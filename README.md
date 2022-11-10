# openshift-observability

**What is Openshift Monitoring?**

OpenShift Container Platform includes a preconfigured, preinstalled, and self-updating monitoring stack that provides monitoring for core platform components. It also have the option to enable monitoring for user-defined projects.

A cluster administrator can configure the monitoring stack with the supported configurations. OpenShift Container Platform delivers monitoring best practices out of the box.

A set of alerts are included by default that immediately notify cluster administrators about issues with a cluster. Default dashboards in the OpenShift Container Platform web console include visual representations of cluster metrics to help you to quickly understand the state of your cluster.

 
Challenges:
- We needed a way to view the health and availability of user defined applications.
- We needed an automated way to install the observability stack using Prometheus and Grafana operators with the help of OpenShift pipeline.
- We did not have a way of probing endpoints with Prometheus.

Outcome:
- This project involves the automatic installation of Observability stack onto OpenShift through a pipeline.
- It captures baseline metrics from apps installed on the cluster (Using Prometheus).
- Determines service availability by probing endpoints with Blackbox Exporter.

Scope:
- Gather metrics from user defined projects and determine availability of service endpoints.
- Display service availability on a Grafana dashboard.

Why need observability ?
- To have real-time health updates and transparency of information with regard to a service’s status.
- Providing a platform for inspecting and adapting according to SLOs and ultimately improving teams’ ability to meet them.

Technology Stack:
  1) Build and Deployment => Docker, OpenShift
  2) Monitoring => Grafana, Prometheus, Black-box exporter

What is Black-Box Exporter ? 
- The Blackbox exporter is a probing exporter that allows to monitor network endpoints such as HTTP,HTTPS, DNS, ICMP or TCP.
- This exporter generates multiple metrics on your configured targets, like general endpoint status, response time, redirect information, or certificate expiration dates.
- By default, when performing HTTP probes, this exporter uses the GET HTTP method to explore your targets and expects a status code similar to 2xx.

Black-Box Exporter Use case:
- Use to measure response times.
- As application developer wants to check the availability of services, their uptime and network health.
- Analysing the latency of specific targets and paths of services running in the same cluster



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
       4.2) helm repo update
       4.3) helm install blackbox-exporter prometheus-community/prometheus-blackbox-exporter
    
    5) Add Below Configuration in prometheus object.
        additionalScrapeConfigs:
            key: prometheus-job-blackbox-configuration.yaml (take file name from the blackbox-secret)
            name: blackbox-secret
