NAMESPACE=$NAMESPACE
echo "************************************************************"
echo "*   Staring observability pipeline run                     *"
echo "************************************************************"
DATE=`date`
START=$(date +%s)
echo "$DATE"
echo "************************************************************"

sed -i -e "s/NAMESPACE-VAL/${NAMESPACE}/g" "pipelinerun.yml"
echo "***********Creating observability Pipeline ***********"
oc -n ${NAMESPACE} create -f pipelinerun.yml
echo ""

echo "***********Completed***********"
