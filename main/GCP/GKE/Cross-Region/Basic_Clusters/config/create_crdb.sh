if [[ $# -eq 0 ]] ; then
    echo 'Mandatory arguments not supplied !'
    exit 1
fi

echo "=== Create a Conflict-free Replicated Database (CRDB)... ==="
echo "Cluster 1: $1 - Cluster 2: $5"

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
  --instance fqdn=redis-cluster.$4.svc.cluster.local,url=https://api.$1,username=admin@admin.com,password=admin,replication_endpoint=mydb-db.$1:443,replication_tls_sni=mydb-db.$1 \
  --instance fqdn=redis-cluster.$8.svc.cluster.local,url=https://api.$5,username=admin@admin.com,password=admin,replication_endpoint=mydb-db.$5:443,replication_tls_sni=mydb-db.$5

rm -rf ~/.kube
gcloud container clusters get-credentials $2 --zone $3
kubectl config set-context --current --namespace=$4

until [[ $(kubectl get svc mydb-load-balancer -o "jsonpath={.status.loadBalancer.ingress[0].ip}") =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    echo "waiting for DB Load Balancer IP - Location 1"
    sleep 10
done   

DB_LB_IP_1=`kubectl get svc mydb-load-balancer -o "jsonpath={.status.loadBalancer.ingress[0].ip}"`;

rm -rf ~/.kube
gcloud container clusters get-credentials $6 --zone $7
kubectl config set-context --current --namespace=$8

until [[ $(kubectl get svc mydb-load-balancer -o "jsonpath={.status.loadBalancer.ingress[0].ip}") =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    echo "waiting for DB Load Balancer IP - Location 2"
    sleep 10
done   

DB_LB_IP_2=`kubectl get svc mydb-load-balancer -o "jsonpath={.status.loadBalancer.ingress[0].ip}"`;

echo "===== Now you can test your Redis DB with the command ====="

echo "Using Redis Insight - Host: $DB_LB_IP_1, Port: 18000, Username: default, Password: $DB_PWD"
echo "Using Redis Insight - Host: $DB_LB_IP_2, Port: 18000, Username: default, Password: $DB_PWD"
echo "In your code using this Connection String: redis://default:$DB_PWD@$DB_LB_IP_1:18000"
echo "In your code using this Connection String: redis://default:$DB_PWD@$DB_LB_IP_2:18000"
echo "Or using redis-cli:"
echo "redis-cli -h $DB_LB_IP_1 -p 18000 -a testPassword --tls --cacert proxy_cert.pem"
echo "redis-cli -h $DB_LB_IP_2 -p 18000 -a testPassword --tls --cacert proxy_cert.pem"