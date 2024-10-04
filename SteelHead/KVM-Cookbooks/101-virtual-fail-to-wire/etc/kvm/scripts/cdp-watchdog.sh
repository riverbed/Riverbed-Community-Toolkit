#!/bin/bash
#################################################################
# Copyright (c) 2024 Riverbed Technology LLC
# This software is licensed under the terms and conditions of the 
# MIT License accompanying the software (“License”).  
# This software is distributed “AS IS” as set forth in the License.
#################################################################

# May 10, 2024
# Platform is for KVM Virtual SteelHead Deployments
# Multiple In-Path Interface Failover Capability
# This script will detect all physical network interfaces on the host 
# Linux server and allow you to assign interfaces to your SteelHead-v.
#
#
#
###########   Fixed Variables    #################
WarnTimer="3" # Warning Message Timer            #
ActionTimer="3" # AI Action Message Timer        #
SleepLink="3"  # Timer for testing LSP           #
LinkState=`cat /etc/kvm/scripts/rvbd-lsp.cfg`    #
#AI=cat /etc/kvm/scripts/rvbd-AI.cfg             #
########### Screen Timer Variables ###############

############################################
# Note: Linkstate LSP                      #
# Read link state settings                 #
# LinkState=`cat /etc/kvm/scripts/lsp.cfg  #
# End Read link state                      #
#                                          #
############################################

####################################################
# Note: In Linux you may change default NIC Names. #
# Edit the file below to set the interface names   #
#/etc/udev/rules.d/70-persistent-net.rules         #
#                                                  #
####################################################

#############################################################################
#                                                                           #
# NOTE: This script can be launched as a deamon at boot time                #
#       Cron can test to ensure the script stays alive                      #
#       You can even start the SteelHead at boot using the commands below   #
#       virsh start VeSHA-2                                                 #
#############################################################################

#######################################################################
#                                                                     #
# Create a service that will run as a service in the background.      #
#                                                                     #
# Edit: /etc/systemd/system/cdp-watchdog.service                      #
#                                                                     #
#                                                                     #
# [Unit]                                                              #
# Description=CDP Watchdog                                            #
# [Service]                                                           #
# Type=simple                                                         #
# ExecStart=/usr/sbin/cdp-watchdog.sh                                 #
# Restart=always                                                      #
# RestartSec=5                                                        #
# [Install]                                                           #
# WantedBy=multi-user.target                                          #
#                                                                     #
#                                                                     #
# Commands to manage the service:                                     #
#                                                                     #
# systemctl enable cdp-watchdog # Enables it as a service at boot     #
# systemctl disable cdp-watchdog # Disables it as a service at boot   #
#                                                                     #
# systemctl start cdp-watchdog # starts the service from the CLI      #
# systemctl stop cdp-watchdog # Stops the service from the CLI        #
#                                                                     #
#######################################################################










############### SteelHead Terminate Graceful ############
#           virsh destroy VeSHA-2 --graceful            #
################### SteelHead start up ##################
#                  virsh start VeSHA-2                  #
#########################################################

#########################################################
#        If the secure vault becomes corrupt            #
#      you may clear it with the command below          #
#                secure-vault clear                     #
#########################################################

#############################################################################################
# We must turn off Network Manager or it will cause problems with the virtual NICs.         #
#                                                                                           #
/usr/bin/systemctl stop NetworkManager.service                                              #
#                                                                                           #
#                                                                                           #
# Do Not use the next command to make it permanet!!                                         #
# systemctl disable NetworkManager.service                                                  #
#                                                                                           #
# Then you enable the network service in a similar fashion.                                 #
# systemctl enable network.service                                                          #
# systemctl start network.service                                                           #
#############################################################################################

########### Start Perpetual Do While Operations ############
clear                                                      #
KvCounter="0"                                              #
LScounter="0"                                              #
Condition="0"                                              #
Status="0"                                                 #
Q="5"                                                      #
while [ $Q == 5 ]                                          #
do                                                         #
KvCounter=$((KvCounter+1))                                 #
LScounter=$((LScounter+1))                                 #
LinkState=`cat /etc/kvm/scripts/rvbd-lsp.cfg`              #
ActionTimer=`cat /etc/kvm/scripts/rvbd-action-timer.cfg`   #
############################################################


############## Reset Riverbed KVM Interfaces ################
if [ "$KvCounter" -eq 400 ] || [ $KvCounter -eq 3 ]; then   #
VNET="vnet0"                                                #
L1="0"                                                      #
J1="0"                                                      #
IFS=$'\n' arr3=( $(/usr/sbin/brctl show | grep vnet) )      #
K1="${#arr3[@]}"                                            #
#echo "G: $K1"                                              #
#                                                           #
while [ $L1 != $K1 ]                                        #
do                                                          #
#                                                           #
KVMP=${arr3[0$L1]//$'\t'/ }                                 #
KVMP="${KVMP##* }"                                          #
if [ "$KVMP" != " " ]; then                                 #
#echo "Interface: $KVMP "                                   #
VNET="vnet""$J1"                                            #
#echo "VMNET: $VNET"                                        #
#echo "KVMP: $KVMP"                                         #
J1=$((J1+1))                                                #
fi                                                          #
/usr/sbin/ip link set $KVMP down                            #
/usr/sbin/ip link set $KVMP name $VNET                      #
/usr/sbin/ip link set $VNET up                              #
L1=$((L1+1))                                                #
done                                                        #
KvCounter="0"                                               #
fi                                                          #
########### End Reset Riverbed KVM Interfaces ###############

############################### Link State Enabled  ############################################
if [ "$LinkState" -eq 1 ] && [ $LScounter -eq 3 ]; then                                        #
clear                                                                                          #
echo "************************************"                                                    #
echo "* Link State Propagation is active *"                                                    #
echo "************************************"                                                    #
#                                                                                              #
C1="0"                                                                                         #
C2="1"                                                                                         #
C3="2"                                                                                         #
C4="0"                                                                                         #
#                                                                                              #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file                 #
while [ $C3 != 32 ]                                                                            #
do                                                                                             #
#                                                                                              #
if  [[ ${network[$C1]} == *"lan"* ]] && [ ${network[$C3]} != "None" ]; then                    #
#                                                                                              #
C1=$((C1+3))                                                                                   #
C2=$((C2+3))                                                                                   #
C3=$((C3+3))                                                                                   #
if  [[ ${network[$C1]} == *"wan"* ]] && [ ${network[$C3]} != "None" ]; then                    #
#                                                                                              #
G1=$C1-"3"                                                                                     #
G2=$C2-"3"                                                                                     #
G3=$C3-"3"                                                                                     #
#                                                                                              #
/usr/sbin/ip link set dev ${network[$C2]} up                                                   #
/usr/sbin/ip link set dev ${network[$G2]} up                                                   #
sleep $SleepLink                                                                               #
#                                                                                              #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/${network[$C2]}/operstate | tr -d '\r' ) )   #
NIC1=("${array[0]##* }")                                                                       #
#                                                                                              #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/${network[$G2]}/operstate | tr -d '\r' ) )   #
NIC2=("${array[0]##* }")                                                                       #
#                                                                                              #
if [ "$NIC1" != "up" ]; then                                                                   #
/usr/sbin/ip link set dev ${network[$G2]} down                                                 #
else                                                                                           #
/usr/sbin/ip link set dev ${network[$G2]} up                                                   #
fi                                                                                             #
#                                                                                              #
if [ "$NIC2" != "up" ]; then                                                                   #
/usr/sbin/ip link set dev ${network[$C2]} down                                                 #
else                                                                                           #
/usr/sbin/ip link set dev ${network[$C2]} up                                                   #
fi                                                                                             #
### Verify                                                                                     #
#                                                                                              #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/${network[$C2]}/operstate | tr -d '\r' ) )   #
NIC1=("${array[0]##* }")                                                                       #
#                                                                                              #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/${network[$G2]}/operstate | tr -d '\r' ) )   #
NIC2=("${array[0]##* }")                                                                       #
#                                                                                              #
echo "Interface status: ${network[$C2]} $NIC1 "                                                #
echo "Interface status: ${network[$G2]} $NIC2 "                                                #
echo " "                                                                                       #
sleep $ActionTimer                                                                             #
#                                                                                              #
#                                                                                              #
fi                                                                                             #
fi                                                                                             #
C1=$((C1+3))                                                                                   #
C2=$((C2+3))                                                                                   #
C3=$((C3+3))                                                                                   #
done                                                                                           #
LScounter="0"                                                                                  #
fi                                                                                             #
clear                                                                                          #
################################# End Link State Enabled  ######################################

################################# Link State Disabled  #########################################
if [ "$LinkState" -eq 0 ] && [ $LScounter -eq 3 ]; then                                        #
clear                                                                                          #
echo "***************************************"                                                 #
echo "* Link State Propagation is Not active *"                                                #
echo "***************************************"                                                 #
#                                                                                              #
C1="0"                                                                                         #
C2="1"                                                                                         #
C3="2"                                                                                         #
C4="0"                                                                                         #
#                                                                                              #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file                 #
while [ $C3 != 32 ]                                                                            #
do                                                                                             #
#                                                                                              #
if  [[ ${network[$C1]} == *"lan"* ]] && [ ${network[$C3]} != "None" ]; then                    #
#                                                                                              #
C1=$((C1+3))                                                                                   #
C2=$((C2+3))                                                                                   #
C3=$((C3+3))                                                                                   #
if  [[ ${network[$C1]} == *"wan"* ]] && [ ${network[$C3]} != "None" ]; then                    #
#                                                                                              #
G1=$C1-"3"                                                                                     #
G2=$C2-"3"                                                                                     #
G3=$C3-"3"                                                                                     #
#                                                                                              #
/usr/sbin/ip link set dev ${network[$C2]} up                                                   #
/usr/sbin/ip link set dev ${network[$G2]} up                                                   #
sleep $SleepLink                                                                               #
echo "Interface ${network[$C2]} and ${network[$G2]} are enabled."                              #
echo " "                                                                                       #
#                                                                                              #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/${network[$C2]}/operstate | tr -d '\r' ) )   #
NIC1=("${array[0]##* }")                                                                       #
#                                                                                              #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/${network[$G2]}/operstate | tr -d '\r' ) )   #
NIC2=("${array[0]##* }")                                                                       #
#                                                                                              #
fi                                                                                             #
fi                                                                                             #
C1=$((C1+3))                                                                                   #
C2=$((C2+3))                                                                                   #
C3=$((C3+3))                                                                                   #
LScounter="0"                                                                                  #
done                                                                                           #
fi                                                                                             #
sleep $ActionTimer                                                                             #
clear                                                                                          #
################################# End Link State Disabled  #####################################

########################## SteelHead is Already Optimizing No Changes #################################
#                                                                                                     #
if [ "$Status" -eq 1 ] && [ "$Condition" -eq 1 ]; then                                                #
clear                                                                                                 #
echo " "                                                                                              #
echo "**********************************************************************************************" #
echo " SteelHead $hostname is already optimizing and the platform is $platform."                      #
echo " CDP packets detected on $Interface with IP address: $IP with RiOS Ver: $rios "                 #
echo " No changes will be made."                                                                      #
echo "**********************************************************************************************" #
sleep $ActionTimer                                                                                    #
fi                                                                                                    #
####################### End SteelHead is Already Optimizing No Changes ################################


############################# Dynamically Build the bridged interfaces #################################
#                                                                                                      #
if [ "$Status" -eq 1 ] && [ "$Condition" -eq 0 ]; then                                                 #
clear                                                                                                  #
echo " "                                                                                               #
echo "**********************************************************************************************"  #
echo " SteelHead $hostname has been detected on interface $Interface and will be set to  optimize."    #
echo "**********************************************************************************************"  #
sleep $ActionTimer                                                                                     #
#                                                                                                      #
C1="0"                                                                                                 #
C2="1"                                                                                                 #
C3="2"                                                                                                 #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file                         #
                                                                                                       #
while [ $C3 != 32 ]                                                                                    #
do                                                                                                     #
if [ ${network[$C2]} != "None" ] && [ ${network[$C3]} != "None" ]; then                                #
#                                                                                                      #
if [ ${network[$C1]} != "primary" ] && [ ${network[$C1]} != "aux" ]; then                              #
#                                                                                                      #
#                                                                                                      #
#echo "Setting up interface: ${network[$C1]} ${network[$C2]} ${network[$C3]} "                         #
#echo " "                                                                                              #
/usr/sbin/ip link add ${network[$C3]} type bridge                                                      #
mac=$(/usr/bin/openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/:$//')                                     #
MAC="00-0e-b6:""$mac" # Include Riverbed Prefix MAC                                                    #
MAC=$(echo $MAC | tr "-" ":")                                                                          #
ifconfig ${network[$C3]} hw ether $MAC                                                                 #
/usr/sbin/ip link set ${network[$C2]} nomaster                                                         #
/usr/sbin/ip link set ${network[$C2]} master ${network[$C3]}                                           #
/usr/sbin/ip link set ${network[$C3]} type bridge stp_state 0                                          #
/usr/sbin/ip link set ${network[$C3]} up                                                               #
fi                                                                                                     #
fi                                                                                                     #
C1=$((C1+3))                                                                                           #
C2=$((C2+3))                                                                                           #
C3=$((C3+3))                                                                                           #
done                                                                                                   #
Condition="1"                                                                                          #
fi # End Status 1 and condition 0                                                                      #
clear                                                                                                  #
echo " "                                                                                               #
echo "******************************************************************"                              #
/usr/sbin/brctl show                                                                                   #
echo "******************************************************************"                              #
sleep $ActionTimer                                                                                     #
#                                                                                                      #
clear                                                                                                  #
########################## End Dynamically Build the bridged interfaces ################################


######################### Begin Main Do While Operation #########################
Failover="0"                                                                    #
C10="0"                                                                         #
C12="1"                                                                         #
C13="2"                                                                         #
C14="0"                                                                         #
#                                                                               #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file  #
while [ $C13 != 32 ]                                                            #
do                                                                              #
#                                                                               #
if  [[ ${network[$C10]} == *"wan"* ]] && [ ${network[$C13]} != "None" ]; then   #
#                                                                               #
#################################################################################

################################## Launch the TCP dump to capture CDP Packets #####################################
#                                                                                                                 #
# Set TCP dump to timeout in 6 seconds. The SteelHead sends them every 5 seconds                                  #
# Set the Packet length to 100 bytes                                                                              #
# Use the destination Layer 2 MAC for Multicast 01:00:0c:cc:cc:cc                                                 #
clear                                                                                                             #
echo " "                                                                                                          #
echo "*************************************************************************************"                      #
#                                                                                                                 #
IFS=$'\n' array=( $( timeout 6s /usr/sbin/tcpdump -v -ni ${network[$C13]} -s 100 ether dst 01:00:0c:cc:cc:cc ) )  #
#                                                                                                                 #
#                                                                                                                 #
# Create an array with the output from the TCP dump                                                               #
hostname=("${array[1]##* }")                                                                                      #
hostname=${hostname//\'/}                                                                                         #
#                                                                                                                 #
# Note: All echo commands can be eliminated for actual implementation                                             #
#                                                                                                                 #
IP=$(echo ${array[2]##* })                                                                                        #
Interface=("${array[3]##* }")                                                                                     #
Interface=${Interface//\'/}                                                                                       #
proto=$(echo ${array[0]})                                                                                         #
proto=$(echo ${proto%%,*}) # trim off the .                                                                       #
proto=$(echo ${proto##* }) # trim off the .                                                                       #
rios=("${array[6]##* }")                                                                                          #
platform=("${array[7]##* }")                                                                                      #
platform=${platform//\'/}                                                                                         #
#                                                                                                                 #
if [ "$proto" == "CDPv2" ] && [ "$platform" == "VCX" ]; then                                                      #
clear                                                                                                             #
echo " "                                                                                                          #
echo "**********************************************************************************************************" #
echo " "                                                                                                          #
echo " SteelHead $hostname sent a $proto packet from $Interface on IP address: $IP with RiOS Ver: $rios"          #
echo " "                                                                                                          #
echo "**********************************************************************************************************" #
sleep $ActionTimer                                                                                                #
#                                                                                                                 #
if (( $Condition == "5" )); then                                                                                  #
Condition="0"                                                                                                     #
fi                                                                                                                #
#                                                                                                                 #
#                                                                                                                 #
break     # Note: There is no need to test additional interfaces if the first one returns CDP infomation.         #
Failover="0"                                                                                                      #
Status="1"                                                                                                        #
else                                                                                                              #
Failover=$((Failover+1))                                                                                          #
clear                                                                                                             #
echo " "                                                                                                          #
echo "****************************************************************"                                           #
echo "Did not receive CDPv2 packets on the inpath interfaces"                                                     #
echo "****************************************************************"                                           #
sleep $ActionTimer                                                                                                #
Failover="3"                                                                                                      #
clear                                                                                                             #
fi                                                                                                                #
#                                                                                                                 #
fi                                                                                                                #
C10=$((C10+3))                                                                                                    #
C12=$((C12+3))                                                                                                    # 
C13=$((C13+3))                                                                                                    #
done                                                                                                              #
############################# End  Launch the TCP dump to capture CDP Packets #####################################

#################################### SteelHead Service is Optimizing ? #################################
if (( $Failover <= "1" )) ; then                                                                       #
Status="1"                                                                                             #
else                                                                                                   #
echo "**********************************************************************************************"  #
echo "The SteelHead has not sent any CDP packets and will assume it has failed."                       #
echo "**********************************************************************************************"  #
sleep $ActionTimer                                                                                     #
clear                                                                                                  #
#                                                                                                      #
Status="0"                                                                                             #
if (( $Condition != "5" )); then                                                                       #
Condition="0"                                                                                          #
fi                                                                                                     #
#                                                                                                      #
fi                                                                                                     #
################################# End SteelHead Service is Optimizing ? ################################

############# Dynamically failover the bridged interfaces ######################
#                                                                              #
if (( $Status == "0" )) && (( $Condition == "5" )) ; then                      #
echo " "                                                                       #
echo "******************************************************************"      #
echo "The SteelHead is already in Failover and there will be no change"        #
echo "******************************************************************"      #
echo " "                                                                       #
sleep $ActionTimer                                                             #
clear                                                                          #
fi                                                                             #
if (( $Status == "0" )) && (( $Condition == "0" )); then                       #
echo " "                                                                       #
echo "********************************************"                            #
echo "The SteelHead is being set to failover now!"                             #
echo "********************************************"                            #
echo " "                                                                       #
sleep $ActionTimer                                                             #
clear                                                                          #
#                                                                              #
C1="0"                                                                         #
C2="1"                                                                         #
C3="2"                                                                         #
C4="0"                                                                         #
#                                                                              #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file #
while [ $C3 != 32 ]                                                            #
do                                                                             #
#                                                                              #
if  [[ ${network[$C1]} == *"lan"* ]] && [ ${network[$C3]} != "None" ]; then    #
#                                                                              #
C1=$((C1+3))                                                                   #
C2=$((C2+3))                                                                   #
C3=$((C3+3))                                                                   #
if  [[ ${network[$C1]} == *"wan"* ]] && [ ${network[$C3]} != "None" ]; then    #
#                                                                              #
G1=$C1-"3"                                                                     #
G2=$C2-"3"                                                                     #
G3=$C3-"3"                                                                     #
#                                                                              #
/usr/sbin/ip link set ${network[$G2]} nomaster                                 #
/usr/sbin/ip link set ${network[$G2]} master ${network[$C3]}                   #
/usr/sbin/ip link set ${network[$C3]} type bridge stp_state 0                  #
/usr/sbin/ip link set ${network[$C3]} up                                       #
#                                                                              #
fi                                                                             #
#                                                                              #
fi                                                                             #
C1=$((C1+3))                                                                   #
C2=$((C2+3))                                                                   #
C3=$((C3+3))                                                                   #
C4=$((C4+1))                                                                   #
done                                                                           #
/usr/sbin/brctl show                                                           #
sleep $ActionTimer                                                             #
clear                                                                          #
#                                                                              #
#################### End Set The SteelHead to Failover #########################
Condition="5"
else
echo " "
fi
done
