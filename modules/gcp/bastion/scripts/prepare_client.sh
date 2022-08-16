#!/bin/bash
echo "$(date) - PREPARING client" >> /home/${ssh_user}/prepare_client.log
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

mkdir /home/${ssh_user}/install
cd /home/${ssh_user}/install
apt-get -y install build-essential autoconf automake libpcre3-dev libevent-dev pkg-config zlib1g-dev libssl-dev

echo "$(date) - DOWNLOADING memtier from : ${memtier_package}" >> /home/${ssh_user}/prepare_client.log
wget -O memtier.tar.gz "${memtier_package}" -P /home/${ssh_user}/install 
echo "$(date) - INSTALLING memtier" >> /home/${ssh_user}/prepare_client.log
tar xfz /home/${ssh_user}/install/memtier.tar.gz -C /home/${ssh_user}/install
mv memtier_benchmark-*/ memtier

pushd memtier
 autoreconf -ivf
 ./configure
 make
 sudo make install
popd

echo "$(date) - Memtier install done" >> /home/${ssh_user}/prepare_client.log

echo "$(date) - DOWNLOADING redis-cli from : ${redis_stack_package}" >> /home/${ssh_user}/prepare_client.log
wget -O redis-stack.tar.gz "${redis_stack_package}" -P /home/${ssh_user}/install
echo "$(date) - INSTALLING redis-cli" >> /home/${ssh_user}/prepare_client.log
tar xfz /home/${ssh_user}/install/redis-stack.tar.gz -C /home/${ssh_user}/install
mv redis-stack-*/ redis-stack
sudo mkdir -p /home/${ssh_user}/.local/bin
ln -s /home/${ssh_user}/install/redis-stack/bin/redis-benchmark /home/${ssh_user}/.local/bin/redis-benchmark
ln -s /home/${ssh_user}/install/redis-stack/bin/redis-cli /home/${ssh_user}/.local/bin/redis-cli

sudo chown -R ${ssh_user}:${ssh_user} /home/${ssh_user}/install
sudo chown -R ${ssh_user}:${ssh_user} /home/${ssh_user}/.local

echo "$(date) - redis-cli install done" >> /home/${ssh_user}/prepare_client.log

echo "$(date) - DOWNLOADING Prometheus from : ${promethus_package}" >> /home/${ssh_user}/prepare_client.log
wget "${promethus_package}" -P /home/${ssh_user}/install
tar xfz /home/${ssh_user}/install/prometheus-*.tar.gz -C /home/${ssh_user}/install
mv prometheus-*/ prometheus

sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mkdir /var/lib/prometheus

for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/$i; done

sudo mv /home/${ssh_user}/install/prometheus/prometheus /home/${ssh_user}/install/prometheus/promtool /usr/local/bin/
sudo mv /home/${ssh_user}/install/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
sudo mv /home/${ssh_user}/install/prometheus/consoles/ /home/${ssh_user}/install/prometheus/console_libraries/ /etc/prometheus/

echo "$(date) - OVERRIDING Prometheus configuration" >> /home/${ssh_user}/prepare_client.log

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
      - targets: ['${cluster_dns}:8070']" | sudo tee /etc/prometheus/prometheus.yml

echo "$(date) - CREATING Prometheus Service" >> /home/${ssh_user}/prepare_client.log

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

echo "$(date) - Prometheus install done" >> /home/${ssh_user}/prepare_client.log

echo "$(date) - INSTALLING Grafana" >> /home/${ssh_user}/prepare_client.log
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/enterprise/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get -y update
sudo apt-get install -y grafana-enterprise

echo "$(date) - Grafana install done" >> /home/${ssh_user}/prepare_client.log

echo "$(date) - STARTING Prometheus Service" >> /home/${ssh_user}/prepare_client.log
sudo systemctl daemon-reload
sudo systemctl start prometheus

echo "$(date) - STARTING Grafana Service" >> /home/${ssh_user}/prepare_client.log
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo "$(date) - CHECKING Services Status" >> /home/${ssh_user}/prepare_client.log
sudo systemctl status prometheus >> /home/${ssh_user}/prometheus_status.log 
sudo systemctl status grafana-server >> /home/${ssh_user}/grafana_status.log 

echo "$(date) - DONE creating client" >> /home/${ssh_user}/prepare_client.log
