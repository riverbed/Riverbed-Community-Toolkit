# 111-opentelemetry-autoinstrumentation-spring-demo-app

This cookbook demonstrates how the [Riverbed APM](https://www.riverbed.com/products/application-performance-monitoring) provides observability of a Java application using [OpenTelemetry](https://opentelemetry.io/) auto-instrumentation.

To instrument the Java Spring Boot demo app ([Spring PetClinic](https://github.com/spring-projects/spring-petclinic)), the OpenTelemetry Java agent will be containerized with the app (the .jar file is copied into the image) and injected in the app at startup. The agent will be configured to export the tracing to the APM SaaS backend via the [APM OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) that will run in an another container.

![diagram](images/111-diagram.png)

## Prerequisites

1. an account in APM (SaaS)
2. a Docker host, for example [Docker Desktop](https://www.docker.com/products/docker-desktop)

## Step by step

### Step 1 - Connect to APM web console

Navigate to APM (for example [https://apm.myaccount.aternity.com](https://apm.myaccount.aternity.com)) > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab the **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*

### Step 2 - Get the files to run the Cookbook

Download the cookbook, for example [right-click here](https://github.com/riverbed/Riverbed-Community-Toolkit/archive/refs/heads/master.zip) to download the zip archive, and expand it locally.

### Step 3 - Start the containers

Open a shell and go to the Cookbook folder. Configure the APM OpenTelemetry Collector using the environment variables, RIVERBED_APM_SAAS_SERVER_HOST and RIVERBED_APM_CUSTOMER_ID, and start all the containers with docker-compose.

For example using Bash:

```bash
# Go to the directory that contains the cookbook
cd Riverbed-Community-Toolkit/APM/111-opentelemetry-autoinstrumentation-spring-demo-app

# Configure the environment variables for the APM OpenTelemetry Collector
export RIVERBED_APM_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com"
export RIVERBED_APM_CUSTOMER_ID="12341234-12341234-13241234"

# Start the containers
docker-compose up
```
or else using PowerShell:

```PowerShell
# Go to the directory that contains the cookbook
cd Riverbed-Community-Toolkit\APM\111-opentelemetry-autoinstrumentation-spring-demo-app

# Configure the environement variable for the APM OpenTelemetry Collector
$env:RIVERBED_APM_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com"
$env:RIVERBED_APM_CUSTOMER_ID="12341234-12341234-13241234"

# Start the containers
docker-compose up
```

### Step 4 - Navigate through the app and monitor

Open the url http://localhost:8080 in the web browser and navigate through the app.

The APM collects the telemetry the java agent is sending. Every transaction and every OpenTelemetry span can be found in the Search tab.

![APM OpenTelemetry traces](images/alluvio-aternity-opentelemetry-service111-java-transactions.png)

## Notes 

### Stop the app and all the containers

Press CTRL + C in the shell where it is running.

Or in a shell, go to the folder where you keep the [docker-compose.yaml](docker-compose.yaml) and run:

```shell
docker-compose down
```

#### License

Copyright (c) 2022-2024 Riverbed Technology, Inc. 

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
