rm -rf ~/.kube
gcloud container clusters get-credentials $1 --region $2

echo "=== Creating and switching to new Context... ==="
kubectl create namespace $3
kubectl config set-context --current --namespace=$3

VERSION=`curl --silent https://api.github.com/repos/RedisLabs/redis-enterprise-k8s-docs/releases/latest | grep tag_name | awk -F'"' '{print $4}'`;                  
kubectl apply -f https://raw.githubusercontent.com/RedisLabs/redis-enterprise-k8s-docs/$VERSION/bundle.yaml

echo "=== Creating Redis Enterprise Cluster... ==="

kubectl apply -f config/redis-cluster.yaml
sleep 30
kubectl rollout status sts/redis-cluster

RE_USER=$(kubectl get secret redis-cluster -o jsonpath="{.data.username}" | base64 --decode); 
RE_PWD=$(kubectl get secret redis-cluster -o jsonpath="{.data.password}" | base64 --decode); 
UI_LB_ENDPOINT=$(kubectl get svc redis-cluster-ui -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo "Redis Enterprise Cluster Created. RE UI is exposed on: https://$UI_LB_ENDPOINT:8443"
echo "Cluster Credentials"
echo "user: $RE_USER"; 
echo "password: $RE_PWD"

echo "=== Exporting Cluster Proxy Certificate... ==="
kubectl exec -it -n $3 redis-cluster-0 -- bash -c "cat /etc/opt/redislabs/proxy_cert.pem" >> proxy_cert.pem

echo "=== Creating Redis Enterprise Database... ==="
kubectl apply -f config/redis-db.yaml

until [ "$(kubectl get redb redis-db -o jsonpath="{.status.status}")" == "active" ]; do
    sleep 10
done   

echo "=== Redis Enterprise Database Created ==="


DB_PWD=$(kubectl get secret redb-redis-db -o jsonpath="{.data.password}" | base64 --decode); 
DB_LB_ENDPOINT=$(kubectl get svc redis-db-load-balancer -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo "=== Redis Enterprise Database Created ==="
echo "Now you can test your Redis DB with the command:"
echo "kubectl exec -it redis-cluster-0 -- redis-cli -h $DB_LB_ENDPOINT -p 18000 -a $DB_PWD"
echo "or with using TLS (if activated)"
echo "kubectl exec -it redis-cluster-0 -- redis-cli -h $DB_LB_ENDPOINT -p 18000 -a $DB_PWD --tls --cacert proxy_cert.pem"