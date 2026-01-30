# Riverbed IQ Assist for Copilot - Cookbook Self-Service 101

:alarm_clock: Approximately 30 minutes

## Introduction

This community cookbook offers step-by-step instructions to integrate Riverbed IQ Assist with a Microsoft Copilot Agent.

You will learn to create an agent using Microsoft Copilot Studio and add Riverbed IQ Assist skills as tools via a Custom Connector.

This Employee IT Self-Service agent uses Riverbed Platform’s AI Ops and Observability to identify user endpoints and devices, and assist with diagnostics and remediation.

After setting up the agent, you’ll learn to customize and extend it with additional tools for advanced scenarios.

For tips, and links to cookbooks or Copilot Agent samples for Riverbed IQ Assist, see the FAQ section at the end of this guide.


| Prerequisites | Description |
|--------------|-------------|
| Microsoft Copilot Studio | An account is required, it can be a trial account. | 
| Riverbed Unified Agent and modules | Unified agent modules must be deployed on your user endpoints (e.g., laptop, VDI, desktop). To use Riverbed IQ Assist skills for user endpoint remediation, you need the Aternity EUEM module and must enable the remediation feature (see Aternity documentation: Getting Started with Remediation). Other modules, such as NPM+, Unified Communication (UC), and Intel WiFi, are optional. | 
| Riverbed Platform | Enable the Riverbed IQ Assist feature and configure the required connectors and integrations, including Riverbed IQ Assist and Aternity EUEM. Obtain OAuth information and generate credentials to connect in Microsoft Copilot Studio | 

## Preparing Riverbed IQ Assist

### 1. Access IQ Ops as Admin

Open the Riverbed console with a user having the Platform Admin role, and navigate to **IQ Ops**

For example: `https://your_tenant.cloud.riverbed.com`

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

> [!NOTE]
> **Riverbed Tenant Name** is the prefix of the URL of the Riverbed console. For example, in the URL `https://your_tenant.cloud.riverbed.com` the **Riverbed Tenant Name** is **your_tenant**
>
> On this page the **Riverbed Tenant Id** is labeled **Tenant Id**. For example `123456-789456-123456`
>
> **Directory Id** is the *GUID* between the domain and the /oauth2/ in the Access Token URI. For example, in the following **Access Token URI** `https://login.microsoftonline.com/987654-987654-987654/oauth2/v2.0/token`, the **Directory Id** is `987654-987654-987654`
>
> To obtain the **Resource Id URI**, take the first portion of the **API Scope** (i.e. remove /.default from the API Scope). For example, if the **API Scope** is `api://987654-654321-321654/.default` then the **Resource Id URI** is `api://987654-654321-321654`


For the credentials, click on **Create OAuth Client** to generate a new client. It requires a name, for example put "Riverbed IQ Assist for Copilot". Then you will obtain the credentials:

* Client Id

* Client Secret


## Setting Up the Copilot Agent

### 1. Access Microsoft Copilot Studio

* Navigate to https://copilotstudio.microsoft.com/

* Go to **Agents** and click on **+ New agent**

### 2. Configure the Agent

* Click on **Configure**

* Set a **Logo**, for example you can use the Riverbed logo ([follow the link and download](https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/refs/heads/master/IQ/Agents/101-Copilot-IT-SelfService/assets/riverbed-icon.png))

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
* Fill the **Connector name** and the **URL** of the customer connector definition:

Connector name:

```
Cookbook Riverbed IQ Assist
```

URL:

```
https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/refs/heads/master/IQ/Agents/101-Copilot-IT-SelfService/assets/apiDefinition.swagger.json
```

> [!NOTE]
> This is the *raw link* of the [connector description](./assets/apiDefinition.swagger.json)

* Click on **Import** and then click **Continue**


* (You are now in the **1. General** page), Download the Riverbed logo ([follow the link and download](https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/refs/heads/master/IQ/Agents/101-Copilot-IT-SelfService/assets/riverbed-icon.png)) 

* Set the icon of the connector with the Riverbed logo

* Set the fields **Host** and **Base URL** using the information of your Riverbed tenant (refer to **Preparing Riverbed IQ Assist** > **5. Get the info and credentials for the Copilot Agent**):

| **Configuration** | **Example** |
| --- | --- |
| Host: `<your Riverbed Tenant Name>.app.cloud.riverbed.com`  | Host: `your_tenant.app.cloud.riverbed.com`  
Base URL: `/api/skills/1.0/tenants/<your Riverbed Tenant Id>` | Base URL: `/api/skills/1.0/tenants/123456-789456-123456` |

<details>
<summary>Click here to see an example screenshot</summary>

![alt Connector General](assets/screenshot_connector_general.png)
![alt text](image.png)
</details>

* Go to the **2. Security** page

* Select the Authentication Type: **OAuth 2.0**

* Select the Identity Provider: **Azure Active Directory**

* Check the box **Enable Service Principal Support** 

* Set the value `0000` for **Client ID**, and `****` for the **Client Secret**. These are only placeholder values and not actual credentials.

* Configure the following properties using the connector information of your account (refer to **Preparing Riverbed IQ Assist** > **5. Get the info and credentials for the Copilot Agent**):

| **Configuration** | **Example** |
| --- | --- |
| Resource URL: `<your Resource Id URI>` | Resource URL: `api://987654-654321-321654`
| Scope: `<your API Scope>` | Scope: `api://987654-654321-321654/.default`

* Leave the other fields as is (**Authorization URL** `https://login.microsoftonline.com`, **Tenant ID**: `common`, **Enable on behalf-of-login**: `false`)

<details>
<summary>Click here to see an example screenshot</summary>

![alt Connector Security](assets/screenshot_connector_security.png)

</details>

* Click on **Create connector** (at the top):

* When the connector is created, you can close the tab, and go back to Copilot Studio

## 4. Configure a connection for Riverbed IQ Assist skills

Back to Copilot Studio > Tools > Add tool window, you can now search and find the skills of Riverbed IQ Assist that are available as Tools for your agent. You can search with the connector name, tools name prefix like "Self-Service" or the specific tool name.

When adding your first tool, configure the connection first.

* Find and click on the tool **Self-Service: Find My User Endpoint** (the tools provided by the connector **Cookbook Riverbed IQ Assist**).

* Expand Connection and click on **Create new connection**

* In Authentication Type, select **Service Principal Connection**

* Configure the properties using the Client ID, Client Secret and Directory ID of your Riverbed account (refer to **Preparing Riverbed IQ Assist** > **5. Get the info and credentials for the Copilot Agent**):

| **Configuration** | **Example** |
| --- | --- |
| Client ID: `<your OAUTH Client ID>` | Client ID: `123456-456789-987654-654321`
| Client Secret: `<your OAUTH Client Secret>` | Client Secret: `******************************`
| Tenant: `<your Directory ID (not your Riverbed Tenant ID)>` | Tenant: `987654-987654-987654`

<details>
<summary>Click here to see an example screenshot</summary>

![alt Connection](assets/screenshot_connection.png)

</details>

* Click **Create**.

The connection is now created.

## 5. Add a tool using the connection for Riverbed IQ Assist skills

In Tools > Add tool, you selected a tool and configured a connection. Now you will configure this tool for your agent.

* Click on **Add and configure**

* Expand **Additional Details**

* Set **When this tool may be used** to **Agent may use this tool at any time**

* Set **Credentials to use** to **Maker-provided credentials**

<details>
<summary>Click here to see an example screenshot</summary>

![alt Tool Additional details](assets/screenshot_tool_additional_details.png)

</details>

* Scroll down to the **Inputs** section

* For each of the inputs listed below, set the **Fill using** field to **Custom value**. Then, in the **Value** field, select **Select variable** (click the 3-dots button on the right), select **System**, search and choose the corresponding system variable in the list:

| Input | Select this system variable as the Value |
| --- | --- |
| **User ID** | `User.Id` |
| **User Principal Name** | `User.PrincipalName` |
| **User Email** | `User.Email` |
| **User Display Name** | `User.DisplayName` |

<details>
<summary>Click here to see an example screenshot</summary>

![alt Tool Inputs](assets/screenshot_tool_inputs.png)

</details>

* Click **Save**

## Customize the Agent – Advanced

You created an Employee Self Service Copilot Agent to share with employees. You can extend and customize it by adding tools from the Riverbed IQ Assist skill set.

### 1. Add more tools

Go to the **Tools** tab and add more **Self-Service** tools, for example:

* **Self-Service: Find My User Endpoint**
* **Self-Service: Suggest User Endpoint Remediation**
* **Self-Service: Initiate Remediation for My User Endpoint**
* **Self-Service: Get My Remediation Run Status**
* **Self-Service: Create a Ticket on My Behalf**

### 2. Apply common configuration to the tools

For each tool, follow the same **Additional Details** and **Inputs** configuration steps described in **"5. Add a tool using the connection for Riverbed IQ Assist skills"** in the previous section.

## Testing the conversational Agent

Once the tools are configured, test the agent end-to-end in Microsoft Copilot Studio:

1. Use the **Test** pane to start a new conversation.
2. Try typical user prompts, for example:
   * "Find my laptop"  
   * "Check if there are any issues with my device"   
3. Confirm that the agent:
   * Identifies the user and their endpoint correctly.
   * Invokes the appropriate Riverbed IQ Assist tools.
   * Returns clear status messages and next steps to the user.
5. Review any errors in the tool invocation logs or Copilot Studio trace output and adjust tool configuration (authentication, parameters, or additional details) as needed.

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

## Frequently Asked Questions (FAQ)

### How to fix errors in Copilot?

#### Error: connectorRequestFailure The connector returned an HTTP error with code 405

A 405 error typically indicates a minor configuration issue in the connector—most often a simple mistake such as a typo in the Host property.

How to fix it:

* In Copilot Studio, open the Tools menu.
* Select the connector in question.
* Review the configuration details carefully and correct any errors (e.g., Host, Path, Authentication settings).
* Save and test the connector again.

#### Error: connectorRequestFailure The connector returned an HTTP error with code 403. Inner Error: User is not authorized to access this resource with an explicity deny identity-based policy.

A 403 error usually means the connector configuration is pointing to a resource the caller does not have permission to access. 

How to fix it:

* The simplest solution is often to delete the connector and recreate it. Refer to **Preparing Riverbed IQ Assist** > , **3. Create a connector for Riverbed IQ Assist skills**

## License

Copyright (c) 2026 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
