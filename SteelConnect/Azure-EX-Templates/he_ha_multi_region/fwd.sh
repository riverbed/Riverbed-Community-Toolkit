#!/bin/bash
log_path="/etc/bootLog.txt"
if [ -f "$log_path" ]
then
    echo "Cloud Init script already ran earlier during first time boot.." >> $log_path
else
    touch $log_path
SSHKey="${sshkey}"
KeyDir="/home/versa/.ssh"
KeyFile="/home/versa/.ssh/authorized_keys"
Dir1IP="${dir_master_mgmt_ip}"
Dir2IP="${dir_slave_mgmt_ip}"
Address="Match Address $Dir1IP,$Dir2IP"
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

# The management network interface
auto eth0
iface eth0 inet dhcp

# The southbound network interface
auto eth1
iface eth1 inet dhcp
post-up ip route add ${ctrl_slave_net} via ${south_slave_gw} dev eth1
post-up ip route add ${ctrl_master_net} via ${south_slave_gw} dev eth1
post-up ip route add ${south_master_net} via ${south_slave_gw} dev eth1

# The cluster network interface
auto eth2
iface eth2 inet dhcp
post-up ip route add ${cluster_master_net} via ${cluster_slave_gw} dev eth2

EOF
echo -e "Modified /etc/network/interface file. Refer below new interface file content:\n`cat /etc/network/interfaces`" >> $log_path

echo "Modifying /etc/hosts file.." >> $log_path
cp /etc/hosts /etc/hosts.bak
cat > /etc/hosts << EOF
127.0.0.1	localhost
${dir_master_mgmt_ip}	${hostname_dir_master}
${dir_slave_mgmt_ip}	${hostname_dir_slave}
%{ for host, ip in analytics_host_map ~}
${ip}	${host}
%{ endfor ~}
%{ for host, ip in forwarder_host_map ~}
${ip}	${host}
%{ endfor ~}

# The following lines are desirable for IPv6 capable hosts cloudeinit
::1localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
echo -e "Modified /etc/hosts file. Refer below new hosts file content:\n`cat /etc/hosts`" >> $log_path

echo -e "Modifying /etc/hostname file.." >> $log_path
hostname ${hostname_fwd}
cp /etc/hostname /etc/hostname.bak
cat > /etc/hostname << EOF
${hostname_fwd}
EOF
echo -e "Hostname modified to : `hostname`" >> $log_path

echo -e "Injecting ssh key into versa user.\n" >> $log_path
if [ ! -d "$KeyDir" ]; then
    echo -e "Creating the .ssh directory and injecting the SSH Key.\n" >> $log_path
    sudo mkdir $KeyDir
sudo echo $SSHKey >> $KeyFile
sudo chown versa:versa $KeyDir
sudo chown versa:versa $KeyFile
sudo chmod 600 $KeyFile
elif ! grep -Fq "$SSHKey" $KeyFile; then
    echo -e "Key not found. Injecting the SSH Key.\n" >> $log_path
    sudo echo $SSHKey >> $KeyFile
    sudo chown versa:versa $KeyDir
    sudo chown versa:versa $KeyFile
    sudo chmod 600 $KeyFile
else
    echo -e "SSH Key already present in file: $KeyFile.." >> $log_path
fi

echo -e "Enanbling ssh login using password." >> $log_path
if ! grep -Fq "$Address" $SSH_Conf; then
	echo -e "Adding the match address exception for Director Management IPs to run cluster install scripts.\n" >> $log_path
        sed -i.bak "\$a\Match Address $Dir1IP,$Dir2IP\n  PasswordAuthentication yes\nMatch all" $SSH_Conf
        sudo service ssh restart
else
        echo -e "Director Management IP address is alredy present in file $SSH_Conf.\n" >> $log_path
fi
fi
