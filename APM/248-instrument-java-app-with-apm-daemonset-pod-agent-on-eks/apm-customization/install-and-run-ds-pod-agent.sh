#!/bin/sh
# install-and-run-ds-pod-agent.sh
# version: 23.1.230115
# ALLUVIO Aternity Tech Community Cookbook (https://github.com/riverbed/Riverbed-Community-Toolkit)
#
# Unattended install of the Aternity APM agent for Kubernetes Daemonset POD deployment

######################################
# Parameters

## Mandatory
ALLUVIO_ATERNITY_APM_CUSTOMER_ID=${ALLUVIO_ATERNITY_APM_CUSTOMER_ID:=""}
ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST=${ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST:=""}

## Optional 
APM_ANALYSIS_SERVER_HOST=${APM_ANALYSIS_SERVER_HOST:=""}
APM_CT_KUBERNETES_CLUSTER_NAME=${APM_CT_KUBERNETES_CLUSTER_NAME:=""}
APM_CT_KUBERNETES_CLOUD=${APM_CT_KUBERNETES_CLOUD:=""}
APM_CT_KUBERNETES_REGION=${APM_CT_KUBERNETES_REGION:=""}

## Experimental
APM_AGENT_PROXY_SERVER_HOST=${APM_AGENT_PROXY_SERVER_HOST:=""}
APM_AGENT_PROXY_SERVER_PORT=${APM_AGENT_PROXY_SERVER_PORT:=""}
APM_AGENT_PROXY_SERVER_REALM=${APM_AGENT_PROXY_SERVER_REALM:=""}
APM_AGENT_PROXY_SERVER_USER=${APM_AGENT_PROXY_SERVER_USER:=""}
APM_AGENT_PROXY_SERVER_PASSWORD=${APM_AGENT_PROXY_SERVER_PASSWORD:=""}

## Internals
APM_CUSTOMIZATION_PATH=${OVERRIDE_APM_CUSTOMIZATION_PATH:="/var/apm-customization"}
APM_INSTALLER_PACKAGE_PATH=${OVERRIDE_APM_INSTALLER_PACKAGE_PATH:="$APM_CUSTOMIZATION_PATH/appinternals_agent_latest_linux.gz"}
APM_AGENT_INSTALL_BASEDIR_PATH=${OVERRIDE_APM_AGENT_INSTALL_BASEDIR_PATH:="/opt"}
APM_AGENT_INSTALL_TEMPDIR_PATH=${OVERRIDE_APM_AGENT_INSTALL_TEMPDIR_PATH:="/tmp"}
APM_AGENT_USERACCOUNT=${OVERRIDE_APM_AGENT_USERACCOUNT:="root"}

######################################
# Variables initialization
O_SI_SAAS_ANALYSIS_SERVER_ENABLED="true"
O_SI_PROXY_SERVER_ENABLED="false"
O_SI_PROXY_SERVER_AUTHENTICATION="false"

######################################
# Check parameters

if [ -z $ALLUVIO_ATERNITY_APM_CUSTOMER_ID ]
then
    echo "Mandatory parameters are missing"
    exit 5
fi

if [ -z $ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST ]
then
O_SI_SAAS_ANALYSIS_SERVER_ENABLED="false"
    if [ -z $APM_ANALYSIS_SERVER_HOST ]
    then
        echo "Mandatory parameters are missing: ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST or APM_ANALYSIS_SERVER_HOST"
        exit 6
    fi
fi

######################################
# . INSTALL

cd $APM_CUSTOMIZATION_PATH
gunzip appinternals_agent_latest_linux.gz && chmod +x appinternals_agent_latest_linux && ./appinternals_agent_latest_linux -silentinstall install.properties && [ -f "/opt/Panorama/hedzup/mn/lib/librpilj64.so" ]
rm -rf appinternals_agent_latest_linux install.properties

######################################
# . POST-INSTALL re-configuration

echo "APM agent import static config"
# Add customization files if any: instrumentation configurations (.json), initial-mapping and tags.yaml
cat config/initial-mapping  >> "${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/userdata/config/initial-mapping"
cp config/*.json "${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/userdata/config/."

echo "APM agent configuration:"
dsaPath="${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/data/dsa.xml"
if [ "$ALLUVIO_ATERNITY_APM_CUSTOMER_ID" ] 
then
    sed -i 's/^.*name="CustomerID".*/<Attribute name="CustomerID" value="'$ALLUVIO_ATERNITY_APM_CUSTOMER_ID'"\/>/g' $dsaPath
fi
if [ "$ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST" ] 
then
    sed -i 's/^.*name="SaaSAnalysisServerHost".*/<Attribute name="SaaSAnalysisServerHost" value="'$ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST'"\/>/g' $dsaPath
    sed -i 's/^.*name="SaaSAnalysisServerEnabled".*/<Attribute name="SaaSAnalysisServerEnabled" value="true"\/>/g' $dsaPath    
elif [ "$APM_ANALYSIS_SERVER_HOST" ]
then
    sed -i 's/^.*name="AnalysisServerHost".*/<Attribute name="AnalysisServerHost" value="'$APM_ANALYSIS_SERVER_HOST'"\/>/g' $dsaPath
    sed -i 's/^.*name="SaaSAnalysisServerEnabled".*/<Attribute name="SaaSAnalysisServerEnabled" value="false"\/>/g' $dsaPath
fi 

######################################
# . POST-INSTALL tagging

echo "APM agent tagging:"
tagsPath="${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/userdata/config/tags.yaml"

# static tags
cat config/tags.yaml >> $tagsPath

# runtinme tags
machineName=$HOSTNAME
echo "logical server : $machineName" | tee -a $tagsPath
echo "agent installation : kubernetes-daemonset-pod" | tee -a $tagsPath
if [ "$APM_CT_KUBERNETES_CLUSTER_NAME" ] 
then 
echo "cluster name : $APM_CT_KUBERNETES_CLUSTER_NAME" | tee -a $tagsPath
fi
if [ "$APM_CT_KUBERNETES_CLOUD" ] 
then 
echo "kubernetes cloud : $APM_CT_KUBERNETES_CLOUD" | tee -a $tagsPath
fi
if [ "$APM_CT_KUBERNETES_REGION" ] 
then 
echo "kubernetes region : $APM_CT_KUBERNETES_REGION" | tee -a $tagsPath
fi

######################################
# . Start the agent and wait until it is ready

echo "APM agent start:"

# TODO: use dsactl start instaled of agent start
# ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/dsactl start
agentPath="${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/agent"
$agentPath start

in_progress=1
until [ ! "$in_progress" ];
do
    echo "Agent status: starting"
    sleep 5
    in_progress=`$agentPath status | grep starting`
done

# Need a pause before launching the app
sleep 3

$agentPath status

tail -f ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/log/AGENTRT.txt