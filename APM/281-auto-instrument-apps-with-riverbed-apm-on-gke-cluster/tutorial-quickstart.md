# Riverbed Community Toolkit Cookbook

<walkthrough-tutorial-duration duration="25"></walkthrough-tutorial-duration>

Welcome! This **Quickstart Tutorial** is part of the cookbook `281-auto-instrument-apps-with-riverbed-apm-on-gke-cluster` 
of the [Riverbed Community Toolkit](https://github.com/riverbed/Riverbed-Community-Toolkit)

You will deploy the [Riverbed Operator](https://github.com/riverbed/riverbed-operator) on your  Kubernetes cluster on Google GKE, and enable APM auto-instrumentation with .NET apps.

> If you are not already in Google Cloud Shell, click on the following button to open Google Cloud Shell:
> [![Open in Google Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/riverbed/Riverbed-Community-Toolkit&tutorial=APM/281-auto-instrument-apps-with-riverbed-apm-on-gke-cluster/tutorial-quickstart.md)

## Summary

**Prerequisites**

1. an account on [GCP](https://cloud.google.com) with a Standard GKE cluster

2. Riverbed APM (Riverbed Platform)

**Overview of the next steps**

1. Connect to your GKE cluster
2. Requirements for Riverbed Operator
3. Riverbed APM account details
4. Riverbed Operator installation
5. Riverbed Operator configuration
6. Enable Auto-Instrumentation
7. Deploy a workload
8. Observe transactions with Riverbed APM


## Step 1. Connect to your GKE cluster

<walkthrough-tutorial-duration duration="2"></walkthrough-tutorial-duration>

### Set the current folder

Go the folder of the cookbook 281

```sh
cd APM/281-auto-instrument-apps-with-riverbed-apm-on-gke-cluster
```

### Set the active project

Run the following command to set the active project, replacing `<PROJECT_ID>` with your actual project ID:

```sh
gcloud config set project <PROJECT_ID>
```

>Example:
>```sh
>gcloud config set project your-riverbed-cookbooks-1354
>```

### Connect to your GKE cluster

Run the following command to connect your GKE, supplying `--zone <ZONE>` or `--region <REGION>` and replacing placeholders and `<CLUSTER_NAME>` with actual values:

```sh
gcloud container clusters get-credentials <CLUSTER_NAME> --zone <ZONE> 
```

> Example:
>```sh
>gcloud container clusters get-credentials your-standard-cluster --zone europe-west9-a 
>```

## Step 2. Requirements for Riverbed Operator

<walkthrough-tutorial-duration duration="3"></walkthrough-tutorial-duration>

### cert-manager

If not already installed in your cluster, use the following command to install it (refer to [docs](https://cert-manager.io/docs/reference/cmctl/#installation) for more details). 

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml

sleep 120
```

Note that it takes about two minutes for cert-manager to be ready.

Terminal output sample:
```terminal
namespace/cert-manager created
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
...
```

## Step 3. Riverbed APM account details

<walkthrough-tutorial-duration duration="1"></walkthrough-tutorial-duration>

### Open the Riverbed APM web console

Open the Riverbed APM web console in a new browser tab. For example the URL looks like this for SaaS accounts: [https://apm.your-env.aternity.com](https://apm.your-env.aternity.com)

### Account details

Navigate to the **CONFIGURE** menu (gear icon), open  **Install Agents**.

In the **Agent Install Steps** section

* Select the **LINUX** tab
* Switch to  **Standard Agent Installation**

Grab the account details that will be used in the next steps:

1. **Customer Id**. Example of a SaaS account (empty for non-SaaS accounts): *1234-121234-123*

2. **Analysis Server Host**. Example of a SaaS account *agents.apm.your_env.aternity.com*

## Step 4. Riverbed Operator installation

<walkthrough-tutorial-duration duration="2"></walkthrough-tutorial-duration>

Run the following command to deploy the latest version of the Riverbed Operator:

```bash
kubectl apply -f https://github.com/riverbed/riverbed-operator/releases/latest/download/riverbed-operator.yaml
```

Terminal output sample:
```terminal
namespace/riverbed-operator created
customresourcedefinition.apiextensions.k8s.io/riverbedoperators.operator.riverbed created
serviceaccount/riverbed-operator-controller-manager created
...
```

## Step 5. Riverbed Operator configuration

<walkthrough-tutorial-duration duration="4"></walkthrough-tutorial-duration>

### Download the configuration template

Use the following command to download the latest configuration manifest from the Riverbed Operator GitHub release:

```bash
wget https://github.com/riverbed/riverbed-operator/releases/latest/download/riverbed_configuration.yaml
```

### Edit the Configuration File

Open the downloaded file  <walkthrough-editor-open-file filePath="riverbed_configuration.yaml">riverbed_configuration.yaml</walkthrough-editor-open-file>

Locate the lines with **customerId** and **analysisServerHost**, and replace the placeholder with your actual **Customer ID** and **Analysis Server Host** values obtained in Step 1:

For example:

```yaml
# If this is a SaaS analysis server, use the Customer Id from the Install Agents, Standard Agent Installation.
# If this is an on-prem analysis server, Leave the customerId as an empty string.
  customerId: 1234-121234-123

# If this is a SaaS analysis server, use the SaaSAnalysisServerHost from the Install Agents, Standard Agent Installation
# If on-prem, use the analysis server address as you would on an agent installation.
  analysisServerHost: agents.apm.your_env.aternity.com
...
```

### Apply the configuration

Run the following command to apply the configuration:

```bash
kubectl apply -f riverbed_configuration.yaml
```

Terminal output sample:
```terminal
riverbedoperator.operator.riverbed/riverbed-apm-agent created
```

For more details on how to deploy the Riverbed Operator, refer to the [Riverbed Operator page](https://github.com/riverbed/riverbed-operator)

### Quick check

You can verify that the Pods of the Riverbed Operator are running (in the `riverbed-operator` namespace)

```bash
kubectl get pod -n riverbed-operator
```

Terminal output sample (example of a cluster having few nodes)
```terminal
NAME                                                    READY   STATUS    RESTARTS   AGE
riverbed-apm-agent-rkhlk                                1/1     Running   0          78s
riverbed-apm-agent-zzwcb                                1/1     Running   0          78s
...
riverbed-operator-controller-manager-78874b995f-cdw2t   1/1     Running   0          6m25s
```

## Step 6. Enable Auto-Instrumentation

<walkthrough-tutorial-duration duration="2"></walkthrough-tutorial-duration>

### Auto-Instrumentation

The auto-instrumentation can be enabled by annotating at the namespace level, so that the Riverbed Operator will automatically instrument every pod with Riverbed APM. You can review the configuration in the file <walkthrough-editor-open-file filePath="cookbook-auto-instrument-namespace-k8s.yaml">cookbook-auto-instrument-namespace-k8s.yaml</walkthrough-editor-open-file>, and also refer to the [Riverbed Operator page](https://github.com/riverbed/riverbed-operator) for more details.

The following command will create the namespace `cookbook-services` and enable auto-instrumentation for .NET 

```bash
kubectl apply -f cookbook-auto-instrument-namespace-k8s.yaml
```

## Step 7. Deploy a workload

<walkthrough-tutorial-duration duration="3"></walkthrough-tutorial-duration>

### Deploy .NET services

Apply the manifest of the app, that will deploy a few .NET services and expose an http endpoint (using a Load Balancer). 

```bash
kubectl apply -f cookbook-dotnet-services-k8s.yaml
```

### Find the External IP address of the endpoint

To find the external ip address, run the following command. It can take a few minutes before the EXTERNAL-IP is assigned and gets displayed.

```bash
kubectl get service -n cookbook-services a-service-dotnet
```

Terminal output sample:

```terminal
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)          AGE
a-service-dotnet   LoadBalancer   10.10.10.5       1.2.3.4          8080:32251/TCP   10m36s
```

## Step 8. Observe transactions with Riverbed APM

<walkthrough-tutorial-duration duration="5"></walkthrough-tutorial-duration>

### Generate transactions

In a new tab in your web browser, try to navigate to the URL of app, replacing `<EXTERNAL-IP>` with the actual value. Retry few times to generate some application transactions that will be recorded in Riverbed APM.

```
http://<EXTERNAL-IP>/call-sync
```

### Observe transactions

Go to the Riverbed APM web console and find the generated transactions


## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Congrats the tutorial is done!

## Notes

### How to try with a Java app?

The following will deploy a simple Java application in a new Kubernetes namespace: `cookbook-app`. The APM auto-instrumentation annotation is set at the deployment level, so that it will be automatically instrumented.

- Deploy

```bash
kubectl apply -f https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/refs/heads/master/APM/281-auto-instrument-apps-with-riverbed-apm-on-gke-cluster/cookbook-java-service-k8s.yaml
```

- Check the EXTERNAL-IP of the Java App

```bash
kubectl get service -n cookbook-app
```

- Navigate on the url to generate some traffic. Every transaction will be recorded in Riverbed APM.

```
http://<EXTERNAL-IP Java App>
```

- Cleanup the namespace

```bash 
kubectl delete namespace cookbook-app
```


#### How to clean-up the cookbook demo workloads

Run the following command to delete workloads:

```bash 
kubectl delete namespace cookbook-services
```

#### How to clean-up the operator

Run the following command to delete the Riverbed Operator:

```bash
kubectl delete -f https://github.com/riverbed/riverbed-operator/releases/latest/download/riverbed-operator.yaml
```

#### Learn more about Riverbed APM

Go to the [Riverbed Operator page](https://github.com/riverbed/riverbed-operator)

#### License

Copyright (c) 2024 - 2025 Riverbed

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
