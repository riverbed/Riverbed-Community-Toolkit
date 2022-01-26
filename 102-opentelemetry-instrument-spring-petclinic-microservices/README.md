# 102-instrument-spring-petclinic-microservices

This cookbook helps to setup a simple Java microservices application on a Docker host with the [Aternity APM collector](https://hub.docker.com/r/aternity/apm-collector), to start practicing Digital Experience Monitoring (DEM) with [Aternity APM](https://www.aternity.com/application-performance-monitoring/).

## Prerequisites

1. an Aternity APM account
2. a Docker host

## Step by Step

### Connect to Aternity APM webconsole

Navigate to Aternity APM > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*

### Build the `spring-petclinit-microservices` app

```
% git submodule update
% cd spring-petclinic-microservices/
% ./mvnw clean install -P buildDocker
% cd ../
```

### Configure `docker-compose` with your CustomerID & SaaS Analysis Server Host

Edit `docker-compose.yml` replacing the following fields with the information from step [1]:
1. `<customerId>`
2. `<SaaSAnalysisServerHost>` 

### Start the application

Note: Make sure you are in the same directory as this README
```
% docker-compose up
```

### Exercise the application

Go to http://localhost:8080 and click around.

### View your generated transactions in the Aternity APM webconsole

### Stop the application

```
% docker-compose down
```

Please visit [Aternity](https://www.aternity.com/) if your need Support or Training.

#### License
Copyright (c) 2022 Aternity. The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
