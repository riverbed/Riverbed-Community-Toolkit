# Magic Sample

The [Magic Sample](Magic%20Sample.json) runbook is an AIOps automation that can be attached to any Aternity ISD Alert.
When triggered it diagnoses the end-user endpoint and then creates a ticket in a 3rd party ITSM (e.g. ServiceNow). 

## Prerequisistes

1. ISD Alert feature is enabled (Aternity EUEM > Configuration > Alerts)

2. ServiceNow integration is installed and the connector is configured (IQ > Integration Library)

3. GenAI feature are enabled

## Quick Setup

After downloading the [runbook file](Magic%20Sample.json), go to IQ Automation, import the runbook in the External Runbooks and proceed with the following configuration steps:

1. Edit the runbook and set the user-defined variables: the name of Aternity environment (domain name) in the variable EUE_ENV (for example: your-env) and 
the account id in the variable EUE_ACCOUNT_ID (for example: 365)

2. Edit both "ServiceNow" nodes (create and update ticket), set the ServiceNow connector to use your own you configured in the Integration Library (for example: your-itsm)

4. Save the runbook toggling on "Allow Automation" to make the runbook available in the Aternity ISD Alerts configuration page

Then in the Aternity Alerts page, you can edit an existing or create a new Alert Rule. And in the Actions section, you can select the runbook from the drop-down.

### License

Copyright (c) 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.