terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

############################################################
# Network Interface

resource "aws_network_interface" "nic" {
  subnet_id       = var.subnet
  security_groups = var.security_groups

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-client-nic"
  })
}


# Elastic IP to the Network Interface
resource "aws_eip" "eip" {
  vpc                       = true
  network_interface         = aws_network_interface.nic.id
  associate_with_private_ip = aws_network_interface.nic.private_ip
  depends_on                = [aws_instance.bastion]

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-client-eip"
  })
}


############################################################
# EC2

resource "aws_instance" "bastion" {
  ami               = var.machine_image 
  instance_type     = var.machine_type
  availability_zone = var.availability_zone
  key_name          = var.ssh_key_name

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-client"
  })

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.nic.id
  }

  user_data = <<-EOF
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

  ################
  # Install Docker
  echo "$(date) - Installing Docker" >> /home/${var.ssh_user}/prepare_client.log
  sudo apt update >> /home/${var.ssh_user}/prepare_client.log 2>&1
  sudo apt -y install apt-transport-https ca-certificates curl software-properties-common >> /home/${var.ssh_user}/prepare_client.log 2>&1
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> /home/${var.ssh_user}/prepare_client.log 2>&1
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" >> /home/${var.ssh_user}/prepare_client.log 2>&1
  sudo apt -y install docker-ce >> /home/${var.ssh_user}/prepare_client.log 2>&1
  sudo groupadd docker
  sudo usermod -aG docker ${var.ssh_user}

  ################
  # Link Grafana to Prometheus
  echo "$(date) - Link Grafana to Prometheus" >> /home/${var.ssh_user}/prepare_client.log
  echo "apiVersion: 1
  datasources:
  - name: Prometheus
      type: prometheus
      access: proxy
      url: http://127.0.0.1:9090
  " | sudo tee /etc/grafana/provisioning/datasources/prometheus.yaml

  ################
  # Dashboards provisionning
  echo "$(date) - Dashboards provisionning" >> /home/${var.ssh_user}/prepare_client.log
  echo "apiVersion: 1
  providers:
  - name: 'default'
      orgId: 1
      folder: ''
      type: file
      options:
      path: /var/lib/grafana/dashboards
  " | sudo tee /etc/grafana/provisioning/dashboards/dashboards.yaml

  sudo mkdir -p /var/lib/grafana/dashboards
  sudo chown -R grafana.grafana /var/lib/grafana/dashboards
  sudo systemctl restart grafana-server

  ################
  # Adding Dashboard: Redis cluster dashboards (18405)
  echo "$(date) - Adding Dashboard: redis cluster (18405)" >> /home/${var.ssh_user}/prepare_client.log
  sudo wget -O /var/lib/grafana/dashboards/18405-cluster-status.json https://grafana.com/api/dashboards/18405/revisions/1/download
  echo "Replacing $${DS_PROMETHEUS} with Prometheus" >> /home/${var.ssh_user}/prepare_client.log
  sudo sed -i 's/\$${DS_PROMETHEUS}/Prometheus/' /var/lib/grafana/dashboards/18405-cluster-status.json

  ################
  # Adding Dashboard: Redis database dashboards (18408)
  echo "$(date) - Adding Dashboard: Redis Database Dashboards (18408)" >> /home/${var.ssh_user}/prepare_client.log
  sudo wget -O /var/lib/grafana/dashboards/18408-database-status-dashboard.json https://grafana.com/api/dashboards/18408/revisions/2/download
  echo "Replacing $${DS_PROMETHEUS} with Prometheus" >> /home/${var.ssh_user}/prepare_client.log
  sudo sed -i 's/\$${DS_PROMETHEUS}/Prometheus/' /var/lib/grafana/dashboards/18408-database-status-dashboard.json

  ################
  # Adding Dashboard: Redis nodes metrics dashboard
  echo "$(date) - Adding Dashboard: Redis nodes metrics dashboard" >> /home/${var.ssh_user}/prepare_client.log
  sudo wget -O /var/lib/grafana/dashboards/redis-software-node-dashboard.json https://raw.githubusercontent.com/redis-field-engineering/redis-enterprise-grafana-dashboards/main/dashboards/software/basic/redis-software-node-dashboard.json
  echo "Replacing $${DS_PROMETHEUS} with Prometheus" >> /home/${var.ssh_user}/prepare_client.log
  sudo sed -i 's/\$${DS_PROMETHEUS}/Prometheus/' /var/lib/grafana/dashboards/redis-software-node-dashboard.json

  # Adding Dashboard: Redis shards metrics dashboard
  echo "$(date) - Adding Dashboard: Redis shards metrics dashboard" >> /home/${var.ssh_user}/prepare_client.log
  sudo wget -O /var/lib/grafana/dashboards/redis-software-shard-dashboard.json https://raw.githubusercontent.com/redis-field-engineering/redis-enterprise-grafana-dashboards/main/dashboards/software/basic/redis-software-shard-dashboard.json
  echo "Replacing $${DS_PROMETHEUS} with Prometheus" >> /home/${var.ssh_user}/prepare_client.log
  sudo sed -i 's/\$${DS_PROMETHEUS}/Prometheus/' /var/lib/grafana/dashboards/redis-software-shard-dashboard.json

  # Restart Grafana
  echo "$(date) - Restart Grafana Server" >> /home/${var.ssh_user}/prepare_client.log
  sudo systemctl restart grafana-server

  echo "$(date) - DONE creating client" >> /home/${var.ssh_user}/prepare_client.log
  EOF

  root_block_device {
    volume_size           = var.boot_disk_size
    volume_type           = var.boot_disk_type
    delete_on_termination = true
  }

}