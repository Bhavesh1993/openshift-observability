# openshift-observability

**What is Openshift Monitoring?**

OpenShift Container Platform includes a preconfigured, preinstalled, and self-updating monitoring stack that provides monitoring for core platform components. 

 Default dashboards in the OpenShift Container Platform web console include visual representations of cluster metrics to help you to quickly understand the state of your cluster. This stack, however, does not monitor user defined applications out of the box nor does it provide a way to scrape endpoints and monitor responses for service availablitiy.
 
Challenges:
- We needed a way to view the health and availability of user defined applications.
- We did not have a way of probing endpoints with Prometheus.

Outcome:
- This monitoring stack captures baseline metrics from apps installed on the cluster (Using Prometheus).
- Determines service availability by probing endpoints with Blackbox Exporter.

Scope:
- Gather metrics from user defined projects and determine availability of service endpoints with Blackbox Exporter.
- Display service availability on a Grafana dashboard.


What is Blackbox Exporter ? 
- Blackbox Exporter is a probing exporter that allows monitoring network endpoints using HTTP, HTTPS, DNS, ICMP or TCP protocols.
- This exporter generates multiple metrics on your configured targets, like general endpoint status, response time, redirect information, or certificate expiration dates.
- By default, when performing HTTP probes, this exporter uses the GET HTTP method to explore your targets and expects a status code similar to 2xx.

Blackbox Exporter Use case:
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

- Requires Docker


Step2: Installation of the Prometheus and Grafana
    
1) Set the Namespace for the demo application and observability stack

```     
export NAMESPACE = <name of your namespace (you want to create)>
```

```       
echo $NAMESPACE
```


2) Run the script to create the namespace and prepare the cluster for observability stack installation.

       ``` 
       ./observability.sh 
       ```

3)  Run pipeline that install operators for Prometheus and Grafana.

```
./pipelinerun.sh
```

Step 3: Install Blackbox Exporter
       
1) Install Blackbox Helm ChartPrometheus community Blackbox exporter charts.

      reference link : https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-chartsb
```       

2) Update Helm repo using below command.

```        
helm repo update
```

3) Install black-box helm chart into cluster using below command.

```
helm install blackbox-exporter prometheus-community/prometheus-blackbox-exporter
```

8) Deploy a demo application

- From the OpenShift console, click on the `Administrator` dropdown at the top left and select the `Developer` perspective.
- Click on `Add` on the left navigation pane and click on `Samples`
- Click on the `Basic Python` sample

 ![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/9fc158cefe6895438e983f2c77b615093dccad7b/images/python%20application%20install%201.png)

- Click `Create` on the `Import from Git`

 ![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/9fc158cefe6895438e983f2c77b615093dccad7b/images/python%20application%20install%202.png)

- Click on the `Developer` dropdown at the top left and select the `Administrator` perspective.
- Then select the `Networking` tab on the left and click on `Routes`
- Click on the route for your newly created application

 ![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/9fc158cefe6895438e983f2c77b615093dccad7b/images/python%20application%20install%203.png)

- From the overview of the application route, copy the `Location` value that contains the address to your demo application.

 ![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/9fc158cefe6895438e983f2c77b615093dccad7b/images/python%20application%20install%204.png)

9) Open the `prometheus-job-blackbox-configuration.yaml` file in your code editor and for the `targets` entry under `static_config` enter the route URL copied in the previous step.

 ![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/9fc158cefe6895438e983f2c77b615093dccad7b/images/blackbox%20configuration%20with%20prometheus%20.png) 
    
10) Next, we need to create a secret that contains our blackbox configuration. Run the following command

```
oc create secret generic blackbox-secret --from-file=prometheus-job-blackbox-configuration.yaml
```

10) Update the Prometheus custom resource in OpenShift by doing the following

- From the OpenShift Console, on the left navigation panel, click on `Operators` and select `Installed Operators`.
- Ensure that you are in the namespace that you set at the beginning.
- Click on the `Prometheus` operator
- Select the tab that says `Prometheus` and click on the `prometheus` resource that appears.
- On the next page, select the tab that says `YAML`
- Add the following lines to that yaml as seen in the image below.

        additionalScrapeConfigs:
            key: prometheus-job-blackbox-configuration.yaml 
            name: blackbox-secret

![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/35203211c705da0439d8133bb16fa7dfae05411f/images/black-box%20configuration%20with%20prometheus.png)

<br />
<br />
<br />


Step3: Configuring Grafana

1) On the left navigation panel, under `Workloads` click on `Secrets`.

1) Find the secret called `grafana-admin-credentials`

1) Scroll down and copy the value for `GF_SECURITY_ADMIN_PASSWORD`

![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_admin_credentials.png)


1) Click on `Networking` on the left navigation panel and select `Routes`.

1) Find the entry for `grafana-route` and click on the url in the `Location` column.

![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_basic_dashboard.png)

=> Create Grafana Dashboard and add datasource in that 

1) Click on `Configuration` on the left navigation panel of grafana dashboard and select `Data Sources` form it.

1) Add `Prometheus` Data Source in Grafana Dashbord in `Configuration` Section

![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/grafana_datasource_configuration.png)


=> Copy Prometheus route 
1) Open `Openshift Dashboard` then after go to `Operator section`.

1) Select `Prometheus` Deployment and Find Deployed `Prometheus` route in `Networking` Section in `Openshift Dashboard`

![alt text](https://github.com/Bhavesh1993/openshift-observability/blob/c468705a5bff6b65d5e5b0ee3c0a8613cdb53180/images/prometheus_route.png)


=> Grafana add data source, here paste prometheus route URL in HTTP section.

1) In `Grafana Dashboard` Openshift Dashboard` then after go to `Operator section`.

1) Select `Prometheus` Deployment and Find Deployed `Prometheus` route in `Networking` Section in `Openshift Dashboard`

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



