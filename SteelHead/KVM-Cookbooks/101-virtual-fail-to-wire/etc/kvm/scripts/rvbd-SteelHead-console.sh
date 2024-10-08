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
# This script enables console access to the running SteelHead
# Use Ctl and ] together to  exit the console 
clear
echo " "
echo " "
echo " "
echo " Use Ctl and ] together to exit the console instance. "
echo " "
echo " "
sleep 4
/usr/bin/virsh console VeSHA1
