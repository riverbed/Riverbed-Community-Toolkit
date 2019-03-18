#!/bin/bash
 
azure config mode arm
azure login
 
if [ -z "$1" ]
then
SubsID=$(azure account show | grep "ID" | grep -v "Tenant ID"|
awk -F ":" '{print $3}' | awk '{print $1}')
echo "Using default Subscription ID: $SubsID"
else
SubsID=$1
echo "Using user provided Subscription ID: $SubsID"
fi
 
AppName="SteelConnect$RANDOM"
AppSecret="SteelConnect123$RANDOM"
AppID=$(azure ad app create --name $AppName \
--home-page https://www.riverbed.com/$RANDOM \
--password $AppSecret \
--identifier-uris https://www.riverbed.com/$RANDOM |
grep "AppId" | awk -F ":" '{print $3}' | awk '{print $1}')
SPObjID=$(azure ad sp create --applicationId $AppID |
grep "Object Id" | awk -F ":" '{print $3}' | awk '{print $1}')
echo "On Azure Portal, created an application with name: $AppName"
echo "Waiting for changes to propagate to Azure..."
sleep 120
azure role assignment create --objectId $SPObjID -o Owner -c \
/subscriptions/$SubsID > /dev/null 2>&1
TenantID=$(azure account show $SubsID | grep "Tenant ID" |
awk -F ":" '{print $3}' | awk '{print $1}')
echo "*******************************************************"
echo "Credentials to enter on SCM:"
echo "Subscription ID: $SubsID"
echo "Application ID: $AppID"
echo "Secret Key: $AppSecret"
echo "Tenant ID: $TenantID"
echo "***************************************************"