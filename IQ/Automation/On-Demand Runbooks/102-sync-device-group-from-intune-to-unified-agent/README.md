# Demo - Sync Device Group from Intune to Unified Agent

This is an On-Demand runbook [Demo - Sync Device Group from Intune to Unified Agent](./Demo%20-%20Sync%20Device%20Group%20from%20Intune%20to%20Unified%20Agent.json) for Riverbed IQ. It connects to Intune (EntraID) to fetch the list of devices in a group, and then push them into a target group for Unified Agent.
The runbook can be scheduled the keep both groups in sync.

## Prerequisistes

1. An existing group in Intune (i.e. EntraID), for example: your_intune_group

2. A target group created in Unified Agent, for example: your_group

3. MS Graph integration is configured (IQ > Integration Library)

4. Unified Agent authentication profile is configured
 

## Quick Setup

* Download the [runbook file](./Demo%20-%20Sync%20Device%20Group%20from%20Intune%20to%20Unified%20Agent.json)
* Open Riverbed IQ and go to Automation > On-Demand Runbooks
* Import this runbook, and set the variables for Unified Agent (ENV LMS and ACCOUNT_ID), and then save the runbook
* Run a test to validate it is working fine

Then, you can configure a schedule, for example a hourly schedule with the name of the groups you want to synchronize.
And, to check the regular run, go to IQ > Runbook Analyses


### License

Copyright (c) 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.