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
################################################################################
#                                                                              #
# This file needs to be added to the host's crontab to run at boot.            #
# Create a script to run at boot time                                          #
# crontab -e                                                                   #
# @reboot  /etc/kvm/scripts/rvbd-boot-up.sh                                    #
#                                                                              #
#                                                                              #
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
/usr/sbin/ip link delete $first_word                                           #
fi                                                                             #
B1=$((B1+1))                                                                   #
done                                                                           #
/usr/sbin/ip route flush table main # Destroys ALL ROUTES                      #
################# Dynamically Build the bridged interfaces #####################

################# Dynamically Build the bridged interfaces ###############################
# This is the format primary eth1 shabr0                                                 #
clear                                                                                    #
echo " "                                                                                 #
C1="0"                                                                                   #
C2="1"                                                                                   #
C3="2"                                                                                   #
readarray -t network < /etc/kvm/scripts/rvbd-network.cfg # Read file                     #
echo " "                                                                                 #
MAX=${#network[@]}                                                                       #
while [ $MAX -gt $C3 ]                                                                   #
do                                                                                       #
if [ ${network[$C2]} != "None" ] || [ ${network[$C3]} != "None" ]; then                  #
#echo "Setting up interface: ${network[$C1]} ${network[$C2]} ${network[$C3]} "           #
/usr/sbin/ip link add ${network[$C3]} type bridge                                        #
mac=$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/:$//')                                #
MAC="00-0e-b6:""$mac" # Include Riverbed Prefix MAC                                      #
MAC=$(echo $MAC | tr "-" ":")                                                            #
#ifconfig ${network[$C3]} hw ether $MAC                                                  #
/usr/sbin/ip link set ${network[$C2]} nomaster                                           #
/usr/sbin/ip link set ${network[$C2]} master ${network[$C3]}                             #
/usr/sbin/ip link set ${network[$C3]} type bridge stp_state 0                            #
/usr/sbin/ip link set ${network[$C3]} up                                                 #
/usr/sbin/ip link set ${network[$C2]} down                                               #
/usr/sbin/ip link set ${network[$C2]} up                                                 #
fi                                                                                       #
C1=$((C1+3))                                                                             #
C2=$((C2+3))                                                                             #
C3=$((C3+3))                                                                             #
done                                                                                     #
clear                                                                                    #
echo " "                                                                                 #
echo "*********************************************************************************" #
/usr/sbin/brctl show                                                                     #
echo "*********************************************************************************" #
echo " "                                                                                 #
################## End Dynamically Build the bridged interfaces ##########################

###############################  Add Routes #########################################
/usr/sbin/ip route flush table main # Destroys ALL ROUTES                           #
#                                                                                   #
L3="0"                                                                              #
L1="0"                                                                              #
readarray -t routing < /etc/kvm/scripts/rvbd-routing.cfg # Read in file             #
ROUTE=${#routing[@]}                                                                #
L1=$ROUTE                                                                           #
while [ $L3 -le $ROUTE ]                                                            #
do                                                                                  #
################################################################################################################
ip=${routing[($L1-3)]}                                                                                         #
mask=${routing[($L1-2)]}                                                                                       #
IFS=. read -r i1 i2 i3 i4 <<< "$ip"                                                                            #
IFS=. read -r m1 m2 m3 m4 <<< "$mask"                                                                          #
################################################################################################################
NETWORK="$((i1 & m1)).$((i2 & m2)).$((i3 & m3)).$((i4 & m4))"                                                  #
/usr/sbin/ip a add ${routing[($L1-3)]}/${routing[($L1-2)]} dev ${routing[($L1-4)]}                             #
/usr/sbin/ip link set ${routing[($L1-4)]} up                                                                   #
/usr/sbin/ip route add $NETWORK dev ${routing[($L1-4)]}                                                        #
/usr/sbin/ip route add default via ${routing[($L1-1)]}                                                         #
L1=$((L1-5))                                                                                                   #
L3=$((L3+5))                                                                                                   #
done                                                                                                           #
echo " "                                                                                                       #
echo "*********************************************************************************"                       #
echo "network:   $((i1 & m1)).$((i2 & m2)).$((i3 & m3)).$((i4 & m4))"                                          #
echo "broadcast: $((i1 & m1 | 255-m1)).$((i2 & m2 | 255-m2)).$((i3 & m3 | 255-m3)).$((i4 & m4 | 255-m4))"      #
echo "first IP:  $((i1 & m1)).$((i2 & m2)).$((i3 & m3)).$(((i4 & m4)+1))"                                      #
echo "last IP:   $((i1 & m1 | 255-m1)).$((i2 & m2 | 255-m2)).$((i3 & m3 | 255-m3)).$(((i4 & m4 | 255-m4)-1))"  #
echo "*********************************************************************************"                       #
echo " "                                                                                                       #
echo "*********************************************************************************"                       #
/usr/sbin/route                                                                                                #
echo "*********************************************************************************"                       #
echo " "                                                                                                       #
echo " "                                                                                                       #
########################################### End Add Routes #####################################################
