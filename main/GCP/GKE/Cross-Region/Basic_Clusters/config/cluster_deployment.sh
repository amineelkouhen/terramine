if [[ $# -eq 0 ]] ; then
    echo 'Mandatory arguments not supplied !'
    exit 1
fi

rm -rf ~/.kube
gcloud container clusters get-credentials $1 --zone $2

echo "=== Creating and switching to new Context... ==="
kubectl create namespace $3
kubectl config set-context --current --namespace=$3

echo "=== Deploy Redis Operator... ==="
#VERSION=`curl --silent https://api.github.com/repos/RedisLabs/redis-enterprise-k8s-docs/releases/latest | grep tag_name | awk -F'"' '{print $4}'`;                  
kubectl apply -f https://raw.githubusercontent.com/RedisLabs/redis-enterprise-k8s-docs/6.2.12-1/bundle.yaml

echo "=== Setup HAProxy Ingress controller... ==="
kubectl apply -f config/haproxy-ingress.yaml

echo "=== Create an Entrypoint to our k8s cluster... ==="
kubectl apply -f config/loadbalancer.yaml

#echo "=== Configure Permissions to listen on system ports (80 and 443)... ==="
#kubectl apply -f config/psp.haproxy.yaml

echo "=== Put a label to all the nodes of the cluster... ==="
kubectl label node --all role=ingress-controller

until [[ $(kubectl get svc -n ingress-controller haproxy-ingress -o "jsonpath={.status.loadBalancer.ingress[0].ip}") =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
    echo "waiting for ingress IP"
    sleep 10
done   

EXTERNAL_IP=`kubectl get svc -n ingress-controller haproxy-ingress -o "jsonpath={.status.loadBalancer.ingress[0].ip}"`;

echo "The External IP address (ingress) is ${EXTERNAL_IP}"

ADDRESS="${EXTERNAL_IP}.nip.io"

cat config/redis-cluster.template | sed -e "s/IPADDRESS/$ADDRESS/g" -e "s/NAMESPACE/$3/g" > config/redis-cluster.yaml
sleep 10

echo "=== Creating Redis Enterprise Cluster... ==="
kubectl apply -f config/redis-cluster.yaml
sleep 30
kubectl rollout status sts/redis-cluster

echo "=== Exporting Cluster Proxy Certificate... ==="
kubectl exec -it -n $3 redis-cluster-0 -- bash -c "cat /etc/opt/redislabs/proxy_cert.pem" > proxy_cert.pem

echo "=== Prepare the routing rules in ingress.yaml ==="
cat config/ingress.template | sed -e "s/IPADDRESS/$ADDRESS/g" -e "s/NAMESPACE/$3/g" > config/ingress.yaml

echo "=== Create the Routing rules... ==="
kubectl apply -f config/ingress.yaml

RE_USER=$(kubectl get secret redis-cluster -o jsonpath="{.data.username}" | base64 --decode); 
RE_PWD=$(kubectl get secret redis-cluster -o jsonpath="{.data.password}" | base64 --decode); 
UI_LB_ENDPOINT=$(kubectl get svc redis-cluster-ui -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo "Redis Enterprise Cluster Created. RE UI is exposed on: https://$UI_LB_ENDPOINT:8443"
echo "Cluster Credentials"
echo "user: $RE_USER"; 
echo "password: $RE_PWD"