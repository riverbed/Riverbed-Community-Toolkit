# 233-containerized-apm-with-java-app-on-gke

In this cookbook a Java web app ([Spring PetClinic](https://github.com/spring-projects/spring-petclinic)) is containerized with the Aternity APM Java library, and deployed along with a [PostgreSQL](https://www.postgresql.org) database on the Linux node pool of a [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).

With this setup, the pods and nodes of the Kubernetes cluster can scaleout, the [Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) will collect every transaction.

## Prerequisites

1. a SaaS account for [Aternity APM](https://www.riverbed.com/products/application-performance-monitoring)

2. a project in [Google Cloud](https://console.cloud.google.com) configured for billing and having Kubernetes setup (Linux node pool and Artifact registry)

3. Click on the button to open the cookbook in the Google Cloud Shell

[![Open in Cloud Shell](https://www.gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/Aternity/Tech-Community&tutorial=233-containerized-apm-with-java-app-on-gke/README.md)

## Step 1. Get Aternity APM details

In the Aternity APM webconsole, navigate to CONFIGURE > AGENTS > Install Agents and in the Agent Installation Steps section,

1. Find your **Customer Id**, for example *12341234-12341234-13241234*
2. Find the **SaaS Analysis Server Host** and obtain the **SaaS Psockets Server host** replacing *agents* by *psockets*. For example if the analysis server host is *agents.apm.my_environment.aternity.com* then the SaaS Psockets Server host is *psockets.apm.my_environment.aternity.com*
3. Download the **Aternity APM Java agent library for Linux** package or contact [Riverbed support](https://support.riverbed.com/) to obtain a copy, for example *aternity-apm-jida-linux-12.18.0_BL546.zip*

## Step 2. Prepare Google Cloud infrastructure

In the [Google Cloud Console](https://console.cloud.google.com) retrieve the details of the project and resources ready to use:

1. Project id, for example: *aternity-cookbooks*
2. Kubernetes Engine cluster name, for example: *autopilot-cluster-1*
3. Region, for example: *europe-west9*
4. Artifact Registry repository name, for example: *aternity-apm*

## Step 3. Store the Aternity APM package in a Bucket Storage

In the [Google Cloud Console](https://console.cloud.google.com), navigate to the [Cloud Storage ](https://console.cloud.google.com/storage/browser). Select the GCP project and create a Bucket with with Docker format and pick the same region as the Kubernetes cluster.

There, upload the package of the Aternity APM Java agent library for Linux (.zip file) and grab the **gsutil URI** for the next steps, for example *gs://my_bucket/aternity-apm-jida-linux-12.18.0_BL546.zip*

## Step 4.Containerize Aternity APM Java agent with the app

1. In the Cloud Shell terminal, run the commands to go to the cookbook folder, select the project (replacing {PROJECT_ID} with the actual value) and configure kubectl to control the cluster

```shell
cd 233-containerized-apm-with-java-app-on-gke
gcloud config set project {PROJECT_ID}
gcloud container clusters get-credentials {CLUSTER NAME} --region {REGION}--project {PROJECT_ID}
```

For example

```shell
cd 233-containerized-apm-with-java-app-on-gke
gcloud config set project aternity-cookbooks
gcloud container clusters get-credentials autopilot-cluster-1 --region europe-west9 --project aternity-cookbook
```

2. Run the command to build the image, replacing the actual values in the substitutions parameter.

```shell
gcloud builds submit --config cloudbuild.yaml --substitutions _APM_PACKAGE_GSUTIL_URI={_APM_PACKAGE_GSUTIL_URI},_REGION={_REGION},_REPOSITORY={REPOSITORY}
```
Where:

   - **{_APM_PACKAGE_GSUTIL_URI}**: the gsutil URI of the package of the Aternity APM Java library package
   - **{_REGION}**: the region of the Artifact Registry
   - **{_REPOSITORY}**: the name of the Artifact Registry repository

For example

```shell
gcloud builds submit --config cloudbuild.yaml --substitutions _APM_PACKAGE_GSUTIL_URI=gs://my_bucket/aternity-apm-jida-linux-12.18.0_BL546.zip,_REGION=europe-west9,_REPOSITORY=aternity-apm
```

Based on the [Dockerfile](Dockerfile), it is building a Docker image that will contain the Java application and the Aternity APM Java agent library for Linux. When the build is done, the image will be stored in the Artifact Registry.

## Step 5. Configure the Kubernetes manifest and deploy

1. With the Cloud Shell Editor, edit the Kubernetes manifest [app-k8s.yaml](app-k8s.yaml) to configure the environment variables of your Aternity APM SaaS account and also the path of the image we just built:

- **Customer Id** in the variable RVBD_CUSTOMER_ID, for example *12341234-12341234-13241234*
- **SaaS Psockets Server host** in the variable RVBD_ANALYSIS_SERVER, for example *psockets.my_environment.aternity.com*
- **Image Path** in the deployment section replacing the token {cookbook-233 image}, for example: *europe-west9-docker.pkg.dev/aternity-cookbooks/aternity-apm/cookbook-233:latest*

2. In the Cloud Shell Terminal, execute the following commands to deploy the application on Kubernetes and then show the external ip address of the load-balancer of the app

```shell
kubectl apply -f app_k8s.yaml
kubectl --namespace cookbook-233 get svc
```

## Step 6. Navigate on the app

In your web browser, open the http url using the external IP address, for example http://external-ip-address, and navigate in the app to generate some traffic and application transactions.

## Step 7. Aternity APM webconsole 

Go to the Aternity APM webconsole to observe the application with every transaction and every instance.

## Cleanup

Run the command to delete the application

```shell
kubectl delete -f app_k8s.yaml
```

#### License

Copyright (c) 2022 Riverbed

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
