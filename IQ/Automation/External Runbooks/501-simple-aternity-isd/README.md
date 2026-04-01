# Simple Example Aternity ISD

External runbook that ingests SDA alerts via HTTP, maps requestBody fields into runtime variables, picks a remediation action based on alert_name (e.g., "Low Disk Space" → "Empty Recycle Bin1"), and shows summary/detail tables in the IQ UI. Marked demo (DO NOT MODIFY); templates contain a few typos (e.g., "alersubnett_id") that can break some mappings.

After downloading the [runbook file](./Simple%20Example%20Aternity%20ISD.txt), go to the IQ **Automation** page and import it under **External Runbooks**.

### License

Copyright (c) 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
