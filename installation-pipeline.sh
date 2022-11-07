NAMESPACE=$NAMESPACE
echo "************************************************************"
echo "*   Staring Observability Stack Deployment                 *"
echo "************************************************************"
DATE=`date`
START=$(date +%s)
echo "$DATE"
echo ""
echo "namespace from environment = "${NAMESPACE}
echo ""
sed -i -e "s/NAMESPACE/${NAMESPACE}/g" "grafanaoperator.yml"

echo "*   1.installing grafana operator         *"
oc apply -f grafanaoperator.yml

sed -i -e "s/NAMESPACE/${NAMESPACE}/g" "grafana.yml"
echo "*   2.installing grafana instance         *"
oc apply -f grafana.yml

sed -i -e "s/NAMESPACE/${NAMESPACE}/g" "prometheousoperator.yml"
echo "*   3.installing prometheus operator         *"
oc apply -f prometheousoperator.yml

sed -i -e "s/NAMESPACE/${NAMESPACE}/g" "prometheuscustomresource.yml"
echo "*   4.installing prometheus instance         *"
oc apply -f prometheuscustomresource.yml

sed -i -e "s/NAMESPACE/${NAMESPACE}/g" "thanos.yml"
echo "*   5.configuration thanos  storage        *"
oc apply -f thanos.yml

sed -i -e "s/NAMESPACE/${NAMESPACE}/g" "thanos-ruler.yml"
echo "*   6. installing  thanos          *"
oc apply -f thanos-ruler.yml