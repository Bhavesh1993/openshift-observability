NAMESPACE=$NAMESPACE
echo "************************************************************"
echo "*   Staring observability Image Creation                   *"
echo "************************************************************"
DATE=`date`
START=$(date +%s)
echo "$DATE"
echo "************************************************************"
#echo ""
#echo "***********Deleting ${NAMESPACE} Namespace if Exist***********"
#oc delete project ${NAMESPACE}
#sleep 20
echo ""
echo "***********Creating observability Namespace***********"
oc new-project ${NAMESPACE} --description="observability stack" --display-name="observability"
echo ""
oc project ${NAMESPACE}
echo "***********Building the observability image***********"
route_value=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
echo ""
docker build --platform amd64 -t ${route_value}/${NAMESPACE}/observability-stack:latest .
echo ""
echo "***********Docker Login***********"
docker login -u `oc whoami` -p `oc whoami --show-token` https://${route_value}
echo ""
echo "***********Pushing observability image to internal registry***********"
docker push ${route_value}/${NAMESPACE}/observability-stack:latest
echo ""
sed -i -e "s/NAMESPACE-VAL/${NAMESPACE}/g" "observability-task.yml"
echo "***********Creating observability task for the pipeline setup***********"
oc -n ${NAMESPACE} apply -f observability-task.yml
echo ""
sed -i -e "s/NAMESPACE-VAL/${NAMESPACE}/g" "observability-pipeline.yml"
echo "***********Creating observability Pipeline ***********"
oc -n ${NAMESPACE} apply -f observability-pipeline.yml
echo ""
echo "***********Creating Service Account for Pipeline ***********"
oc create serviceaccount observability-stack -n ${NAMESPACE}
oc policy add-role-to-user cluster-admin system:serviceaccount:${NAMESPACE}:observability-stack -n ${NAMESPACE}
oc policy add-role-to-user system:openshift:scc:anyuid system:serviceaccount:${NAMESPACE}:observability-stack -n ${NAMESPACE}
oc adm policy add-cluster-role-to-user cluster-admin  -z observability-stack
echo ""
echo "***********Completed***********"
