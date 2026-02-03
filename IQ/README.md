# Riverbed-Community-Toolkit - IQ Ops

This folder contains cookbooks and samples to be used when building Agents and Runbooks for Automation with the Riverbed Platform.

> [!NOTE]
> * To use runbooks below you need active licenses of the Riverbed Products. Please visit the website of Riverbed for more information about the [Riverbed Platform](https://www.riverbed.com/platform)
> * For help about Riverbed IQ, please refer to the [help page](https://help.cloud.riverbed.com/) 

## Quick start

## Agents cookbooks with Riverbed IQ Assist

| Agent | Description | Tags | Last update |
| --- | --- | --- | --- |
| Copilot IT Self-Service | [More details](Agents/101-Copilot-IT-SelfService) | Microsoft Copilot | Jan. 2026 |
| Riverbed IQ Assist for ServiceNow | [More details](Agents/101-riverbed-iq-assist-for-servicenow) | ServiceNow, SOW | Feb. 2026 |


## Automation runbooks

You can download the Runbook files from the tables below and import them into your Riverbed IQ account. 

1. Choose a runbook in the table below. There are different runbook types: Incident Runbooks, Lifecyle Runbook, On-Demand Runbooks, External Runbooks or Subflows

2. Follow the download link and click **Download raw file** to get the runbook file (.json).

3. In **Riverbed IQ Ops**, open the Menu, go to Automation, select the runbook type and import the runbook

### External Runbooks

| Runbook | File | Description | Tags | Last update |
| --- | --- | --- | --- | --- |
| Riverbed IQ Assist for ServiceNow - Incident - Quick Start | [Download](Automation/External%20Runbooks/100-riverbed-iq-assist-for-servicenow-incident-quickstart/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Quick%20Start.json) | [More details](Automation/External%20Runbooks/100-riverbed-iq-assist-for-servicenow-incident-quickstart) | AIOps, Aternity EUEM, ITSM, ServiceNow | Oct. 2025 |
| Riverbed IQ Assist for ServiceNow - Incident - Diagnose User Endpoint | [Download](Automation/External%20Runbooks/101-riverbed-iq-assist-for-servicenow-incident-diagnose-user-endpoint/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Diagnose%20User%20Endpoint.json) | [More details](Automation/External%20Runbooks/101-riverbed-iq-assist-for-servicenow-incident-diagnose-user-endpoint/) | AIOps, Aternity EUEM, NPM+, GenAI, ITSM, ServiceNow | Oct. 2025 |
| Riverbed IQ Assist for ServiceNow - Incident - Fetch User Endpoint Metrics | [Download](Automation/External%20Runbooks/102-riverbed-iq-assist-for-servicenow-incident-fetch-user-endpoint-metrics/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Fetch%20User%20Endpoint%20Metrics.json) | [More details](Automation/External%20Runbooks/102-riverbed-iq-assist-for-servicenow-incident-fetch-user-endpoint-metrics/) | AIOps, Aternity EUEM, NPM+, ITSM, ServiceNow | Oct. 2025 |
| Riverbed IQ Assist for ServiceNow - Incident - Custom Diagnose User Endpoint | [Download](Automation/External%20Runbooks/103-riverbed-iq-assist-for-servicenow-incident-custom-diagnose-user-endpoint/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Custom%20Diagnose%20User%20Endpoint.json), [Example](Automation/External%20Runbooks/103-riverbed-iq-assist-for-servicenow-incident-custom-diagnose-user-endpoint/examples/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Custom%20Diagnose%20User%20Endpoint%20-%20EUEM%20only.json) | [More details](Automation/External%20Runbooks/103-riverbed-iq-assist-for-servicenow-incident-custom-diagnose-user-endpoint/) | AIOps, Aternity EUEM, NPM+, ITSM, ServiceNow | Oct. 2025 |
| Riverbed IQ Assist for ServiceNow - Incident - Bring Your Own GenAI - Custom Diagnose User Endpoint | [Download](Automation/External%20Runbooks/104-riverbed-iq-assist-for-servicenow-incident-bring-your-own-genai-custom-diagnose-user-endpoint-mistral-ai/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Bring%20Your%20Own%20GenAI%20and%20Diagnose%20User%20Endpoint%20-%20Mistral%20AI.json) | [More details](Automation/External%20Runbooks/104-riverbed-iq-assist-for-servicenow-incident-bring-your-own-genai-custom-diagnose-user-endpoint-mistral-ai/) | AIOps, Aternity EUEM, NPM+, ITSM, ServiceNow, BYO LLM, Mistral AI | Oct. 2025 |
| Riverbed IQ Assist for ServiceNow - Incident - Caller Endpoint Diagnostic | [Download](Automation/External%20Runbooks/105-riverbed-iq-assist-for-servicenow-incident-caller-endpoint-diagnostic/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Caller%20Endpoint%20Diagnostic.json) | [More details](Automation/External%20Runbooks/105-riverbed-iq-assist-for-servicenow-incident-caller-endpoint-diagnostic/) | AIOps, Aternity EUEM, NPM+, ITSM, ServiceNow | Oct. 2025 |
| Riverbed IQ Assist for ServiceNow - Incident - Find Caller Endpoint | [Download](Automation/External%20Runbooks/106-riverbed-iq-assist-for-servicenow-incident-find-caller-endpoint/Riverbed%20IQ%20Assist%20for%20ServiceNow%20-%20Incident%20-%20Find%20Caller%20Endpoint.json) | [More details](Automation/External%20Runbooks/106-riverbed-iq-assist-for-servicenow-incident-find-caller-endpoint/) | AIOps, Aternity EUEM, NPM+, ITSM, ServiceNow | Oct. 2025 |
| Demo - IQ Assist - Create ITSM ticket with Endpoint Diagnosis | [Download](Automation/External%20Runbooks/200-riverbed-iq-assist-isd-endpoint-diagnosis/Demo%20-%20IQ%20Assist%20-%20Create%20ITSM%20ticket%20with%20Endpoint%20Diagnosis.json) | [More details](Automation/External%20Runbooks/200-riverbed-iq-assist-isd-endpoint-diagnosis) | AIOps, Aternity EUEM, ISD, ITSM | Oct. 2025 |
| ISD Create Freshservice Ticket | [Download](Automation/External%20Runbooks/isd-create-freshservice-ticket/isd-create-freshservice-ticket.json) | [More details](Automation/External%20Runbooks/isd-create-freshservice-ticket) | AIOps, Aternity EUEM, ISD, ITSM | Aug 2025 |

### Subflows

| Subflow | File | Description | Tags | Last update |
| --- | --- | --- | --- | --- |
| Check Current Time in Range | [Download](Automation/Subflows/Check%20Current%20Time%20in%20Range/Check%20Current%20Time%20in%20Range.txt) | [More details](Automation/Subflows/Check%20Current%20Time%20in%20Range) | AIOps, IQ | Jan 2025 |

### On-Demand Runbooks

| Runbook | File | Description | Tags | Last update |
| --- | --- | --- | --- | --- |
| Riverbed IQ Assist - Suggest Remediation | [Download](Automation/On-Demand%20Runbooks/101-riverbed-iq-assist-suggest-remediation/Riverbed%20IQ%20Assist%20-%20Diagnostic%20and%20Remediation%20Suggestion%20for%20User%20Endpoint.json) | [More details](Automation/On-Demand%20Runbooks/101-riverbed-iq-assist-suggest-remediation) | AIOps, Remediation | June 2025 |
| Sync Device Group from Intune to Unified Agent | [Download](Automation/On-Demand%20Runbooks/102-sync-device-group-from-intune-to-unified-agent/Demo%20-%20Sync%20Device%20Group%20from%20Intune%20to%20Unified%20Agent.json) | [More details](Automation/On-Demand%20Runbooks/102-sync-device-group-from-intune-to-unified-agent) | Device Management, Intune | June 2025 |
| User Device Teams Calls | [Download](Automation/On-Demand%20Runbooks/103-user-device-teams-calls/User%20Device%20Teams%20Calls.json) | [More details](Automation/On-Demand%20Runbooks/103-user-device-teams-calls) | Teams, Collaboration | June 2025 |

### More runbooks

Other Runbooks for other Runbooks types are in preparation.

*Incident Runbooks*

*Lifecycle Runbooks*


### License

Copyright (c) 2025 - 2026 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
