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

    $ oc get route default-route -n openshift-image-registry --template=‘{{ .spec.host }}’

If Default Route is not there please configure it using Below Command 

    $ oc patchconfigs.imageregistry.operator.openshift.io/cluster--patch ‘{“spec”:{“defaultRoute”:true}}’--type=merge 
                                          OR 
    $ oc edit configs.imageregistry.operator.openshift.io/clusterPut defaultRoute: true in spec field



Step2: Installation Command
    
1) Create Namespace
     
       $ export NAMESPACE = name of your namespace (you want to create)
       
       $ echo $NAMECPACE
       your namespace name will display here
       
2) Create an observability project in OCP cluster.
 
       $ ./observability.sh 
    
3)  Run pipeline that install operators like Prometheus and Grafana.

        $ ./pipelinerun.sh
    
4) Create OpenShift secret for Blackbox job 

       $ oc create secret generic secret_name –from-file=filepath 
       
       In my case i run below command 
       $ oc create secret generic blackbox-secret --from-file=prometheus-job-blackbox-configuration.yaml
       
5) Install Blackbox Helm ChartPrometheus community Blackbox exporter charts.

      reference link : https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter

       $ helm repo add prometheus-community https://prometheus-community.github.io/helm-chartsb
       
6) Update Helm repo using below command.
        
       $ helm repo update

7) Install black-box helm chart into cluster using below command.

       $ helm install blackbox-exporter prometheus-community/prometheus-blackbox-exporter
    
    
    
8) Add Below Configuration in prometheus object.

       additionalScrapeConfigs:
            key: prometheus-job-blackbox-configuration.yaml (take file name from the blackbox-secret)
            name: blackbox-secret

![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/35203211c705da0439d8133bb16fa7dfae05411f/images/black-box%20configuration%20with%20prometheus.png)

        
            


Step3: Monitoring Stack 


=> Find Grafana Admin Credential
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_admin_credentials.png)


=> Access Grafana Dashboard using route
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_basic_dashboard.png)


=> Create Grafana Dashboard and add datasource in that 
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_datasource_configuration.png)


=> Copy Prometheus route 
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/prometheus_route.png)


=> Grafana add data source, here paste prometheus route URL in HTTP section.
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_add_data_source.png)


=> Grafana Added data source
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/garana_added_data_source.png)


=> Grafana import prometheus data source
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_add_data_source_prometheus.png)


=> Check prometheus import 
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_dashbaord_datasource.png)


=> Add grafana dashboard panel
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_add_panel.png)


=> Add PromeQL that find from **probe_success** in prometheus 
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_add_promQL.png)


=> Configure name and visulization in filed section
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_add_promeQL_field.png)


=> Configured Grafana dashboard
![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_final_dashboard.png)



