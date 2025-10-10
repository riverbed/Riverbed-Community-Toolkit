# Riverbed IQ Assist for ServiceNow - Incident - Bring Your Own GenAI - Custom Diagnose User Endpoint - Mistral AI

The runbook [Riverbed IQ Assist for ServiceNow - Incident - Bring Your Own GenAI and Diagnose User Endpoint](./Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Custom%20Diagnose%20User%20Endpoint.json) works with the Riverbed IQ Assist app in ServiceNow. When triggered it will enrich the incident with a diagnosis of the user endpoint.

This runbook uses your own GenAI service, provided by Mistral AI, and can be customized.

> [! Tip]
> The runbook can also be adapted to use other GenAI/LLM services, such as those available in the Integration Library (e.g., Gemini, AWS Bedrock).

## Prerequisites

Ensure the following are in place before proceeding:

1. **Riverbed IQ Assist for ServiceNow** is installed in your ServiceNow instance ([open ServiceNow Store](https://store.servicenow.com/sn_appstore_store.do#!/store/search?q=Riverbed)).

2. **Riverbed IQ Assist** is enabled:
   - Navigate to **IQ > Administration > Riverbed IQ Assist Configuration**.
   - Ensure the integration is installed via **IQ > Integration Library**.

3. Aternity integration on Riverbed IQ is installed.

4. ServiceNow integration is installed (IQ > Integration Library).

5. **Mistral AI integration** is configured to your own account (IQ > Integration Library).


## Quick Setup

Follow these steps to set up the runbook:

1. Download the file of the [runbook](./Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Bring%20Your%20Own%20GenAI%20and%20Diagnose%20User%20Endpoint%20-%20Mistral%20AI.json)

2. in **IQ**, go to **Automation > External Runbooks**

3. Import the runbook

4. Toggle **Allow Automation** to 'On'

5. For customization, edit the runbook and see the notes in the Runbook

### License

Copyright (c) 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
