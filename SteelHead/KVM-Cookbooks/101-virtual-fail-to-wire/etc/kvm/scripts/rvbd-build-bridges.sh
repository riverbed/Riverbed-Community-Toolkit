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
#
#
#
############### Discover and tear down all bidged Interfaces####################
/usr/bin/systemctl stop NetworkManager.service                                 #
clear                                                                          #
D1="0"                                                                         #
B1="1"                                                                         #
IFS=$'\n' BRIDGES=( $(/usr/sbin/brctl show ) )                                 #
while [ $B1 -ne 20 ]                                                           #
do                                                                             #
first_word=$(expr "${BRIDGES[$B1]}" : '\([^[:space:]]\+\)')                    #
if [ -z "$first_word" ]                                                        #
then                                                                           #
D1=$((D1+1))                                                                   #
else                                                                           #
ip link delete $first_word                                                     #
fi                                                                             #
B1=$((B1+1))                                                                   #
done                                                                           #
################# Dynamically Build the bridged interfaces #####################
exit
################# Dynamically Build the bridged interfaces #####################
# This is the format primary eth1 shabr0                                       #
clear                                                                          #
echo " "                                                                       #
C1="0"                                                                         #
C2="1"                                                                         #
C3="2"                                                                         #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file #
echo " "                                                                       #
MAX=${#network[@]}                                                             #
echo "MAX $MAX "

while [ $MAX -gt $C3 ]                                                         #
do                                                                             #
if [ ${network[$C2]} != "None" ] || [ ${network[$C3]} != "None" ]; then        #
#echo "Setting up interface: ${network[$C1]} ${network[$C2]} ${network[$C3]} " #
/usr/sbin/ip link add ${network[$C3]} type bridge                              #
mac=$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/:$//')                      #
MAC="00-0e-b6:""$mac" # Include Riverbed Prefix MAC                            #
MAC=$(echo $MAC | tr "-" ":")                                                  #
#ifconfig ${network[$C3]} hw ether $MAC                                        #
/usr/sbin/ip link set ${network[$C2]} nomaster                                 #
/usr/sbin/ip link set ${network[$C2]} master ${network[$C3]}                   #
/usr/sbin/ip link set ${network[$C3]} type bridge stp_state 0                  #
/usr/sbin/ip link set ${network[$C3]} up                                       #
/usr/sbin/ip link set ${network[$C2]} down                                     #
/usr/sbin/ip link set ${network[$C2]} up                                       #
fi                                                                             #
C1=$((C1+3))                                                                   #
C2=$((C2+3))                                                                   #
C3=$((C3+3))                                                                   #
done                                                                           #
clear                                                                          #
/usr/sbin/brctl show                                                           #
############### End Dynamically Build the bridged interfaces ###################

###############################  Add Routes #########################################
L3="4"                                                                              #
L1="0"                                                                              #
readarray -t routing < /etc/kvm/scripts/routing.cfg # Read in routing.cfg file      #
ROUTE=${#routing[@]}                                                                #
L1=$ROUTE                                                                           #
while [ $ROUTE -gt $L3 ]                                                            #
do                                                                                  #
/usr/sbin/ip link set ${routing[($L1-4)]} up                                        #
/usr/sbin/ip a add ${routing[($L1-3)]}/${routing[($L1-2)]} dev ${routing[($L1-4)]}  #
L1=$((L1/2))                                                                        #
L3=$((L3+5))                                                                        #
done                                                                                #
echo " "                                                                            #
echo " "                                                                            #
/usr/sbin/route                                                                     #
echo " "                                                                            #
################################### End Add Routes ##################################
