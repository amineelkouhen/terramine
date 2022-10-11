if [[ $# -eq 0 ]] ; then
    echo 'Mandatory arguments not supplied !'
    exit 1
fi

echo "--- Deploy $1 Cluster ---"
./config/cluster_deployment.sh $1 $2 $3
EXTERNAL_IP=`kubectl get svc -n ingress-controller haproxy-ingress -o "jsonpath={.status.loadBalancer.ingress[0].ip}"`;
IPADDRESS_CLUSTER_1="${EXTERNAL_IP}.nip.io"

echo "--- Deploy $4 Cluster ---"
./config/cluster_deployment.sh $4 $5 $6
EXTERNAL_IP=`kubectl get svc -n ingress-controller haproxy-ingress -o "jsonpath={.status.loadBalancer.ingress[0].ip}"`;
IPADDRESS_CLUSTER_2="${EXTERNAL_IP}.nip.io"

./config/create_crdb.sh $IPADDRESS_CLUSTER_1 $3 $IPADDRESS_CLUSTER_2 $6