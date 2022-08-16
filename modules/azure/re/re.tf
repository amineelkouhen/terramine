# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Create public IPs
resource "azurerm_public_ip" "public-ips" {
  count               = var.worker_count
  name                = "${var.name}-public-IP-${count.index}"
  location            = var.region
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [sort(var.availability_zones)[count.index % length(var.availability_zones)]]
}

# Create network interface for Redis nodes
resource "azurerm_network_interface" "nic" {
    name                = "${var.name}-node-${count.index}-nic"
    location            = var.region
    resource_group_name = var.resource_group
    depends_on          = [azurerm_public_ip.public-ips]
    count               = var.worker_count

    ip_configuration {
        name                          = "${var.name}-node-nic-${count.index}-configuration"
        subnet_id                     = var.subnets[count.index % length(var.subnets)]
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public-ips[count.index].id
    }

    tags = merge("${var.resource_tags}",{
        environment = "${var.name}"
    })
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = var.resource_group
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = var.resource_group
    location                    = var.region
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = merge("${var.resource_tags}",{
        environment = "${var.name}"
    })
}

# Create Redis nodes
resource "azurerm_linux_virtual_machine" "nodes" {
    name                  = "${var.name}-node-${count.index}"
    location              = var.region
    resource_group_name   = var.resource_group
    network_interface_ids = [azurerm_network_interface.nic[count.index].id]
    size                  = var.machine_type
    zone                  = sort(var.availability_zones)[count.index % length(var.availability_zones)]
    count                 = var.worker_count

    os_disk {
      name                 = "${var.name}-node-${count.index}_boot_disk"
      caching              = "ReadWrite"
      storage_account_type = "${var.boot_disk_type}"
      disk_size_gb         = var.boot_disk_size
    }

    source_image_reference {
      publisher = split(":", var.machine_image)[0]
      offer     = split(":", var.machine_image)[1]
      sku       = split(":", var.machine_image)[2]
      version   = split(":", var.machine_image)[3]
    }

    #dynamic "plan" {
    #  for_each = var.machine_plan == "" ? [] : [1]
    #  content {
    #    name      = split(":", var.machine_plan)[0]
    #    product   = split(":", var.machine_plan)[1]
    #    publisher = split(":", var.machine_plan)[2]
    #  }
    #}

    custom_data = base64encode(<<-EOF
    #! /bin/bash
    echo "$(date) - PREPARING machine node" >> /home/${var.ssh_user}/install_redis.log
    apt-get -y update
    apt-get -y install vim
    apt-get -y install iotop
    apt-get -y install iputils-ping

    apt-get install -y netcat
    apt-get install -y dnsutils
    export DEBIAN_FRONTEND=noninteractive
    export TZ="UTC"
    apt-get install -y tzdata
    ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata

    # cloud instance have no swap anyway
    #swapoff -a
    #sed -i.bak '/ swap / s/^(.*)$/#1/g' /etc/fstab
    echo 'DNSStubListener=no' | tee -a /etc/systemd/resolved.conf
    mv /etc/resolv.conf /etc/resolv.conf.orig
    ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    service systemd-resolved restart
    sysctl -w net.ipv4.ip_local_port_range="40000 65535"
    echo "net.ipv4.ip_local_port_range = 40000 65535" >> /etc/sysctl.conf

    echo "$(date) - PREPARE done" >> /home/${var.ssh_user}/install_redis.log

    ################
    # RS

    echo "$(date) - INSTALLING Redis Enterprise" >> /home/${var.ssh_user}/install_redis.log

    mkdir /home/${var.ssh_user}/install

    echo "$(date) - DOWNLOADING Redis Enterprise from : " ${var.redis_distro} >> /home/${var.ssh_user}/install_redis.log
    wget "${var.redis_distro}" -P /home/${var.ssh_user}/install
    tar xvf /home/${var.ssh_user}/install/redislabs*.tar -C /home/${var.ssh_user}/install

    echo "$(date) - INSTALLING Redis Enterprise - silent installation" >> /home/${var.ssh_user}/install_redis.log

    cd /home/${var.ssh_user}/install
    sudo /home/${var.ssh_user}/install/install.sh -y 2>&1 >> /home/${var.ssh_user}/install_rs.log
    sudo adduser ${var.ssh_user} redislabs

    echo "$(date) - INSTALL done" >> /home/${var.ssh_user}/install_redis.log

    ################
    # NODE

    node_external_addr=`curl ifconfig.me/ip`
    echo "Node ${count.index + 1} : $node_external_addr" >> /home/${var.ssh_user}/install_redis.log
    rack_aware=${var.rack_aware}

    if $rack_aware ; then
      if [ ${count.index + 1} -eq 1 ]; then
        echo "create cluster" >> /home/${var.ssh_user}/install_redis.log
        echo "rladmin cluster create name ${var.cluster_dns} username ${var.redis_user} password '${var.redis_password}' external_addr $node_external_addr flash_enabled rack_aware rack_id 'AZ-${sort(var.availability_zones)[count.index % length(var.availability_zones)]}' " >> /home/${var.ssh_user}/install_redis.log
        /opt/redislabs/bin/rladmin cluster create name ${var.cluster_dns} username ${var.redis_user} password '${var.redis_password}' external_addr $node_external_addr flash_enabled rack_aware rack_id 'AZ-${sort(var.availability_zones)[count.index % length(var.availability_zones)]}' 2>&1 >> /home/${var.ssh_user}/install_redis.log
      else
          echo "joining cluster " >> /home/${var.ssh_user}/install_redis.log
          until sudo /opt/redislabs/bin/rladmin cluster join username ${var.redis_user} password '${var.redis_password}' nodes ${azurerm_public_ip.public-ips[0].ip_address} external_addr $node_external_addr flash_enabled rack_id 'AZ-${sort(var.availability_zones)[count.index % length(var.availability_zones)]}' replace_node ${count.index + 1} 2>&1; do
            echo "rladmin cluster join username ${var.redis_user} password '${var.redis_password}' nodes ${azurerm_public_ip.public-ips[0].ip_address} external_addr $node_external_addr flash_enabled rack_id 'AZ-${sort(var.availability_zones)[count.index % length(var.availability_zones)]}' replace_node ${count.index + 1}" >> /home/${var.ssh_user}/install_redis.log
            echo joining cluster, retrying in 60 seconds... >> /home/${var.ssh_user}/install_redis.log
            sleep 60
          done   
      fi
    else
      if [ ${count.index + 1} -eq 1 ]; then
        echo "create cluster" >> /home/${var.ssh_user}/install_redis.log
        echo "rladmin cluster create name ${var.cluster_dns} username ${var.redis_user} password '${var.redis_password}' external_addr $node_external_addr flash_enabled " >> /home/${var.ssh_user}/install_redis.log
        /opt/redislabs/bin/rladmin cluster create name ${var.cluster_dns} username ${var.redis_user} password '${var.redis_password}' external_addr $node_external_addr flash_enabled 2>&1 >> /home/${var.ssh_user}/install_redis.log
      else
        echo "joining cluster " >> /home/${var.ssh_user}/install_redis.log
        until sudo /opt/redislabs/bin/rladmin cluster join username ${var.redis_user} password '${var.redis_password}' nodes ${azurerm_public_ip.public-ips[0].ip_address} external_addr $node_external_addr flash_enabled replace_node ${count.index + 1} 2>&1; do
          echo "rladmin cluster join username ${var.redis_user} password '${var.redis_password}' nodes ${azurerm_public_ip.public-ips[0].ip_address} external_addr $node_external_addr flash_enabled replace_node ${count.index + 1}" >> /home/${var.ssh_user}/install_redis.log
          echo joining cluster, retrying in 60 seconds... >> /home/${var.ssh_user}/install_redis.log
          sleep 60
        done
      fi
    fi
    echo "$(date) - DONE creating cluster node" >> /home/${var.ssh_user}/install_redis.log

    ################
    # NODE external_addr - it runs at each reboot to update it
    echo "${count.index + 1}" > /home/${var.ssh_user}/node_index.terraform
    cat <<EOF > /home/${var.ssh_user}/node_externaladdr.sh
    #!/bin/bash
    node_external_addr=\$(curl -s ifconfig.me/ip)
    # Terraform node_id may not be Redis Enterprise node id
    myip=\$(ifconfig | grep 10.26 | cut -d' ' -f10)
    rs_node_id=\$(/opt/redislabs/bin/rladmin info node all | grep -1 \$myip | grep node | cut -d':' -f2)
    /opt/redislabs/bin/rladmin node \$rs_node_id external_addr set \$node_external_addr
    chown ${var.ssh_user} /home/${var.ssh_user}/node_externaladdr.sh
    chmod u+x /home/${var.ssh_user}/node_externaladdr.sh
    /home/${var.ssh_user}/node_externaladdr.sh

    echo "$(date) - DONE updating RS external_addr" >> /home/${var.ssh_user}/install.log
    Footer
    EOF
    )

    computer_name  = "${var.name}-node-${count.index}"
    admin_username = var.ssh_user
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.ssh_user
        public_key     = file(var.ssh_public_key)
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = merge("${var.resource_tags}",{
        environment = "${var.name}"
    })
}
#resource "azurerm_managed_disk" "datadisk" {
#  name                 = "${var.name}-redis-${count.index}-datadisk"
#  location             = var.region
#  resource_group_name  = var.resource_group
#  storage_account_type = "Premium_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = 4000
#  count                = var.machine_count
#  zones                = [ sort(var.zones)[count.index % length(var.zones)] ]
#}

#resource "azurerm_virtual_machine_data_disk_attachment" "datadisk" {
#  managed_disk_id    = azurerm_managed_disk.datadisk[count.index].id
#  virtual_machine_id = azurerm_linux_virtual_machine.redis[count.index].id
#  lun                = "3"
#  caching            = "ReadWrite"
#  count              = var.machine_count
#}