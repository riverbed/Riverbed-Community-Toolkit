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
clear
echo " "
echo " "
############################################################################################
  INT1='Select the speed of interface ethr0 (top NIC on the left in cluster of four.): '   #
echo "$INT1"                                                                               #
int1=("100" "1000" "Quit")                                                                 #
select speed_ethr0 in "${int1[@]}"; do                                                     #
    case $speed_ethr0 in                                                                   #
        "100")                                                                             #
            echo "You set the speed to $speed_ethr0"                                       #
            break                                                                          #
            ;;                                                                             #
        "1000")                                                                            #
            echo "You set the speed to  $speed_ethr0"                                      #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the duplex of interface ethr0 (top NIC on the left in cluster of four.): '  #
echo "$INT1"                                                                               #
int1=("half" "full" "Quit")                                                                #
select duplex_ethr0 in "${int1[@]}"; do                                                    #
    case $duplex_ethr0 in                                                                  #
        "half")                                                                            #
            echo "You set the duplex to $duplex_ethr0"                                     #
            break                                                                          #
            ;;                                                                             #
        "full")                                                                            #
            echo "You set the to duplex $duplex_ethr0"                                     #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the autonegotiation for ethr0 (top NIC on the left in cluster of four.): '  #
echo "$INT1"                                                                               #
int1=("off" "on" "Quit")                                                                   #
select neg_ethr0 in "${int1[@]}"; do                                                       #
    case $neg_ethr0 in                                                                     #
        "off")                                                                             #
            echo "You set the autonegotiate to $neg_ethr0"                                 #
            break                                                                          #
            ;;                                                                             #
        "on")                                                                              #
            echo "You set the to duplex $neg_ethr0"                                        #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
sleep 2                                                                                    #
clear                                                                                      #
############################################################################################

############################################################################################
  INT1='Select the speed of interface ethr1 (top NIC on the right in cluster of four.): '  #
echo "$INT1"                                                                               #
int1=("100" "1000" "Quit")                                                                 #
select speed_ethr1 in "${int1[@]}"; do                                                     #
    case $speed_ethr1 in                                                                   #
        "100")                                                                             #
            echo "You set the speed to $speed_ethr1"                                       #
            break                                                                          #
            ;;                                                                             #
        "1000")                                                                            #
            echo "You set the speed to  $speed_ethr1"                                      #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the duplex of interface ethr1 (top NIC on the right in cluster of four.): ' #
echo "$INT1"                                                                               #
int1=("half" "full" "Quit")                                                                #
select duplex_ethr1 in "${int1[@]}"; do                                                    #
    case $duplex_ethr1 in                                                                  #
        "half")                                                                            #
            echo "You set the duplex to $duplex_ethr1"                                     #
            break                                                                          #
            ;;                                                                             #
        "full")                                                                            #
            echo "You set the to duplex $duplex_ethr1"                                     #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the autonegotiation for ethr1 (top NIC on the right in cluster of four.): ' #
echo "$INT1"                                                                               #
int1=("off" "on" "Quit")                                                                   #
select neg_ethr1 in "${int1[@]}"; do                                                       #
    case $neg_ethr1 in                                                                     #
        "off")                                                                             #
            echo "You set the autonegotiate to $neg_ethr1"                                 #
            break                                                                          #
            ;;                                                                             #
        "on")                                                                              #
            echo "You set the to duplex $neg_ethr1"                                        #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
sleep 2                                                                                    #
clear                                                                                      #
############################################################################################

############################################################################################
  INT1='Select the speed of interface ethr2 (bottom NIC on the left in cluster of four.): '#
echo "$INT1"                                                                               #
int1=("100" "1000" "Quit")                                                                 #
select speed_ethr2 in "${int1[@]}"; do                                                     #
    case $speed_ethr2 in                                                                   #
        "100")                                                                             #
            echo "You set the speed to $speed_ethr2"                                       #
            break                                                                          #
            ;;                                                                             #
        "1000")                                                                            #
            echo "You set the speed to  $speed_ethr2"                                      #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the duplex of interface ethr2 (bottom NIC on the left in cluster of four.):'#
echo "$INT1"                                                                               #
int1=("half" "full" "Quit")                                                                #
select duplex_ethr2 in "${int1[@]}"; do                                                    #
    case $duplex_ethr2 in                                                                  #
        "half")                                                                            #
            echo "You set the duplex to $duplex_ethr2"                                     #
            break                                                                          #
            ;;                                                                             #
        "full")                                                                            #
            echo "You set the to duplex $duplex_ethr2"                                     #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the autonegotiation for ethr2 (bottom NIC on the left in cluster of four.):'#
echo "$INT1"                                                                               #
int1=("off" "on" "Quit")                                                                   #
select neg_ethr2 in "${int1[@]}"; do                                                       #
    case $neg_ethr2 in                                                                     #
        "off")                                                                             #
            echo "You set the autonegotiate to $neg_ethr2"                                 #
            break                                                                          #
            ;;                                                                             #
        "on")                                                                              #
            echo "You set the to duplex $neg_ethr2"                                        #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
sleep 2                                                                                    #
clear                                                                                      #
############################################################################################

###############################    Set Up NIC Speed     ####################################
INT1='Select the speed of interface ethr3 (bottom NIC on right in cluster of four.): '     #
echo "$INT1"                                                                               #
int1=("100" "1000" "Quit")                                                                 #
select speed_ethr3 in "${int1[@]}"; do                                                     #
    case $speed_ethr3 in                                                                   #
        "100")                                                                             #
            echo "You set the speed to $speed_ethr3"                                       #
            break                                                                          #
            ;;                                                                             #
        "1000")                                                                            #
            echo "You set the speed to  $speed_ethr3"                                      #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the duplex of interface ethr3 (bottom NIC on right in cluster of four.): '  #
echo "$INT1"                                                                               #
int1=("half" "full" "Quit")                                                                #
select duplex_ethr3 in "${int1[@]}"; do                                                    #
    case $duplex_ethr3 in                                                                  #
        "half")                                                                            #
            echo "You set the duplex to $duplex_ethr3"                                     #
            break                                                                          #
            ;;                                                                             #
        "full")                                                                            #
            echo "You set the to duplex $duplex_ethr3"                                     #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
 INT1='Select the autonegotiation for ethr3 (bottom NIC on right in cluster of four.): '   #
echo "$INT1"                                                                               #
int1=("off" "on" "Quit")                                                                   #
select neg_ethr3 in "${int1[@]}"; do                                                       #
    case $neg_ethr3 in                                                                     #
        "off")                                                                             #
            echo "You set the autonegotiate to $neg_ethr3"                                 #
            break                                                                          #
            ;;                                                                             #
        "on")                                                                              #
            echo "You set the to duplex $neg_ethr3"                                        #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
sleep 2                                                                                    #
clear                                                                                      #
##############################  End Set Up Nic Speed  ######################################

###############################    Set Up NIC Speed     ####################################
INT1='Select the speed of interface ethr4 (bottom NIC on right in cluster of four.): '     #
echo "$INT1"                                                                               #
int1=("100" "1000" "Quit")                                                                 #
select speed_ethr4 in "${int1[@]}"; do                                                     #
    case $speed_ethr4 in                                                                   #
        "100")                                                                             #
            echo "You set the speed to $speed_ethr4"                                       #
            break                                                                          #
            ;;                                                                             #
        "1000")                                                                            #
            echo "You set the speed to  $speed_ethr4"                                      #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the duplex of interface ethr4 (bottom NIC on right in cluster of four.): '  #
echo "$INT1"                                                                               #
int1=("half" "full" "Quit")                                                                #
select duplex_ethr4 in "${int1[@]}"; do                                                    #
    case $duplex_ethr4 in                                                                  #
        "half")                                                                            #
            echo "You set the duplex to $duplex_ethr4"                                     #
            break                                                                          #
            ;;                                                                             #
        "full")                                                                            #
            echo "You set the to duplex $duplex_ethr4"                                     #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
 INT1='Select the autonegotiation for ethr4 (bottom NIC on right in cluster of four.): '   #
echo "$INT1"                                                                               #
int1=("off" "on" "Quit")                                                                   #
select neg_ethr4 in "${int1[@]}"; do                                                       #
    case $neg_ethr4 in                                                                     #
        "off")                                                                             #
            echo "You set the autonegotiate to $neg_ethr4"                                 #
            break                                                                          #
            ;;                                                                             #
        "on")                                                                              #
            echo "You set the to duplex $neg_ethr4"                                        #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
sleep 2                                                                                    #
clear                                                                                      #
##############################  End Set Up Nic Speed  ######################################

###############################    Set Up NIC Speed     ####################################
INT1='Select the speed of interface ethr5 (bottom NIC on right in cluster of four.): '     #
echo "$INT1"                                                                               #
int1=("100" "1000" "Quit")                                                                 #
select speed_ethr5 in "${int1[@]}"; do                                                     #
    case $speed_ethr5 in                                                                   #
        "100")                                                                             #
            echo "You set the speed to $speed_ethr5"                                       #
            break                                                                          #
            ;;                                                                             #
        "1000")                                                                            #
            echo "You set the speed to  $speed_ethr5"                                      #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
  INT1='Select the duplex of interface ethr5 (bottom NIC on right in cluster of four.): '  #
echo "$INT1"                                                                               #
int1=("half" "full" "Quit")                                                                #
select duplex_ethr5 in "${int1[@]}"; do                                                    #
    case $duplex_ethr5 in                                                                  #
        "half")                                                                            #
            echo "You set the duplex to $duplex_ethr5"                                     #
            break                                                                          #
            ;;                                                                             #
        "full")                                                                            #
            echo "You set the to duplex $duplex_ethr5"                                     #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
echo " "                                                                                   #
echo " "                                                                                   #
 INT1='Select the autonegotiation for ethr5 (bottom NIC on right in cluster of four.): '   #
echo "$INT1"                                                                               #
int1=("off" "on" "Quit")                                                                   #
select neg_ethr5 in "${int1[@]}"; do                                                       #
    case $neg_ethr5 in                                                                     #
        "off")                                                                             #
            echo "You set the autonegotiate to $neg_ethr5"                                 #
            break                                                                          #
            ;;                                                                             #
        "on")                                                                              #
            echo "You set the to duplex $neg_ethr5"                                        #
            break                                                                          #
            ;;                                                                             #
        "Quit")                                                                            #
            echo "User requested exit"                                                     #
            exit                                                                           #
            ;;                                                                             #
        *) echo "invalid option $REPLY";;                                                  #
    esac                                                                                   #
done                                                                                       #
sleep 2                                                                                    #
clear                                                                                      #
##############################  End Set Up Nic Speed  ######################################

#########################        Get NIC State        ##################################
clear                                                                                  #
echo " "                                                                               #
Interface="ethr"                                                                       #
W="0"                                                                                  #
U="5"                                                                                  #
while [ "$W" -le "$U" ]                                                                #
do                                                                                     #
Interface="ethr$W"                                                                     #
#                                                                                      #
IFS=$'\n' Speed=( $( /usr/sbin/ethtool $Interface | grep Speed: ) )                    #
IFS=$'\n' Duplex=( $( /usr/sbin/ethtool $Interface | grep Duplex: ) )                  #
IFS=$'\n' Negotiation=( $( /usr/sbin/ethtool $Interface | grep Auto-negotiation: ) )   #
LINK=$'\n' array=( $( /usr/bin/cat /sys/class/net/$Interface/operstate | tr -d '\r' ) )#
#                                                                                      #
Speed="${Speed//$'\t'/}" # Trim Tabs, Leading and Trailing spaces                      #
Duplex="${Duplex//$'\t'/}" # Trim Tabs, Leading and Trailing spaces                    #
Negotiation="${Negotiation//$'\t'/}" # Trim Tabs, Leading and Trailing spaces          #
#                                                                                      #
echo "Interface: $Interface"                                                           #
echo "Link State:${array[0]}"                                                          #
echo "$Speed "                                                                         #
echo "$Duplex"                                                                         #
echo "$Negotiation "                                                                   #
echo " "                                                                               #
echo " "                                                                               #
W=$((W+1))                                                                             #
done                                                                                   #
#########################      End Get NIC State      ##################################









