if [[ $# -eq 0 ]] ; then
    echo 'Mandatory arguments not supplied !'
    exit 1
fi

echo "=== Create a Conflict-free Replicated Database (CRDB)... ==="
echo "Cluster 1: $1 - Cluster 2: $3"

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
  --instance fqdn=redis-cluster.$2.svc.cluster.local,url=https://api.$1,username=admin@admin.com,password=admin,replication_endpoint=mydb-db.$1:443,replication_tls_sni=mydb-db.$1 \
  --instance fqdn=redis-cluster.$4.svc.cluster.local,url=https://api.$3,username=admin@admin.com,password=admin,replication_endpoint=mydb-db.$3:443,replication_tls_sni=mydb-db.$3

echo "=== Create a Conflict-free Replicated Database (CRDB)... ==="
echo "Now you can test your CRDB with the command:"
echo "kubectl exec -it redis-cluster-0 -- redis-cli -h mydb -p 18000 -a testPassword"