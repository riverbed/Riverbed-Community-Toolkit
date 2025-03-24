# Cookbook 101-apm-collector-with-docker-compose

On a machine with a docker host, you can deploy the [APM OpenTelemetry Collector container](https://hub.docker.com/r/aternity/apm-collector) of the [Riverbed Platform](https://www.riverbed.com/platform) using a simple compose file.

## Prerequisites

1. a Riverbed APM account (SaaS)
2. a Docker host, for example [Docker Desktop](https://www.docker.com/products/docker-desktop)

## Step by Step

### Step 1. Get your CustomerID & SaaS Analysis Server Host details from the APM web console

Navigate to the APM console (for example [https://apm.myaccount.aternity.com](https://apm.myaccount.aternity.com)) > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*

Those information are required to activate the APM OpenTelemetry Collector container, passing via the environment variable `SERVER_URL`. 

### Step 2. Configure container with the info of the APM account

Configure the environment variables for the APM OpenTelemetry Collector

```bash
# Configure the environment variables for the APM OpenTelemetry Collector
export RIVERBED_APM_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com"
export RIVERBED_APM_CUSTOMER_ID="12341234-12341234-13241234"
```
or with PowerShell:

```PowerShell
# Configure the environement variable for the APM OpenTelemetry Collector
$env:RIVERBED_APM_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com"
$env:RIVERBED_APM_CUSTOMER_ID="12341234-12341234-13241234"
```

### Step 3. Start the container

Start using the [compose.yaml](compose.yaml), for example with Bash:

```bash
cd Riverbed-Community-Toolkit/APM/101-apm-collector-with-docker-compose
docker compose up
```

## Notes

### Stop the app and all the containers

Press CTRL + C in the shell where it is running.

Or in a shell, go to the folder where you keep the [compose.yaml](compose.yaml) and run:

```shell
docker compose down
```

#### License

Copyright (c) 2022-2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
