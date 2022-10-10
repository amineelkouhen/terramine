kubectl exec -it redis-cluster-0 -- \
crdb-cli crdb create \
  --name redis-crdb \
  --port 18000 \
  --password testPassword \
  --memory-size 2GB \
  --replication true \
  --sharding true \
  --shards-count 2 \
  --instance fqdn=redis-cluster.NAMESPACE_CLUSTER_1.svc.cluster.local,url=https://api.IPADDRESS_CLUSTER_1,username=admin@admin.com,password=admin,replication_endpoint=redis-db.IPADDRESS_CLUSTER_1:443,replication_tls_sni=redis-crdb.IPADDRESS_CLUSTER_1 \
  --instance fqdn=redis-cluster.NAMESPACE_CLUSTER_2.svc.cluster.local,url=https://api.IPADDRESS_CLUSTER_2,username=admin@admin.com,password=admin,replication_endpoint=redis-db.IPADDRESS_CLUSTER_2:443,replication_tls_sni=redis-crdb.IPADDRESS_CLUSTER_2