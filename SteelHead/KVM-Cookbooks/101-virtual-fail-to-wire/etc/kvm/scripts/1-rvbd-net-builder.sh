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
# This script will detect all physical network interfaces on the host Linux server and 
# allow you to assign interfaces to your SteelHead-v.
#
#
#
clear

########################## Query the host server for the physical NICs ####################################
#                                                                                                         #
IFS=$'\n' array=( $(ls -l /sys/class/net/ | awk '$NF~/\/devices\/(platform|pci)/{print $9}'))             #
#                                                                                                         #
# Add two additional elements to the array for user's to select (None and Quit)                           #
array=( "${array[@]}" "None" )                                                                            #
array=( "${array[@]}" "Quit" )                                                                            #
#echo ${#array[@]} # Will count the number of physical interfaces on the Linux host.                      #
echo " "                                                                                                  #
echo "********************************************************************************************"       #
echo "*   CAUTION!! Do not use the physical interface assigned for management of the Linux Host! *"       #
echo "********************************************************************************************"       #
echo " "                                                                                                  #
echo " "                                                                                                  #
echo "********************************************************************************************"       #
echo "*      Ask the customer which physical interfaces are available for this deployment!       *"       #
echo "********************************************************************************************"       #
echo " "                                                                                                  #
echo " "                                                                                                  #
#                                                                                                         #
# Configure the Primary port                                                                              #
echo "********************************************************************************************"       #
echo " "                                                                                                  #
echo " "                                                                                                  #
echo "Select the number by a designated physical interface as Primary interface."                         #
echo " "                                                                                                  #
#                                                                                                         #
select Primary in "${array[@]}"; do                                                                       #
    case $Primary in                                                                                      #
        "") echo 'Invalid choice' >&2 ;;                                                                  #
        *)  break                                                                                         #
    esac                                                                                                  #
done                                                                                                      #
if [ "$Primary" == "Quit" ]; then                                                                         #
exit                                                                                                      #
fi                                                                                                        #
###################### End Query the host server for the physical NICs ####################################

#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do 
    printf "%s = %s\n" "$i" "${array[i]}"; 
clear
done
echo " "
echo " "
echo " "
echo "You selected physical interface $Primary for the Primary port."
echo " "
echo " "
# Configure the Aux port
echo "********************************************************************************************" 
echo " "
echo "Select the number by a designated physical interface as Aux interface."
echo " "
select Aux in "${array[@]}"; do
    case $Aux in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$Aux" == "Quit" ]; then
exit
fi
if [ "$Aux" == "None" ]; then
break 
fi
#####################################################################################
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo " "
echo "You selected physical interface $Aux for the Aux port."
echo " "
echo " "

# Configure the lan0_0 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as lan0_0 interface."
echo " "
select lan0_0 in "${array[@]}"; do
    case $lan0_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$lan0_0" == "Quit" ]; then
exit
fi

#############################################################################
# Remove used selection
#####################################################################################

printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $lan0_0 for the lan0_0 port."
echo " "
echo " "

# Configure the wan0_0 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as wan0_0 interface."
echo " "
select wan0_0 in "${array[@]}"; do
    case $wan0_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$wan0_0" == "Quit" ]; then
exit
fi


#############################################################################
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $wan0_0 for the wan0_0 port."
echo " "
echo " "

# Configure the lan1_0 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as lan1_0 interface."
echo " "
select lan1_0 in "${array[@]}"; do
    case $lan1_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$lan1_0" == "Quit" ]; then
exit
fi

#############################################################################
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $lan1_0 for the 1an1_0 port."
echo " "
echo " "

# Configure the wan1_0 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as wan1_0 interface."
echo " "
select wan1_0 in "${array[@]}"; do
    case $wan1_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$wan1_0" == "Quit" ]; then
exit
fi
#############################################################################
# Remove used selection

#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $wan1_0 for the wan1_0 port."
echo " "
echo " "


# Configure the lan0_1 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as lan0_1 interface."
echo " "
select lan0_1 in "${array[@]}"; do
    case $lan0_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$lan0_1" == "Quit" ]; then
exit
fi
#############################################################################
# Remove used selection

#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $lan0_1 for the lan0_1 port."
echo " "
echo " "


# Configure the wan0_1 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as wan0_1 interface."
echo " "
select wan0_1 in "${array[@]}"; do
    case $wan0_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$wan0_1" == "Quit" ]; then
exit
fi
#############################################################################
# Remove used selection
clear
echo " " 
echo " " 




#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $wan0_1 for the wan0_1 port."
echo " "
echo " "


# Configure the lan1_1 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as lan1_1 interface."
echo " "
select lan1_1 in "${array[@]}"; do
    case $lan1_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$lan1_1" == "Quit" ]; then
exit
fi

#############################################################################
# Remove used selection

clear
echo " " 
echo " " 
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#array[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${array[i]}";
clear
done
echo " "
echo "You selected physical interface $lan1_1 for the lan1_1 port."
echo " "
echo " "

# Configure the wan1_1 port
echo "********************************************************************************************" 
echo "Select the number by a designated physical interface as wan1_1 interface."
echo " "
select wan1_1 in "${array[@]}"; do
    case $wan1_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$wan1_1" == "Quit" ]; then
exit
fi

#############################################################################
# Remove used selection
clear
echo " " 
echo " " 
echo "You selected physical interface $wan1_1 for the wan1_1 port."
echo " "
echo " "
echo "********************************************************************************************" 
echo " "

echo "Primary: $Primary" 
echo "Aux: $Aux"  
echo " "
echo " "
echo "Lan0_0: $lan0_0"  
echo "WAN0_0: $wan0_0" 
echo " "
echo " "
echo "LAN1_0: $lan1_0" 
echo "WAN1_0: $wan1_0" 
echo " "
echo " "
echo "LAN0_1: $lan0_1"
echo "WAN0_1: $wan0_1"
echo " "
echo " " 
echo "LAN1_1: $lan1_1"
echo "WAN1_1: $wan1_1"

IFS=$'\n' array=( $(ls -l /sys/class/net/ | awk '$NF~/\/devices\/(platform|pci)/{print $9}'))

# Add two additional elements to the array for user's to select (None and Quit)
#array=( "${array[@]}" "None" )
#array=( "${array[@]}" "Quit" )
echo " "
echo ${#array[@]}

array2=( "${array2[@]}" "Primary" "$Primary" )
array2=( "${array2[@]}" "Aux" "$Aux" )
array2=( "${array2[@]}" "lan0_0" "$lan0_0" )
array2=( "${array2[@]}" "wan0_0" "$wan0_0" )
array2=( "${array2[@]}" "lan1_0" "$lan1_0" )
array2=( "${array2[@]}" "wan1_0" "$wan1_0" )
array2=( "${array2[@]}" "lan0_1" "$lan0_1" )
array2=( "${array2[@]}" "wan0_1" "$wan0_1" )
array2=( "${array2[@]}" "lan1_1" "$lan1_1" )
array2=( "${array2[@]}" "wan1_1" "$wan1_1" )

echo ${#array2[@]}

vnets=("${#array2[@]}")
vnets=$((vnets-2))
echo "$vnets"
clear

echo ${array2[@]}

echo " "
echo " "

int1=("shabr0" "shabr1" "shabr2" "shabr3" "shabr4" "shabr5" "shabr6" "shabr7" "shabr8" "shabr9" "None" "Quit")
#echo ${int1[@]}

clear
echo " "
echo " "

echo "Select the number by a designated bridged interface for the Primary on $Primary."
echo " "
select primary in "${int1[@]}"; do
    case $Primary in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$primary" == "Quit" ]; then
exit
fi
if [ "$primary" == "None" ]; then
break
fi
# Remove used selection

#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
done
clear
########################################################################################
if [ "$Aux" = "None" ]; then
echo " "
INT5='Will you use Data Store Sync with the Aux Interface? '
echo "$INT5"
echo " "
echo " "
echo " "
int5=("Yes" "No" "Quit")
select ADSS in "${int5[@]}"; do
    case $ADSS in
        "Yes")
            echo " "
            echo "You selected $ADSS for Data Store Sync"
            break
            ;;
        "No")
            echo " "
            echo "You selected $ADSS for Data Store Sync"
            aux="None"
            break
            ;;
       "Quit")
            echo "User requested exit"
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
fi
########################################################################################

if [ "$Aux" != "None" ] || [ "$ADSS" != "No" ]; then
echo "Select the number by a designated bridged interface for the Aux on $Aux."
echo " "
select aux in "${int1[@]}"; do
    case $aux in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$aux" == "Quit" ]; then
exit
fi
if [ "$aux" == "None" ]; then
break
fi
# Remove used selection

#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
done
clear
echo " "
echo " "
echo "You selected bridged interface $aux for the Aux port on $Aux."
echo " "
################################################################
# Remove the last shabr selection


################################################################
else
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi

########################################################################################
if [ "$lan0_0" != "None" ]; then

echo "Select the number by a designated bridged interface for the LAN0_0 on $lan0_0."
echo " "
select LAN0_0 in "${int1[@]}"; do
    case $LAN0_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$LAN0_0" == "Quit" ]; then
exit
fi
if [ "$LAN0_0" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $LAN0_0 for the LAN0_0 port on $lan0_0."
echo " "
########################################################################################
else
LAN0_0="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi








########################################################################################
if [ "$wan0_0" != "None" ]; then
echo "Select the number by a designated bridged interface for the WAN0_0 on $wan0_0."
echo " "
select WAN0_0 in "${int1[@]}"; do
    case $WAN0_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$WAN0_0" == "Quit" ]; then
exit
fi
if [ "$WAN0_0" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $WAN0_0 for the WAN0_0 port on $wan0_0."
echo " "
########################################################################################
else
WAN0_0="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi
########################################################################################
if [ "$lan1_0" != "None" ]; then
echo "Select the number by a designated bridged interface for the LAN1_0 on $lan1_0."
echo " "
select LAN1_0 in "${int1[@]}"; do
    case $LAN1_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$LAN1_0" == "Quit" ]; then
exit
fi
if [ "$LAN1_0" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $LAN1_0 for the LAN1_0 port on $lan1_0."
echo " "
########################################################################################
else
LAN1_0="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi
########################################################################################
if [ "$wan1_0" != "None" ]; then
echo "Select the number by a designated bridged interface for the WAN1_0 on $wan1_0."
echo " "
select WAN1_0 in "${int1[@]}"; do
    case $WAN1_0 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$WAN1_0" == "Quit" ]; then
exit
fi
if [ "$WAN1_0" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $WAN1_0 for the WAN1_0 port on $wan1_0."
echo " "
########################################################################################
else
WAN1_0="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi
########################################################################################
if [ "$lan0_1" != "None" ]; then
echo "Select the number by a designated bridged interface for the LAN0_1 on $lan0_1."
echo " "
select LAN0_1 in "${int1[@]}"; do
    case $LAN0_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$LAN0_1" == "Quit" ]; then
exit
fi
if [ "$LAN0_1" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $LAN0_1 for the LAN0_1 port on $lan0_1."
echo " "
########################################################################################
else
LAN0_1="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi
########################################################################################
if [ "$wan0_1" != "None" ]; then
echo "Select the number by a designated bridged interface for the WAN0_1 on $wan0_1."
echo " "
select WAN0_1 in "${int1[@]}"; do
    case $WAN0_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$WAN0_1" == "Quit" ]; then
exit
fi
if [ "$WAN0_1" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $WAN0_1 for the WAN0_1 port on $wan0_1."
echo " "
########################################################################################
else
WAN0_1="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
fi
########################################################################################
if [ "$lan1_1" != "None" ]; then
echo "Select the number by a designated bridged interface for the LAN1_1 on $lan1_1."
echo " "
select LAN1_1 in "${int1[@]}"; do
    case $LAN1_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$LAN1_1" == "Quit" ]; then
exit
fi
if [ "$LAN1_1" == "None" ]; then
break
fi
# Remove used selection
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
#clear
done
clear
echo " "
echo " "
echo "You selected bridged interface $LAN1_1 for the LAN1_1 port on $lan1_1."
echo " "
########################################################################################
else
LAN1_1="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
for (( i=0; i<${#int1[@]}; i++ )); do
    if [[ ${int1[i]} == $FIELD ]]; then
        int1=( "${int1[@]:0:$i}" "${int1[@]:$((i + 1))}" )
        i=$((i - 1))
    fi
done
fi
########################################################################################
if [ "$wan1_1" != "None" ]; then
echo "Select the number by a designated bridged interface for the WAN1_1 on $wan1_1."
echo " "
select WAN1_1 in "${int1[@]}"; do
    case $WAN1_1 in
        "") echo 'Invalid choice' >&2 ;;
        *)  break
    esac
done
if [ "$WAN1_1" == "Quit" ]; then
exit
fi
if [ "$WAN1_1" == "None" ]; then
break
fi
# Remove used selection
for (( i=0; i<${#int1[@]}; i++ )); do
    if [[ ${int1[i]} == $WAN1_1 ]]; then
        int1=( "${int1[@]:0:$i}" "${int1[@]:$((i + 1))}" )
        i=$((i - 1))
    fi
done
if [ "$WAN1_1" == "None" ]; then
int1=( "${int1[@]}" "None" )
fi
#####################################################################################
printf "\n%s\n" "After:"
for (( i=0; i<${#int1[@]}; i++ )); do
    printf "%s = %s\n" "$i" "${int1[i]}";
done
clear
echo " "
echo " "
echo "You selected bridged interface $WAN1_1 for the WAN1_1 port on $wan1_1."
echo " "
########################################################################################
else
WAN1_1="None"
BRcount=( "${#int1[@]}")
BRcount=$((BRcount-3)) # Remember that 0 also counts
FIELD=${int1[$BRcount]}
#echo "Removed field $FIELD"
#echo " "
# Remove last option
for (( i=0; i<${#int1[@]}; i++ )); do
    if [[ ${int1[i]} == $FIELD ]]; then
        int1=( "${int1[@]:0:$i}" "${int1[@]:$((i + 1))}" )
        i=$((i - 1))
    fi
done
fi
########################################################################################

#################################### Add Primary Routes ##########################################
clear                                                                                            #
echo " "                                                                                         #
echo "****************************************************************************** "           #
echo " "                                                                                         #
echo -n "Enter an IP address for Bridged Interface $primary \"IPA\" "                            #
read IPA                                                                                         #
echo " "                                                                                         #
echo "****************************************************************************** "           #
clear                                                                                            #
echo " "                                                                                         #
echo "****************************************************************************** "           #
echo " "                                                                                         #
echo -n "Enter the subnet mask for IP Address:$IPA on Bridged Interface: $primary \"SNM\" "      #
read SNM                                                                                         #
echo " "                                                                                         #
echo " "                                                                                         #
clear                                                                                            #
echo " "                                                                                         #
echo "****************************************************************************** "           #
echo " "                                                                                         #
echo -n "Enter the Default Gateway for IP Address:$IPA on Bridged Interface: $primary \"DFG\" "  #
read DFG                                                                                         #
echo " "                                                                                         #
echo "****************************************************************************** "           #
clear                                                                                            #
echo " "                                                                                         #
echo " "                                                                                         #
##################################################################################################


####################################     Add WAN Routes ##########################################
clear                                                                                            #
echo " "                                                                                         #
echo "****************************************************************************** "           #
echo " "                                                                                         #
echo -n "Enter an IP address for Bridged Interface $wan0_0 \"IPAW\" "                            #
read IPAW                                                                                        #
echo " "                                                                                         #
echo "****************************************************************************** "           #
clear                                                                                            #
echo " "                                                                                         #
echo "****************************************************************************** "           #
echo " "                                                                                         #
echo -n "Enter the subnet mask for IP Address:$IPAW on Bridged Interface: $wan0_0 \"SNMW\" "     #
read SNMW                                                                                        #
echo " "                                                                                         #
echo " "                                                                                         #
clear                                                                                            #
echo " "                                                                                         #
echo "****************************************************************************** "           #
echo " "                                                                                         #
echo -n "Enter the Default Gateway for IP Address:$IPAW on Bridged Interface: $wan0_0 \"DFGW\" " #
read DFGW                                                                                        #
echo " "                                                                                         #
echo "****************************************************************************** "           #
clear                                                                                            #
echo " "                                                                                         #
echo " "                                                                                         #
##################################################################################################

echo " "
net="/etc/kvm/scripts/network.cfg"
echo "primary" > $net
echo "$Primary" >> $net
echo "$primary" >> $net
echo "aux" >> $net
echo "$Aux" >> $net
echo "$aux" >> $net
echo "lan0_0" >> $net
echo "$lan0_0" >> $net
echo "$LAN0_0" >> $net
echo "wan0_0" >> $net
echo "$wan0_0" >> $net
echo "$WAN0_0" >> $net
echo "lan1_0" >> $net
echo "$lan1_0" >> $net
echo "$LAN1_0" >> $net
echo "wan1_0" >> $net
echo "$wan1_0" >> $net
echo "$WAN1_0" >> $net
echo "lan0_1" >> $net
echo "$lan0_1" >> $net
echo "$LAN0_1" >> $net
echo "wan0_1" >> $net
echo "$wan0_1" >> $net
echo "$WAN0_1" >> $net
echo "lan1_1" >> $net
echo "$lan1_1" >> $net
echo "$LAN1_1" >> $net
echo "wan1_1" >> $net
echo "$wan1_1" >> $net
echo "$WAN1_1" >> $net



PRIMARY=( "${PRIMARY[@]}" "$Primary" ) # Physical Interface
PRIMARY=( "${PRIMARY[@]}" "$primary" ) # Bridge Interface

AUX=( "${AUX[@]}" "$Aux" ) # Physical Interface
AUX=( "${AUX[@]}" "$aux" ) # Bridge Interface

LAN0_0=( "${LAN0_0[@]}" "$lan0_0" ) # Physical Interface
LAN0_0=( "${LAN0_0[@]}" "$LAN0_0" ) # Bridge Interface

WAN0_0=( "${WAN0_0[@]}" "$wan0_0" ) # Physical Interface
WAN0_0=( "${WAN0_0[@]}" "$WAN0_0" ) # Bridge Interface

LAN1_0=( "${LAN1_0[@]}" "$lan1_0" ) # Physical Interface
LAN1_0=( "${LAN1_0[@]}" "$LAN1_0" ) # Bridge Interface

WAN1_0=( "${WAN1_0[@]}" "$wan1_0" ) # Physical Interface
WAN1_0=( "${WAN1_0[@]}" "$WAN1_0" ) # Bridge Interface

LAN0_1=( "${LAN0_1[@]}" "$lan0_1" ) # Physical Interface
LAN0_1=( "${LAN0_1[@]}" "$LAN0_1" ) # Bridge Interface

WAN0_1=( "${WAN0_1[@]}" "$wan0_1" ) # Physical Interface
WAN0_1=( "${WAN0_1[@]}" "$WAN0_1" ) # Bridge Interface

LAN1_1=( "${LAN1_1[@]}" "$lan1_1" ) # Physical Interface
LAN1_1=( "${LAN1_1[@]}" "$LAN1_1" ) # Bridge Interface

WAN1_1=( "${WAN1_1[@]}" "$wan1_1" ) # Physical Interface
WAN1_1=( "${WAN1_1[@]}" "$WAN1_1" ) # Bridge Interface



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

############### Report all network settings needed for configuration ###########
# This is the format SHA Iface name, Physical Ethernet port, Bridged iface name#
clear                                                                          #
echo " "                                                                       #
echo " "                                                                       #
echo "**********************************************************************"  #
echo "*                                                                    *"  #
echo "* Please write down your selections below to configure the SteelHead *"  #
echo "*                                                                    *"  #
echo "**********************************************************************"  #
C1="0"                                                                         #
C2="1"                                                                         #
C3="2"                                                                         #
readarray -t network < /etc/kvm/scripts/network.cfg # Read in network.cfg file #
echo " "                                                                       #
echo "SteelHead Port    Physical Port   Bridged Port"                          #
while [ $C3 != 32 ]                                                            #
do                                                                             #
if [ ${network[$C2]} != "None" ] || [ ${network[$C3]} != "None" ]; then        #
                                                                               #
                                                                               #
echo "${network[$C1]}           ${network[$C2]}         ${network[$C3]} "      #
                                                                               #
fi                                                                             #
C1=$((C1+3))                                                                   #
C2=$((C2+3))                                                                   #
C3=$((C3+3))                                                                   #
done                                                                           #
echo " "                                                                       #
echo " "                                                                       #
############# End Report all network settings needed for configuration #########