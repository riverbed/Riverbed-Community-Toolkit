#!/bin/bash
# Riverbed Community Toolkit
# SteelConnect-EX Controller VM Initialization script

log_path="/var/log/riverbed-community-boot.log"
if [ -f "$log_path" ]
then
	logger "Cloud Init user-data script: exiting"
	date >> $log_path
	echo "A previous execution has been detected ($log_path is not empty). This initialization script should run only once" | tee -a $log_path
	exit 500
else
    touch $log_path
fi

logger "Cloud Init user-data script: starting..."
date >> $log_path

SSHKey="${sshkey}"
DirIP="${dir_mgmt_ip}"
Address="Match Address $DirIP"

KeyDir="/home/admin/.ssh"
KeyFile="/home/admin/.ssh/authorized_keys"
SSH_Conf="/etc/ssh/sshd_config"

echo "Modify /etc/network/interface file.." | tee -a $log_path
cp /etc/network/interfaces /etc/network/interfaces.bak
cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system, see interfaces(5).

auto lo
iface lo inet loopback

# Management interface
auto eth0
iface eth0 inet dhcp
offload-gro off

auto eth1
iface eth1 inet dhcp
offload-gro off

auto eth2
iface eth2 inet dhcp
offload-gro off
EOF
echo -e "Modified /etc/network/interface file. Refer below new interface file content:\n`cat /etc/network/interfaces`" | tee -a $log_path

echo "Modifying /etc/hosts file.." | tee -a $log_path
echo "127.0.0.1 localhost localhost.localdomain" >> /etc/hosts
echo -e "Modified /etc/hosts file:\n`cat /etc/hosts`" | tee -a $log_path

echo "Injecting ssh key into admin user" | tee -a $log_path
if [ ! -d "$KeyDir" ]; then
	echo "Creating the .ssh directory and injecting the SSH Key" | tee -a $log_path
	mkdir $KeyDir
	echo $SSHKey >> $KeyFile
	chown admin:versa $KeyDir
	chown admin:versa $KeyFile
	chmod 600 $KeyFile
elif ! grep -Fq "$SSHKey" $KeyFile; then
	echo "Key not found. Injecting the SSH Key" | tee -a $log_path
	echo $SSHKey >> $KeyFile
	chown admin:versa $KeyDir
	chown admin:versa $KeyFile
	chmod 600 $KeyFile
else
    echo "SSH Key already present in file: $KeyFile" | tee -a $log_path
fi

echo -e "Enabling ssh login using password from Director to Controller required for first time login durin Controller on boarding." >> $log_path
if ! grep -Fq "$Address" $SSH_Conf; then
    echo -e "Adding the match address exception for Director Management IP required for first time login durin Controller on boarding.\n" >> $log_path
    sed -i.bak "\$a\Match Address $DirIP\n  PasswordAuthentication yes\nMatch all" $SSH_Conf
    service ssh restart
else
    echo "Director Management IP address is alredy present in file $SSH_Conf" | tee -a $log_path
fi

date >> $log_path
echo "Done" | tee -a $log_path
logger "Cloud Init script: done"
