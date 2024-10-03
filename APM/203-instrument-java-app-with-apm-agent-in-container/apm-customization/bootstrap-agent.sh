#! /bin/sh
# bootstrap-agent.sh
# 23.1.230123
# Cookbook 203 - Aternity Tech Community Cookbook (https://github.com/riverbed/Riverbed-Community-Toolkit)
#
# Usage:
#   bootstrap-agent.sh <cmd> <args>
# Example:
#   bootstrap-agent.sh java /app/app.jar

######################################
# Parameters

APM_AGENT_INSTALL_BASEDIR_PATH=${OVERRIDE_APM_AGENT_INSTALL_BASEDIR_PATH:="/opt"}

######################################
# 1. POST-INSTALL re-configuration

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
elif [ "$ALLUVIO_ATERNITY_APM_ANALYSIS_SERVER_HOST" ]
then
    sed -i 's/^.*name="AnalysisServerHost".*/<Attribute name="AnalysisServerHost" value="'$ALLUVIO_ATERNITY_APM_ANALYSIS_SERVER_HOST'"\/>/g' $dsaPath
    sed -i 's/^.*name="SaaSAnalysisServerEnabled".*/<Attribute name="SaaSAnalysisServerEnabled" value="false"\/>/g' $dsaPath
fi
if [ "$ALLUVIO_ATERNITY_APM_PROXY_SERVER_HOST" ] 
then
    sed -i 's/^.*name="ProxyServerEnabled".*/<Attribute name="ProxyServerEnabled" value="true"\/>/g' $dsaPath
    sed -i 's/^.*name="ProxyServerHost".*/<Attribute name="ProxyServerHost" value="'$ALLUVIO_ATERNITY_APM_PROXY_SERVER_HOST'"\/>/g' $dsaPath
    sed -i 's/^.*name="ProxyServerPort".*/<Attribute name="ProxyServerPort" value="'$ALLUVIO_ATERNITY_APM_PROXY_SERVER_PORT'"\/>/g' $dsaPath
fi

######################################
# 2. POST-INSTALL tagging

echo "APM agent tagging:"
tagsPath="${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/userdata/config/tags.yaml"
machineName=$HOSTNAME
cat >> $tagsPath <<- EOF
logical server : $machineName
agent installation : container
EOF
cat $tagsPath

######################################
# 3. Start the agent and wait until it is ready

${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/dsactl start

agentPath="${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/agent"
echo "APM agent start:"
in_progress=1
until [ ! "$in_progress" ];
do
    echo "Agent status: starting"
    sleep 5
    in_progress=`$agentPath status | grep starting`
done
$agentPath status

if [ `which dotnet` ]; then
    echo "Detect dotnet presence and enable dotnet instrumentation"
    ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/install_mn/install_startup.sh
    ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/InstallNetCore.sh
    ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/rpictrl.sh install
    ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/rpictrl.sh enable
    ${APM_AGENT_INSTALL_BASEDIR_PATH}/Panorama/hedzup/mn/bin/rpictrl.sh status
fi

# Need a pause before launching the app
sleep 3

######################################
# 4. Launch the app with the command provided in arguments

echo "App start: $*"
$*
