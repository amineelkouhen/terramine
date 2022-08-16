terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

###########################################################
# Network Interface
resource "aws_network_interface" "cluster_nic" {
  subnet_id       = var.subnets[count.index % length(var.availability_zones)].id
  security_groups = var.security_groups
  count           = var.worker_count

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-cluster-nic-${count.index}"
  })
}

# Elastic IP to the Network Interface
#resource "aws_eip" "eip" {
#  vpc                       = true
#  count                     = var.worker_count
#  network_interface         = aws_network_interface.cluster_nic[count.index].id
#  associate_with_private_ip = aws_network_interface.cluster_nic[count.index].private_ip
#  depends_on                = [aws_instance.node]
#
#  tags = merge("${var.resource_tags}",{
#    Name = "${var.name}-cluster-eip-${count.index}"
#  })
#}

###########################################################
# EC2
resource "aws_instance" "node" {
  ami = var.machine_image 
  instance_type = var.machine_type
  availability_zone = sort(var.availability_zones)[count.index % length(var.availability_zones)]
  key_name = var.ssh_key_name
  count    = var.worker_count

  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.cluster_nic[count.index].id
  }

  root_block_device {
    volume_size           = var.boot_disk_size
    volume_type           = var.boot_disk_type
    delete_on_termination = true
  }

  user_data = <<-EOF
  #! /bin/bash
  echo "$(date) - CREATING SSH key" >> /home/${var.ssh_user}/install_redis.log
  sudo -u ${var.ssh_user} bash -c 'echo "${file(var.ssh_public_key)}" >> ~/.ssh/authorized_keys'

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
  private_conf=${var.private_conf}

  if [ ${count.index + 1} -eq 1 ]; then
    echo "create cluster" >> /home/${var.ssh_user}/install_redis.log
    command="/opt/redislabs/bin/rladmin cluster create name ${var.cluster_dns} username ${var.redis_user} password '${var.redis_password}' flash_enabled"

    if $rack_aware ; then
      command="$command rack_aware rack_id '${sort(var.availability_zones)[count.index % length(var.availability_zones)]}'"
    fi

    if ! $private_conf; then
      command="$command external_addr $node_external_addr"
    fi
    echo "$command" >> /home/${var.ssh_user}/install_redis.log
    sudo bash -c "$command 2>&1" >> /home/${var.ssh_user}/install_redis.log
  else
    echo "joining cluster " >> /home/${var.ssh_user}/install_redis.log
    command="/opt/redislabs/bin/rladmin cluster join username ${var.redis_user} password '${var.redis_password}' nodes ${aws_network_interface.cluster_nic[0].private_ip} flash_enabled replace_node ${count.index + 1}"
    
    if $rack_aware ; then
      command="$command rack_id '${sort(var.availability_zones)[count.index % length(var.availability_zones)]}'"
    fi

    if ! $private_conf; then
      command="$command external_addr $node_external_addr"
    fi

    echo "$command" >> /home/${var.ssh_user}/install_redis.log
    until sudo bash -c "$command 2>&1" >> /home/${var.ssh_user}/install_redis.log ; do
      echo "joining cluster, retrying in 60 seconds..." >> /home/${var.ssh_user}/install_redis.log
      sleep 60
    done   
  fi
  echo "$(date) - DONE creating cluster node" >> /home/${var.ssh_user}/install_redis.log

  ################
  # NODE external_addr - it runs at each reboot to update it
  echo "${count.index + 1}" > /home/${var.ssh_user}/node_index.terraform
  if ! $private_conf; then
    cat <<EOF > /home/${var.ssh_user}/node_externaladdr.sh
    #!/bin/bash
      node_external_addr=\$(curl -s ifconfig.me/ip)
      # Terraform node_id may not be Redis Enterprise node id
      /opt/redislabs/bin/rladmin node ${count.index + 1} external_addr set \$node_external_addr
      chown ${var.ssh_user} /home/${var.ssh_user}/node_externaladdr.sh
      chmod u+x /home/${var.ssh_user}/node_externaladdr.sh
      /home/${var.ssh_user}/node_externaladdr.sh

      echo "$(date) - DONE updating RS external_addr" >> /home/${var.ssh_user}/install.log
    Footer
  fi
  EOF

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-node-${count.index}"
  })
}

#resource "aws_volume_attachment" "datadisk" {
#  device_name = "/dev/sdc"
#  volume_id   = aws_ebs_volume.datadisk[count.index].id
#  instance_id = aws_instance.node[count.index].id
#  count       = var.worker_count
#}
#resource "aws_ebs_volume" "datadisk" {
#  availability_zone = sort(var.availability_zones)[count.index % length(var.availability_zones)]
#  size              = 5000
#  type              = "gp2"
#  count             = var.worker_count
#
#  tags = merge("${var.resource_tags}",{
#    Name = "${var.name}-datadisk-${count.index}"
#  })
#}

