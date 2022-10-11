echo "=== Create a Conflict-free Replicated Database (CRDB)... ==="
kubectl exec -it redis-cluster-0 -- \
crdb-cli crdb create \
  --name mydb \
  --port 18000 \
  --password testPassword \
  --memory-size 2GB \
  --replication true \
  --sharding true \
  --shards-count 2 \
  --encryption yes \
  --instance fqdn=redis-cluster.NAMESPACE_CLUSTER_1.svc.cluster.local,url=https://api.IPADDRESS_CLUSTER_1,username=admin@admin.com,password=admin,replication_endpoint=mydb-db.IPADDRESS_CLUSTER_1:443,replication_tls_sni=mydb-db.IPADDRESS_CLUSTER_1 \
  --instance fqdn=redis-cluster.NAMESPACE_CLUSTER_2.svc.cluster.local,url=https://api.IPADDRESS_CLUSTER_2,username=admin@admin.com,password=admin,replication_endpoint=mydb-db.IPADDRESS_CLUSTER_2:443,replication_tls_sni=mydb-db.IPADDRESS_CLUSTER_2

echo "=== Create a Conflict-free Replicated Database (CRDB)... ==="
echo "Now you can test your CRDB with the command:"
echo "kubectl exec -it redis-cluster-0 -- redis-cli -h mydb -p 18000 -a testPassword"