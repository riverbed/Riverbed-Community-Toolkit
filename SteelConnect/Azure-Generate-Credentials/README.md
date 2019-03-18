#### Generate Azure Credentials for SteelConnect SCM

- Go to Azure portal https://portal.azure.com
- Open Cloud Shell (select Bash mode)
- Run the following bash commands to download and execute the script **azure_credentials_generate.sh**: 

```bash
wget https://raw.githubusercontent.com/riverbed/se-toolkit/master/SteelConnect/Azure-Generate-Credentials/azure_credentials_generate.sh

chmod +x

azure_credentials_generate.sh
```

  About 2 min after you will get the output with all the parameters required to add the Azure account in SteelConnect SCM > Network Design > Azure.