#!/bin/bash
log_path="/etc/bootLog.txt"
if [ -f "$log_path" ]
then
    echo "Cloud Init script already ran earlier during first time boot.." >> $log_path
else
    touch $log_path
SSHKey="${sshkey}"
KeyDir="/home/admin/.ssh"
KeyFile="/home/admin/.ssh/authorized_keys"
DirMasterIP="${dir_master_mgmt_ip}"
DirSlaveIP="${dir_slave_mgmt_ip}"
Address="Match Address $DirMasterIP,$DirSlaveIP"
SSH_Conf="/etc/ssh/sshd_config"
echo "Starting cloud init script..." > $log_path

echo "Modifying /etc/network/interface file.." >> $log_path
cp /etc/network/interfaces /etc/network/interfaces.bak
cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp
offload-gro off

auto eth1
iface eth1 inet dhcp
offload-gro off

auto eth2
iface eth2 inet dhcp
offload-gro off

auto eth3
iface eth3 inet dhcp
offload-gro off
EOF
echo -e "Modified /etc/network/interface file. Refer below new interface file content:\n`cat /etc/network/interfaces`" >> $log_path

echo -e "Injecting ssh key into admin user.\n" >> $log_path
if [ ! -d "$KeyDir" ]; then
    echo -e "Creating the .ssh directory and injecting the SSH Key.\n" >> $log_path
    sudo mkdir $KeyDir
    sudo echo $SSHKey >> $KeyFile
    sudo chown admin:versa $KeyDir
    sudo chown admin:versa $KeyFile
    sudo chmod 600 $KeyFile
elif ! grep -Fq "$SSHKey" $KeyFile; then
    echo -e "Key not found. Injecting the SSH Key.\n" >> $log_path
    sudo echo $SSHKey >> $KeyFile
    sudo chown admin:versa $KeyDir
    sudo chown admin:versa $KeyFile
    sudo chmod 600 $KeyFile
else
    echo -e "SSH Key already present in file: $KeyFile.." >> $log_path
fi

echo -e "Enanbling ssh login using password from Director to Controller required for first time login durin Controller on boarding." >> $log_path
if ! grep -Fq "$Address" $SSH_Conf; then
    echo -e "Adding the match address exception for Director Management IP required for first time login durin Controller on boarding.\n" >> $log_path
    sed -i.bak "\$a\Match Address $DirMasterIP,$DirSlaveIP\n  PasswordAuthentication yes\nMatch all" $SSH_Conf
    sudo service ssh restart
else
    echo -e "Director Management IP address is alredy present in file $SSH_Conf.\n" >> $log_path
fi
fi
