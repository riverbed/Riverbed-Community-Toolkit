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
##################################################################################
sudo rm ifcfg-* -f                                                               #
#                                                                                #
readarray -t MACS < /etc/kvm/scripts/rvbd-mac.cfg # Read in rvbd-mac.cfg file    #
echo "${MACS[@]} "                                                               #
Counter=${#MACS[@]}                                                              #
K="0"                                                                            #
while [[ $Counter -gt $K ]]                                                      #
do                                                                               #
echo "$K: ${MACS[$K]} "                                                          #
sleep 1                                                                          #
#Variables should be auto-populated                                              #
NicName="${MACS[$K]}"                                                            #
NicMAC="${MACS[((K+1))]}"                                                        #
#                                                                                #
DNS1="none"                                                                      #
DNS2="none"                                                                      #
DNS3="none"                                                                      #
IPADDR="none"                                                                    #
NETMASK="none"                                                                   #
GATEWAY="none"                                                                   #
#                                                                                #
echo "IP ADDRESS: $IPADDR "                                                      #
##################################################################################

####################### Build ifcfg Files ##########
sudo rm test.txt -f                                #
#                                                  #
Line=" "                                           #
/usr/bin/systemctl stop NetworkManager.service     #
# Run this before building any bridged interfaces  #
#                                                  #
#IFCFG Baseline information fed into array IFCFG   # 
IFCFG=("TYPE=Ethernet" "PROXY_METHOD=none" "NAME="\"$NicName"\"" "DEVICE=$NicName" "BOOTPROTO=none" "BOOTPROTO=static" "BROWSER_ONLY=no" "IPADDR=$IPADDR" "NETMASK=$NETMASK" "GATEWAY=$GATEWAY" "PREFIX=24"  "DNS1=$DNS1" "DNS2=$DNS2" "DNS3=$DNS3" "HWADDR=$NicMAC" "DEFROUTE=yes" "PEERDNS=no" "PEERROUTES=no" "IPV4_FAILURE_FATAL=no" "IPV6INIT=no" "IPV6_AUTOCONF=no" "IPV6_DEFROUTE=no" "IPV6_FAILURE_FATAL=no" "IPV6_ADDR_GEN_MODE=default" "ONBOOT=yes" "AUTOCONNECT_PRIORITY=-999") #
#                                                          #
ArraySize=${#IFCFG[@]}                                     #
#                                                          #
Line="/etc/sysconfig/network-scripts/ifcfg-$NicName"       #
sudo rm /etc/sysconfig/network-scripts/ifcfg-$NicName -f   #
for each in "${IFCFG[@]}"                                  #
do                                                         #
  echo "$each"                                             #
echo "$each" >> $Line                                      #
if [[ $E -gt $ArraySize ]]; then                           #
#                                                          #
break                                                      #
fi                                                         #
E=$((E+1))                                                 #
done                                                       #
E="0"                                                      #
K=$((K+2))                                                 #
done                                                       #
clear                                                      #
############ End Build IFCFG Files #########################

