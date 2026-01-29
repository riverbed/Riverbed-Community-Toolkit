# Riverbed IQ Assist for Copilot - Cookbook Self-Service 101

:alarm_clock: 30 minutes

## Introduction

This community cookbook offers step-by-step instructions to integrate Riverbed IQ Assist with a Microsoft Copilot Agent.

You will learn to create an agent using Microsoft Copilot Studio and add Riverbed IQ Assist skills as tools via a Custom Connector.

This Employee IT Self-Service agent uses Riverbed Platform’s AI Ops and Observability to identify user endpoints and devices, and assist with diagnostics and remediation.

After setting up the agent, you’ll learn to customize and extend it with additional tools for advanced scenarios.

For FAQs, troubleshooting tips, and links to cookbooks or Copilot Agent samples for Riverbed IQ Assist, see the FAQ section at the end of this guide.


| Prerequisites | Description |
|--------------|-------------|
| Microsoft Copilot Studio | An account is required, it can be a trial account. | 
| Riverbed Unified Agent and modules | Unified agent modules must be deployed on your user endpoints (e.g., laptop, VDI, desktop). To use Riverbed IQ Assist skills for user endpoint remediation, you need the Aternity EUEM module and must enable the remediation feature (see Aternity documentation: Getting Started with Remediation). Other modules, such as NPM+, Unified Communication (UC), and Intel WiFi, are optional. | 
| Riverbed Platform | Enable the Riverbed IQ Assist feature and configure the required connectors and integrations, including Riverbed IQ Assist and Aternity EUEM. Obtain OAuth information and generate credentials to connect in Microsoft Copilot Studio | 

## Preparing Riverbed IQ Assist

### 1. Access IQ Ops as Admin

Open the Riverbed console with a user having the Platform Admin role, and navigate to **IQ Ops**

For example: `https://your_tenant.riverbed.cloud`

### 2. Enable Riverbed IQ Assist

Go IQ Ops > Administration > **Riverbed IQ Assist Configuration**, and click on opt-in to enable the feature.

### 3. Install Integrations

Go to IQ Ops > Integrations Library

Find Riverbed IQ Assist, install the integration and configure a connector that you can name Riverbed IQ Assist

Install Aternity EUEM integration and configure a connector. It is recommended to use OAUTH 2.0. Enable ODATA and REMEDIATION adding the corresponding service tags.

Optionally install other integrations: ServiceNow

### 4. Check Data Store

Go to IQ Ops > **Management**

In the hamburger menu, open **Edges & Data Sources** and enable your data sources (e.g. Aternity SAAS, NPM+)

### 5. Get the info and credentials for the Copilot Agent

Go to IQ Ops > **Management**, in the hamburger menu, open **API Access**

On this page you will find all the required information:

* Riverbed Tenant Name

* Riverbed Tenant Id

* Directory Id

* API Scope

* Resource Id URI


For the credentials, click on **Create OAuth Client** to generate a new client. It requires a name, for example put “Riverbed IQ Assist for Copilot”. Then you will obtain the credentials:

* Client Id

* Client Secret

For more details see the FAQ: How to configure the connection in Copilot? where are the info?


## Setting Up the Copilot Agent

### 1. Access Microsoft Copilot Studio

* Navigate to https://copilotstudio.microsoft.com/

* Go to **Agents** and click on **+ New agent**

### 2. Configure the Agent

* Click on **Configure**

* Set a **Logo**, for example you can use the Riverbed Logo ([logo link](./assets/riverbed-icon.png))

* Configure the agent Name, Description and Instruction. For example using this agent sample (*101-Copilot-IT-SelfService*):

Name:

```
IT Self-Service Assistant
```

Description

```
IT Self-Service Assistant is an IT Expert that efficiently handles common technical queries, diagnoses your user endpoints or devices (such as laptop, workstation, etc.), and guides you through resolution steps with clarity and precision.
```

Instructions

```
1. Identify User Devices and Endpoints
Detect and recognize the specific devices and endpoints currently used by the end user.
2. Diagnose Reported Issues
Analyze the symptoms and context to determine the root cause of the problems reported by the user.
3. Recommend Remediation Strategies
When possible, suggest appropriate and effective remediation steps based on available observability data.
4. Provide Clear, User-Friendly Guidance
Ensure all instructions and explanations are simple, jargon-free, and easy to follow—especially for users with limited IT experience.
5. Confirm Before Acting
Always seek explicit confirmation from the user before initiating any remediation actions.
6. Communicate Clearly and Effectively
Responses should be concise, well-structured, and easy to understand, avoiding technical complexity unless necessary.
```

* hit **Create**


### 3. Create a connector for Riverbed IQ Assist skills

* Go to Tools and click **+ Add a Tool.**
* Expand the **Create new** section and click **Custom connector**. A new tab opens (in Power Apps > Custom Connectors).
* At the top right, in the list **+ New custom connector**, select **Import an OpenAPI from URL**
* Fill the Name and the URL of the customer connector definition:

Name:

```
Cookbook Riverbed IQ Assist Skills
```

URL ([raw link of the connector description](./assets/apiDefinition.swagger.json))

```
https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/refs/heads/main/IQ/Agents/101-Copilot-IT-SelfService/apiDefinition.swagger.json
```


* (You are now in the **“1. General”** page), set an icon for your connector, for example you can use the Riverbed Logo ([logo link](./assets/riverbed-icon.png))

* Set the fields **Host** and **Base URL** using the connector information of your account (refer to the preparation steps):

| **Configuration** | **Example** |
| --- | --- |
| Host: `<your Riverbed Tenant Name>.app.cloud.riverbed.com`  | Host: `yourtenant.app.cloud.riverbed.com`  
Base URL: `/api/skills/1.0/tenants/<your Riverbed Tenant Id>` | Base URL: `/api/skills/1.0/tenants/123456-789456-123456` |

* Go to the **“2. Security”** page and configure the following using the connector information of your account (see Preparation):

| **Configuration** | **Example** |
| --- | --- |
| Authentication Type: **OAuth 2.0**  | Authentication Type: **OAuth 2.0** 
| Identity Provider: **Azure Active Directory**  | Identity Provider: **Azure Active Directory**
|  Check the box **Enable Service Principal Support**  | Check the box **Enable Service Principal Support**  
| Client ID: `****` | Client ID: `****`
| Client Secret: `****` | Client Secret: `****` |
| Resource URL: `<your Resource URI>` | Resource URL: `api://987654-654321-321654`
| Scope: `<your API Scope>` | Scope: `api://987654-654321-321654/.default`

> [!NOTE]
> Leave the other fields as is (Authorization URL `https://login.microsoftonline.com`, Tenant ID: `common`, Enable on behalf-of-login: `false`)

* Click on **Create connector** (at the top):

* When the connector is created, just close the tab and go back to Copilot Studio

## 4. Configure a connection for Riverbed IQ Assist skills

Back to Copilot Studio > Tools > Add tool window, you can now search and find the skills of Riverbed IQ Assist that are available as Tools for your agent. You can search with the connector name, tools name prefix like “Self-Service” or the specific tool name.

When adding your first tool, configure the connection first.

* Find and click on the tool **“Self-Service: Find My User Endpoint”** (provided by the connector **“Cookbook Riverbed IQ Assist Skills”**).
* Connection: **Create new connection**
* In Authentication Type, select **Service Principal Connection**.

| **Configuration** | **Example** |
| --- | --- |
| Authentication Type: **Service Principal Connection**  | Authentication Type: **Service Principal Connection**  
| Client ID: `<your OAUTH Client ID>` | Client ID: `123456-456789-987654-654321`
| Client Secret: `<your OAUTH Client Secret>` | Client Secret: `******************************`
| Tenant: `<your Directory ID (not your Riverbed Tenant ID)>` | Tenant: `987654-987654-987654`

> [!NOTE]
> In the Riverbed Console > API Access, the value labelled **Directory Id** must be used in the field **Tenant**. |  

* Click **Create**.

The connection is now created.

## 5. Add a tool using the connection for Riverbed IQ Assist skills

In Tools > Add tool, you selected a tool and configured a connection. Now you will configure this tool for your agent.

* Click on **Add and configure**

* Apply the common configuration for each tool

* Expand **Additional Details**

* Set **When this tool may be used** to **Agent may use this tool at any time**

* Set **Credentials to use** to **Maker-provided credentials**

* Apply configuration for user authentication

* Edit the tool of Riverbed IQ Assist, for example the tool **“Self-Service: Find My User Endpoint”**
* In the **Inputs** section, click **+ Add input**
* Add each of the following, set **Fill using** to **Custom value** and select the corresponding system value from the list:

| Input | Description | Value |
| --- | --- | --- |
| **User ID** | A unique, stable identifier for the human user. Must be set to the System.User.Id environment variable. | `User.Id` |
| **User Principal Name** | The user sign-in name. Must be set to the System.User.PrincipalName environment variable. | `User.PrincipalName` |
| **User Email** | Contact email of the user. Must be set to the System.User.Email environment variable. | `User.Email` |
| **User Display Name** | Human friendly name of the user. Must be set to the System.User.DisplayName environment variable. | `User.DisplayName` |

* Refer to the specific configuration of the tool in the paragraph below
* Click **Save**

## Customize the Agent – Advanced

You created an Employee Self Service Copilot Agent to share with employees. You can extend and customize it by adding tools from the Riverbed IQ Assist skill set.

### 1. Add more tools

Go to the **Tools** tab and add the following **Self-Service** tools:

* **Self-Service: Find My User Endpoint**
* **Self-Service: Suggest User Endpoint Remediation**
* **Self-Service: Initiate Remediation for My User Endpoint**
* **Self-Service: Get My Remediation Run Status**
* **Self-Service: Create a Ticket on My Behalf**

### 2. Apply common configuration to the tools

Edit each tool:

* Set additional details (see FAQ: How to set the additional details?)
* Set user authentication configuration (see FAQ: How to add user authentication to the Tools?)

## Testing the conversational Agent

Once the tools are configured, test the agent end-to-end in Microsoft Copilot Studio:

1. In Copilot Studio, open your Employee IT Self-Service agent.
2. Use the **Test** pane to start a new conversation.
3. Try typical user prompts, for example:
   * "Find my laptop"  
   * "Check if there are any issues with my device"  
   * "Start remediation on my endpoint"  
4. Confirm that the agent:
   * Identifies the user and their endpoint correctly.
   * Invokes the appropriate Riverbed IQ Assist tools.
   * Returns clear status messages and next steps to the user.
5. Review any errors in the tool invocation logs or Copilot Studio trace output and adjust tool configuration (authentication, parameters, or additional details) as needed.

When you are satisfied with the behavior in the test pane, proceed to deploy the agent to Microsoft Teams.

## Deploying the Agent to Teams

To make the agent available to users in Microsoft Teams:

1. In Copilot Studio, select your Employee IT Self-Service agent.
2. Choose **Publish** (or **Go live**) to create a production version.
3. Navigate to the **Channels** section for the agent.
4. Enable the **Microsoft Teams** channel and follow the guided steps:
   * Configure the display name and icon for the agent in Teams.
   * Set who can access the agent (e.g., specific groups or the whole organization).
5. Complete any required approvals in the Teams admin center, if your organization requires app approval.
6. From the Teams client, search for the published agent by name, add it to a chat, and run a few of the same test prompts used in Copilot Studio to confirm behavior.

After verifying that the agent works as expected in Teams, communicate availability and basic usage examples to your end users.

## Frequently Asked Questions (FAQ)

*work in progress*

## License

Copyright (c) 2026 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
