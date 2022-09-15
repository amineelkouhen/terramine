# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Create public IP for bastion node
resource "azurerm_public_ip" "client-public-ip" {
    name                         = "${var.name}-client-public-ip"
    location                     = var.region
    resource_group_name          = var.resource_group
    allocation_method            = "Static"
    sku                          = "Standard"
    zones                        = [var.availability_zone]

    tags = {
        environment = "${var.name}"
    }
}

# Create network interface for client node
resource "azurerm_network_interface" "client-nic" {
    name                      = "${var.name}-client-nic"
    location                  = var.region
    resource_group_name       = var.resource_group

    ip_configuration {
        name                          = "${var.name}-client-nic-configuration"
        subnet_id                     = var.subnet
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.client-public-ip.id
    }

    tags = {
        environment = "${var.name}"
    }
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

    tags = {
        environment = "${var.name}"
    }
}

# Create client node
resource "azurerm_linux_virtual_machine" "client" {
    name                  = "${var.name}-client"
    location              = var.region
    resource_group_name   = var.resource_group
    network_interface_ids = [azurerm_network_interface.client-nic.id]
    size                  = var.machine_type
    zone                  = var.availability_zone

    os_disk {
      name                 = "${var.name}-client_boot_disk"
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

  #  dynamic "plan" {
  #    for_each = var.machine_plan == "" ? [] : [1]
  #    content {
  #      name      = split(":", var.machine_plan)[0]
  #      product   = split(":", var.machine_plan)[1]
  #      publisher = split(":", var.machine_plan)[2]
  #    }
  #  }
    #}
    
    custom_data = base64encode(<<-EOF
    #!/bin/bash
    echo "$(date) - PREPARING client" >> /home/${var.ssh_user}/prepare_client.log
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

    mkdir /home/${var.ssh_user}/install
    cd /home/${var.ssh_user}/install
    apt-get -y install build-essential autoconf automake libpcre3-dev libevent-dev pkg-config zlib1g-dev libssl-dev

    echo "$(date) - DOWNLOADING memtier from : ${var.memtier_package}" >> /home/${var.ssh_user}/prepare_client.log
    wget -O memtier.tar.gz "${var.memtier_package}" -P /home/${var.ssh_user}/install 
    echo "$(date) - INSTALLING memtier" >> /home/${var.ssh_user}/prepare_client.log
    tar xfz /home/${var.ssh_user}/install/memtier.tar.gz -C /home/${var.ssh_user}/install
    mv memtier_benchmark-*/ memtier

    pushd memtier
    autoreconf -ivf
    ./configure
    make
    sudo make install
    popd

    echo "$(date) - Memtier install done" >> /home/${var.ssh_user}/prepare_client.log

    echo "$(date) - DOWNLOADING redis-cli from : ${var.redis_stack_package}" >> /home/${var.ssh_user}/prepare_client.log
    wget -O redis-stack.tar.gz "${var.redis_stack_package}" -P /home/${var.ssh_user}/install
    echo "$(date) - INSTALLING redis-cli" >> /home/${var.ssh_user}/prepare_client.log
    tar xfz /home/${var.ssh_user}/install/redis-stack.tar.gz -C /home/${var.ssh_user}/install
    mv redis-stack-*/ redis-stack
    sudo mkdir -p /home/${var.ssh_user}/.local/bin
    ln -s /home/${var.ssh_user}/install/redis-stack/bin/redis-benchmark /home/${var.ssh_user}/.local/bin/redis-benchmark
    ln -s /home/${var.ssh_user}/install/redis-stack/bin/redis-cli /home/${var.ssh_user}/.local/bin/redis-cli

    sudo chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/install
    sudo chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.local

    echo "$(date) - redis-cli install done" >> /home/${var.ssh_user}/prepare_client.log

    echo "$(date) - DOWNLOADING Redis Insight from : ${var.redis_insight_package}" >> /home/${var.ssh_user}/prepare_client.log
    wget "${var.redis_insight_package}" -P /home/${var.ssh_user}/install
    echo "$(date) - Starting Redis Insight" >> /home/${var.ssh_user}/prepare_client.log
    mv /home/${var.ssh_user}/install/redisinsight-* /home/${var.ssh_user}/install/redisinsight
    chmod +x /home/${var.ssh_user}/install/redisinsight
    sudo /home/${var.ssh_user}/install/redisinsight >> /home/${var.ssh_user}/prepare_client.log &

    echo "$(date) - Redis Insight install done" >> /home/${var.ssh_user}/prepare_client.log

    echo "$(date) - DOWNLOADING Prometheus from : ${var.promethus_package}" >> /home/${var.ssh_user}/prepare_client.log
    wget "${var.promethus_package}" -P /home/${var.ssh_user}/install
    tar xfz /home/${var.ssh_user}/install/prometheus-*.tar.gz -C /home/${var.ssh_user}/install
    mv prometheus-*/ prometheus

    sudo groupadd --system prometheus
    sudo useradd -s /sbin/nologin --system -g prometheus prometheus
    sudo mkdir /var/lib/prometheus

    for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/$i; done

    sudo mv /home/${var.ssh_user}/install/prometheus/prometheus /home/${var.ssh_user}/install/prometheus/promtool /usr/local/bin/
    sudo mv /home/${var.ssh_user}/install/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
    sudo mv /home/${var.ssh_user}/install/prometheus/consoles/ /home/${var.ssh_user}/install/prometheus/console_libraries/ /etc/prometheus/

    echo "$(date) - OVERRIDING Prometheus configuration" >> /home/${var.ssh_user}/prepare_client.log

    echo "global:
        scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
        evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

    # A scrape configuration containing exactly one endpoint to scrape:
    # Here it's Prometheus itself.
    scrape_configs:
        # The job name is added as a label.
        - job_name: \"prometheus-redis\"
        scheme: https
        tls_config:
            insecure_skip_verify: true

        # metrics_path defaults to '/metrics'
        # scheme defaults to 'http'.

        # Override the global default and scrape targets from this job every 5 seconds.
        scrape_interval: 5s

        static_configs:
            - targets: ['${var.cluster_dns}:8070']" | sudo tee /etc/prometheus/prometheus.yml

    echo "$(date) - CREATING Prometheus Service" >> /home/${var.ssh_user}/prepare_client.log

    echo "[Unit]
    Description=Prometheus Service
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=prometheus
    Group=prometheus
    ExecReload=/bin/kill -HUP \$MAINPID
    ExecStart=/usr/local/bin/prometheus \
        --config.file=/etc/prometheus/prometheus.yml \
        --storage.tsdb.path=/var/lib/prometheus \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries \
        --web.listen-address=0.0.0.0:9090 \
        --web.external-url=

    Restart=always

    [Install]
    WantedBy=multi-user.target
    " | sudo tee /etc/systemd/system/prometheus.service

    for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/$i; done
    for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/$i; done
    sudo chown -R prometheus:prometheus /var/lib/prometheus/

    echo "$(date) - Prometheus install done" >> /home/${var.ssh_user}/prepare_client.log

    echo "$(date) - INSTALLING Grafana" >> /home/${var.ssh_user}/prepare_client.log
    sudo apt-get install -y apt-transport-https
    sudo apt-get install -y software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get -y update
    sudo apt-get install -y grafana-enterprise

    echo "$(date) - Grafana install done" >> /home/${var.ssh_user}/prepare_client.log

    echo "$(date) - STARTING Prometheus Service" >> /home/${var.ssh_user}/prepare_client.log
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl enable prometheus

    echo "$(date) - STARTING Grafana Service" >> /home/${var.ssh_user}/prepare_client.log
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server

    echo "$(date) - CHECKING Services Status" >> /home/${var.ssh_user}/prepare_client.log
    sudo systemctl status prometheus >> /home/${var.ssh_user}/prometheus_status.log 
    sudo systemctl status grafana-server >> /home/${var.ssh_user}/grafana_status.log 

    echo "$(date) - DONE creating client" >> /home/${var.ssh_user}/prepare_client.log
    EOF
    )

    computer_name  = "${var.name}-client"
    admin_username = var.ssh_user
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.ssh_user
        public_key     = file(var.ssh_public_key)
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "${var.name}"
    }
}