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
##### Identify all of the Interfaces and their MAC Addresses ####
clear                                                           #
FILE="/etc/udev/rules.d/70-persistent-net.rules"                #
rm $FILE -f                                                     #
IFS=$'\n' MAC=( $( ip -o link  | awk '{print $2,$(NF-4)}' ))    #
echo "$2 "                                                      #
echo "$2 "                                                      #
MAX="${#MAC[$C3]}"                                              #
C3="0"                                                          #
rm /etc/kvm/scripts/rvbd-mac.cfg -f                             #
touch /etc/kvm/scripts/rvbd-mac.cfg                             #
macs="/etc/kvm/scripts/rvbd-mac.cfg"                            #
while [ $C3 != $MAX ]                                           #
do                                                              #
first_word=$(expr "${MAC[$C3]}" : '\([^[:space:]]\+\)')         #
Interface=${first_word//\:/}                                    #
#                                                               #
ADDRESS=$(echo ${MAC[$C3]})                                     #
ADDRESS=$(echo ${ADDRESS%%,*}) # trim off the .                 #
ADDRESS=$(echo ${ADDRESS##* }) # trim off the .                 #
#                                                               #
if [[ $Interface != shabr* ]] && [[ $Interface != ""  ]]; then  #
if [[ $Interface != "lo"  ]]; then                              #
if [[ $ADDRESS != "00:00:00:00:00:00"  ]]; then                 #
echo "MAC Address: $ADDRESS "                                   #
echo "Interface: $Interface "                                   #
#                                                               #
macs="/etc/kvm/scripts/rvbd-mac.cfg"                            #
echo "$Interface" >> $macs                                      #
string="$ADDRESS"                                               #
uppercase_string=$(echo "$string" | tr '[:lower:]' '[:upper:]') #
ADDRESS="$uppercase_string"                                     #
echo "$ADDRESS" >> $macs                                        #
PERS="SUBSYSTEM=="\""net"\"", ACTION=="\""add"\"", DRIVERS=="\""?*"\"", ATTR{address}=="\""$ADDRESS"\"", ATTR{dev_id}=="\""0x0"\"", ATTR{type}=="\""1"\"", NAME="\""$Interface"\"""                       #
echo "$PERS" >> $FILE                                           #
echo " "                                                        #
fi                                                              #
fi                                                              #
else                                                            #
exit                                                            #
fi                                                              #
C3=$((C3+1))                                                    #
done                                                            #
## End Identify all of the Interfaces and their MAC Addresses ###

~
~

