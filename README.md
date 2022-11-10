# openshift-observability
openshift-observability

Pre-Requisites:

Step1: Check Default Route Using Below command in Open Shift Cluster 

    oc get route default-route -n openshift-image-registry --template=‘{{ .spec.host }}’

If Default Route is not there please configure it using Below Command 

    oc patchconfigs.imageregistry.operator.openshift.io/cluster--patch ‘{“spec”:{“defaultRoute”:true}}’--type=merge 
                                          OR 
    oc edit configs.imageregistry.operator.openshift.io/clusterPut defaultRoute: true in spec field

Step2: Installation Command

    1) ./observability.sh=> It create an observability project in OCP cluster
    
    2) ./pipelinerun.sh=> It create pipeline that install operators like Prometheus and Grafana 
    
    3) Create OpenShift secret for Blackbox job 
       oc create secret generic secret_name –from-file=filepath oc create secret generic blackbox-secret --from-file=prometheus-job-blackbox-configuration.yaml
       
    4) Install Blackbox Helm ChartPrometheus community Blackbox exporter charts
       Link => https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter
       4.1) helm repo add prometheus-community https://prometheus-community.github.io/helm-chartsb
       4.2) helm repo updatec
       4.3) helm install blackbox-exporter prometheus-community/prometheus-blackbox-exporter
