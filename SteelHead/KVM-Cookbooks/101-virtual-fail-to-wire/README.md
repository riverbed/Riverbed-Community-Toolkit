
# SteelHead Virtual Fail-to-Wire for KVM

With this cookbook, you can enable a virtual Fail-to-Wire for a KVM Virtual SteelHead Deployments
It supports Multiple In-Path Interface Failover.

This cookbook is open-source and shared on the [Riverbed Community Toolkit](https://github.com/riverbed/Riverbed-Community-Toolkit/tree/master/SteelHead/KVM-Cookbooks/101-virtual-fail-to-wire)

## Quick start

### Step 1. Package as a tar.gz

```shell
# Fetch a copy of the Riverbed-Community-Toolkit
wget https://github.com/riverbed/Riverbed-Community-Toolkit/archive/refs/heads/master.zip

# Expand
unzip master.zip

# Change directory
cd Riverbed-Community-Toolkit-master/SteelHead/KVM-Cookbooks/101-virtual-fail-to-wire/

# Package as a tar
tar -cvf rvbd-ftw.tar etc run usr

# Add license and readme inside the package (in the script folder)
tar --append --file=rvbd-ftw.tar --transform 's|^|etc/kvm/riverbed-community-toolkit/|' LICENSE.md README.md

# Compress the .tar into a .tar.gz
gzip rvbd-ftw.tar
```

### Step 2. Copy the rvbd-ftw.tar.gz file to your environment and deploy

```shell
tar xvzf rvbd-ftw.tar.gz -C / 
```

## How-to and notes

### Create a script to run at boot time

```shell
crontab -e
@reboot  /etc/kvm/scripts/rvbd-boot-up.sh
```

### Add shutdown process so we don't corrupt the virtual SteelHead

Modify the file: K2-rvbd-shutdown-VeSHA1-graceful
This file is located in the /etc/rc.d/rc5.d directory

## Modify the kernel to enable console port control

```shell
grubby --args=console=ttyS0, 9600 --update-kernel /boot/vmlinuz-5.14.0-427.28.1.el9_4.x86_64
```

## Create a service that will run as a service in the background.


Edit: /etc/systemd/system/cdp-watchdog.service

```
[Unit]
Description=CDP Watchdog
[Service]
Type=simple
ExecStart=/usr/sbin/cdp-watchdog.sh
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
```

Commands to manage the service:

- Enable

```shell
systemctl enable cdp-watchdog # Enables it as a service at boot
```

- Disable

```shell
systemctl disable cdp-watchdog # Disables it as a service at boot
```

- Start

```shell
systemctl start cdp-watchdog # starts the service from the CLI
```

- Stop

```shell
systemctl stop cdp-watchdog # Stops the service from the CLI
```

## Draft

```shell
cd /etc/rc.d/rc5.d 

vi /etc/rc.d/rc5.d/K2-rvbd-shutdown-VeSHA1-graceful

dos2unix rvbd-*

######### RVBD Shutdown Virtual SHA VeSHA1 Graceful ###########
/usr/bin/virsh destroy VeSHA1 --graceful                      #
###### End RVBD Shutdown Virtual SHA VeSHA1 Graceful ##########
```

## Package as tar

- Create tar file with all scripts

```shell
tar -czvf rvbd-ftw.tar.gz /etc/kvm/scripts/ /usr/sbin/cdp-watchdog.sh /etc/rc.d/rc5.d/K2-rvbd-shutdown-VeSHA1-graceful /etc/systemd/system/cdp-watchdog.service /etc/sysconfig/network-scripts/ /etc/udev/rules.d/70-persistent-net.rules /run/libvirt/qemu/VeSHA1.xml /etc/libvirt/qemu/VeSHA1.xml
```

- Extract the file

```shell
tar xvzf rvbd-ftw.tar.gz -C / 
```

## License

Copyright (c) 2021-2024 Riverbed Technology, Inc.

The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.