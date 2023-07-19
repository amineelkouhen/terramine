  #! /bin/bash
  echo "$(date) - PREPARING machine node" >> /home/${ssh_user}/install_redis.log
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

  echo "$(date) - PREPARE done" >> /home/${ssh_user}/install_redis.log

  ################
  # RS

  echo "$(date) - INSTALLING Redis Enterprise" >> /home/${ssh_user}/install_redis.log
  mkdir /home/${ssh_user}/install

  echo "$(date) - DOWNLOADING Redis Enterprise from : ${redis_distro}" >> /home/${ssh_user}/install_redis.log
  wget "${redis_distro}" -P /home/${ssh_user}/install
  tar xvf /home/${ssh_user}/install/redislabs*.tar -C /home/${ssh_user}/install

  echo "$(date) - INSTALLING Redis Enterprise - silent installation" >> /home/${ssh_user}/install_redis.log

  cd /home/${ssh_user}/install
  sudo /home/${ssh_user}/install/install.sh -y 2>&1 >> /home/${ssh_user}/install_rs.log
  sudo adduser ${ssh_user} redislabs

  echo "$(date) - INSTALL done" >> /home/${ssh_user}/install_redis.log

  ################
  # NODE

  node_external_addr=`curl ifconfig.me/ip`
  echo "Node ${node_id} : $node_external_addr" >> /home/${ssh_user}/install_redis.log
  rack_aware=${rack_aware}
  private_conf=${private_conf}

  if [ ${node_id} -eq 1 ]; then
    echo "create cluster" >> /home/${ssh_user}/install_redis.log
    command="/opt/redislabs/bin/rladmin cluster create name ${cluster_dns} username ${redis_user} password '${redis_password}' flash_enabled"

    if $rack_aware ; then
      command="$command rack_aware rack_id '${availability_zone}'"
    fi

    if ! $private_conf; then
      command="$command external_addr $node_external_addr"
    fi
    echo "$command" >> /home/${ssh_user}/install_redis.log
    sudo bash -c "$command 2>&1" >> /home/${ssh_user}/install_redis.log
  else
    echo "joining cluster " >> /home/${ssh_user}/install_redis.log
    command="/opt/redislabs/bin/rladmin cluster join username ${redis_user} password '${redis_password}' nodes ${node_1_ip} flash_enabled replace_node ${node_id}"
    
    if $rack_aware ; then
      command="$command rack_id '${availability_zone}'"
    fi

    if ! $private_conf; then
      command="$command external_addr $node_external_addr"
    fi

    echo "$command" >> /home/${ssh_user}/install_redis.log
    until sudo bash -c "$command 2>&1" >> /home/${ssh_user}/install_redis.log ; do
      echo "joining cluster, retrying in 60 seconds..." >> /home/${ssh_user}/install_redis.log
      sleep 60
    done   
  fi
  echo "$(date) - DONE creating cluster node" >> /home/${ssh_user}/install_redis.log

  ################
  # Install Docker
  echo "$(date) - Installing Docker" >> /home/${ssh_user}/install_redis.log
  sudo apt update >> /home/${ssh_user}/install_redis.log 2>&1
  sudo apt -y install apt-transport-https ca-certificates curl software-properties-common >> /home/${ssh_user}/install_redis.log 2>&1
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> /home/${ssh_user}/install_redis.log 2>&1
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" >> /home/${ssh_user}/install_redis.log 2>&1
  sudo apt -y install docker-ce >> /home/${ssh_user}/install_redis.log 2>&1
  sudo groupadd docker
  sudo usermod -aG docker ${ssh_user}

  if [ ${node_id} -eq 1 ]; then
    #Add Redis Gears to cluster (Python module only)
    echo "$(date) - Installing Redis Gears..." >> /home/${ssh_user}/install_redis.log
    echo "curl -s https://redismodules.s3.amazonaws.com/redisgears/redisgears.Linux-ubuntu20.04-x86_64.1.2.5.zip -o /tmp/redis-gears.zip" >> /home/${ssh_user}/install_redis.log
    sudo curl -s https://redismodules.s3.amazonaws.com/redisgears/redisgears.Linux-ubuntu20.04-x86_64.1.2.5.zip -o /tmp/redis-gears.zip >> /home/${ssh_user}/install_redis.log 2>&1
    echo "curl -k -u $(redis_user):$(redis_password) -F 'module=@/tmp/redis-gears.zip' https://$(cluster_dns):9443/v2/modules" >> /home/${ssh_user}/install_redis.log
    sudo curl -k -u "${redis_user}:${redis_password}" -F "module=@/tmp/redis-gears.zip" https://${cluster_dns}:9443/v2/modules >> /home/${ssh_user}/install_redis.log 2>&1
  fi

  ################
  # NODE external_addr - it runs at each reboot to update it
  echo "${node_id}" > /home/${ssh_user}/node_index.terraform
  cat <<EOF > /home/${ssh_user}/node_externaladdr.sh
  #!/bin/bash
  node_external_addr=\$(curl -s ifconfig.me/ip)
  # Terraform node_id may not be Redis Enterprise node id
  myip=\$(ifconfig | grep 10.26 | cut -d' ' -f10)
  rs_node_id=\$(/opt/redislabs/bin/rladmin info node all | grep -1 \$myip | grep node | cut -d':' -f2)
  /opt/redislabs/bin/rladmin node \$rs_node_id external_addr set \$node_external_addr
  chown ${ssh_user} /home/${ssh_user}/node_externaladdr.sh
  chmod u+x /home/${ssh_user}/node_externaladdr.sh
  /home/${ssh_user}/node_externaladdr.sh

  echo "$(date) - DONE updating RS external_addr" >> /home/${ssh_user}/install.log
  Footer