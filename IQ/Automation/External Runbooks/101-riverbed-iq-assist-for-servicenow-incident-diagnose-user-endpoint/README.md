# Riverbed IQ Assist for ServiceNow - Incident - Diagnose User Endpoint

The runbook [Riverbed IQ Assist for ServiceNow - Incident - Diagnose User Endpoint](./Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Diagnose%20User%20Endpoint.json) can be used as-is for Incidents assistance with Riverbed IQ Assist for ServiceNow.

When triggered from ServiceNow, the runbook diagnoses the user’s endpoint and enriches the incident ticket.

## Prerequisites

1. ServiceNow:
  - [Riverbed IQ Assist for ServiceNow](https://store.servicenow.com/sn_appstore_store.do#!/store/search?q=Riverbed) is installed from the ServiceNow Store.

2. Riverbed AIOps:
  - Riverbed IQ Assist opt-in is enabled (IQ > Administration > Riverbed IQ Assist configuration) and the integration is configured (IQ > Integration Library).
  - Aternity integration is installed and configured (IQ > Integration Library)
  - ServiceNow integration is installed and configured (IQ > Integration Library)

## CI Setup

In this setup, Riverbed IQ Assist uses the associated Configuration Item (CI) to identify the User Endpoint. 

1. Download the runbook file: [Riverbed IQ Assist for ServiceNow - Incident - Diagnose User Endpoint](./Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Diagnose%20User%20Endpoint.json).
2. In IQ, go to Automation > External Runbooks and import the JSON.
3. Open the imported runbook and enable "Allow Automation"

## Custom Field Setup

In this setup, Riverbed IQ Assist will extract a custom field of the Incident record that contain the User Endpoint to analyse.

1. Download the custom runbook: [Riverbed IQ Assist for ServiceNow - Incident - Diagnose User Endpoint](./Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Diagnose%20User%20Endpoint%20from%20Incident%20Custom%20Field.json).
2. In IQ, go to Automation > External Runbooks and import the JSON.
3. Open the imported runbook and enable "Allow Automation"

## Other Setup

You can customize the setup to leverage other Riverbed IQ Assist skills. For example, the [runbook 105](../105-riverbed-iq-assist-for-servicenow-incident-caller-endpoint-diagnostic/) uses a skill to find the user endpoint.


### License

Copyright (c) 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
