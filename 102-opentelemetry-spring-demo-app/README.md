# 102-opentelemetry-spring-demo-app

This cookbook helps to setup Java microservices application on a Docker host with the [Aternity APM OpenTelemetry collector container](https://hub.docker.com/r/aternity/apm-collector), to start practicing Digital Experience Monitoring (DEM) with [Aternity APM](https://www.aternity.com/application-performance-monitoring/) and [OpenTelemetry](https://opentelemetry.io/).

The sample app is a famous Java Community application called [Spring PetClinic](https://github.com/spring-petclinic). It is using [ZipKin](https://zipkin.io/) instrumentation and libraries.

## Prerequisites

1. an Aternity APM account
2. a Docker host

## Step by Step

### Connect to Aternity APM webconsole

Navigate to Aternity APM > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*

### Fetch the code

For example using git from a shell:

```shell
git clone https://github.com/Aternity/Tech-Community.git
```

Or download the zip archive of the [Aternity Tech-Community repository](https://github.com/Aternity/Tech-Community) from GitHub (Code button > Download ZIP).

### Configure the Aternity OpenTelemetry Collector with your CustomerID & SaaS Analysis Server Host

Go to the directory `Tech-Community directory` and `102-opentelemetry-spring-demo-app`.

Edit the [docker-compose.yml](docker-compose.yml) file

In the tracing-server section, replace the following tokens with the information from step [1] and save:
1. `<customerId>` 
2. `<SaaSAnalysisServerHost>` 

### Start the `spring-petclinit-microservices` app instrumented with OpenTelemetry

In your shell, go to the cookbook directory:

```shell
cd Tech-Community/102-opentelemetry-spring-demo-app
```

Sart the containers:

```shell
docker-compose up
```

### Exercise the application

Go to http://localhost:8080 and click around. 

### Connect to the Aternity APM webconsole to analyze evethe OpenTelemetry transactions

Navigate to your Aternity APM url, for example [https://apm.myaccount.aternity.com](https://apm.myaccount.aternity.com)

Please visit [Aternity](https://www.aternity.com/) if your need Support or Training.

### Stop the application

```shell
docker-compose down
```

#### License

Copyright (c) 2022 Aternity. The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
