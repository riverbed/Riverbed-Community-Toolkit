# 106-opentelemetry-autoinstrumentation-java-app

A simple Java application is launched with [OpenTelemetry](https://opentelemetry.io/) automatic instrumentation. The OpenTelemetry instrumentation is configured with multiple telemetry exporters. In parallel it is logging telemetry on the console, exporting to a local [jaeger](https://www.jaegertracing.io), and also exporting to the Aternity APM SaaS backend via the [Aternity APM OpenTelemetry collector container](https://hub.docker.com/r/aternity/apm-collector).

For this cookbook the [Aternity APM OpenTelemetry collector container](https://hub.docker.com/r/aternity/apm-collector) is configured to receive OTLP-gRPC but it also supports OTLP-http, jaeger and even zipkin telemetry.

![diagram](images/106-diagram.png)

## Prerequisites

1. an Aternity APM account (SaaS)
2. a Docker host, for example [Docker Desktop](https://www.docker.com/products/docker-desktop)

## Step by step

### Step 1 - Connect to Aternity APM webconsole

Navigate to Aternity APM (for example [https://apm.myaccount.aternity.com](https://apm.myaccount.aternity.com)) > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*

### Step 2 - Get the sources

Download the sources, for example [right-click here](https://github.com/Aternity/Tech-Community/archive/refs/heads/main.zip) to download the zip archive, and expand it locally.

Edit the [docker-compose.yaml](docker-compose.yaml) file if you want to manually configure the `SERVER_URL` environment variable of the Aternity APM OpenTelemetry Collector container, replacing *ATERNITY_SAAS_SERVER_HOST* and *ATERNITY_CUSTOMER_ID* with actual values. The remaining is set to pull the Aternity APM OpenTelemetry Collector container image from [DockerHub](https://hub.docker.com/r/aternity/apm-collector) and expose the port 4317 to receive OTLP gRPC telemetry. It looks like this:

```yaml
services:
     
  aternity-opentelemetry-collector:

    image: registry.hub.docker.com/aternity/apm-collector:2022.4.0-4
    
    environment:
    
      SERVER_URL: "wss://${ATERNITY_SAAS_SERVER_HOST}/?RPM_AGENT_CUSTOMER_ID=${ATERNITY_CUSTOMER_ID}"
    
    ports:
    
      - "4317:4317/tcp"
```

The sources of the Java application consists in a single Java file [cookbook106.java](src/main/java/com/aternity/community/cookbook106/cookbook106.java), a standard Maven pom.xlm file, and a Dockerfile to build an image. The build will be done automatically when starting the containers with docker-compose in the next step. 

### Step 3 - Start the containers

In a shell, go to the Cookbook folder, configure the Aternity APM OpenTelemetry Collector using the environment variables, ATERNITY_SAAS_SERVER_HOST and ATERNITY_CUSTOMER_ID, and starts all the containers with docker-compose.

For example using Bash:

```bash
# Go to the directory that contains the cookbook
cd Tech-Community-main\106-opentelemetry-autoinstrumentation-java-app

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

The app simply fetches a page from a url, parses the contents and exits. To generate telemetry, the app container will restart indifinitely.

In Aternity Web console, in the Search tab, the transactions will appear with the instance name "service106-java-otlp"

![Aternity APM OpenTelemetry traces](images/aternity-opentelemetry-service106-java-transactions.png)

## Notes 

### Stop the app and all the containers

Press CTRL + C in the shell where it is running.

Or in a shell, go to the folder where you keep the [docker-compose.yaml](docker-compose.yaml) and run:

```shell
docker-compose down
```

### How to launch myapp.jar with automatic instrumentation and multiple exporters?

Here is a sample in Bash that shows how to run a java app (myapp.jar) with OpenTelemetry automatic instrumentation and multiple exporters: logging on the console, otlp-grpc and jaeger. In this example the jaeger and otlp-grpc OpenTelemetry endpoints are running on the localhost. OpenTelemetry exporters are configured using environment variables. The jar for the automatic instrumentation will be downloaded ([opentelemetry-javaagent.jar](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.12.1/opentelemetry-javaagent.jar)) and injected using the JAVA_TOOL_OPTIONS environment variable.

```bash
# Configure OpenTelemetry instrumentation (OTEL_TRACES_EXPORTER default is "OTLP")
OTEL_SERVICE_NAME="myapp"
OTEL_TRACES_EXPORTER=logging,otlp,jaeger

## OTLP-gRPC
OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

## Jaeger
OTEL_EXPORTER_JAEGER_ENDPOINT="http://localhost:14250"

# Inject OpenTelemetry automatic instrumentation
curl -OL https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.12.1/opentelemetry-javaagent.jar
JAVA_TOOL_OPTIONS="-javaagent:./opentelemetry-javaagent.jar"

# Run the app
java -jar myapp.jar
```

More details about java instrumentation are available on the [OpenTelemetry docs page](https://opentelemetry.io/docs/).

#### License

Copyright (c) 2022 Riverbed Technology, Inc. 

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
