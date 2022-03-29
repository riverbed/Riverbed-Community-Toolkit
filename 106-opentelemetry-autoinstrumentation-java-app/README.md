# 106-opentelemetry-autoinstrumentation-java-app

A simple Java application is launched with OpenTelemetry automatic instrumentation and configured with multiple telemetry exporters to demonstrate at the same time logging on the console, OTLP-gRPC telemetry export to the Aternity APM OpenTelemetry Collector and Jaeger telemetry export


## Prerequisites

1. an Aternity APM account (SaaS)
2. a Docker host, for example [Docker Desktop](https://www.docker.com/products/docker-desktop)

## Step by step

### Step 1 - Connect to Aternity APM webconsole

Navigate to Aternity APM (for example [https://apm.myaccount.aternity.com](https://apm.myaccount.aternity.com)) > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*

### Step 2 - Get the sources

Download the source, for example [right-click here](https://github.com/Aternity/Tech-Community/archive/refs/heads/main.zip) to download zip archive and expand it locally.

### Step 3 - Start the containers

In a shell, go to the Cookbook folder, configure the Aternity APM OpenTelemetry Collector using the environment variables, ATERNITY_SAAS_SERVER_HOST and ATERNITY_CUSTOMER_ID, and starts all the containers with docker-compose.

```bash
# Go to the directory that contains the cookbook
cd Tech-Community\Tech-Community-main\106-opentelemetry-autoinstrumentation-java-app

# Configure the environment variables for the Aternity OpenTelemetry Collector
export ATERNITY_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com"
export ATERNITY_CUSTOMER_ID="12341234-12341234-13241234"

# Start the containers
docker-compose up
```
or else using PowerShell:

```PowerShell
# Go to the directory that contains the cookbook
cd Tech-Community\Tech-Community-main\106-opentelemetry-autoinstrumentation-java-app

# Configure the environement variable for the Aternity OpenTelemetry Collector
$env:ATERNITY_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com"
$env:ATERNITY_CUSTOMER_ID="12341234-12341234-13241234"

# Start the containers
docker-compose up
```

### Step 4 - Open the Aternity APM webconsole to visualize and analyze the traces collected for every transaction

In the Search, transaction will appear with the instance name "service106-java-otlp"
Search transactions 

#### License

Copyright (c) 2022 Riverbed Technology, Inc. 

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
