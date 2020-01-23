#!/bin/bash
log_path="/etc/bootLog.txt"
if [ -f "$log_path" ]
then
    echo "Cloud Init script already ran earlier during first time boot.." >> $log_path
else
    touch $log_path
SSHKey="${sshkey}"
KeyDir="/home/Administrator/.ssh"
KeyFile="/home/Administrator/.ssh/authorized_keys"
Van1IP="${van_1_mgmt_ip}"
Van2IP="${van_2_mgmt_ip}"
Address="Match Address $Van1IP,$Van2IP"
SSH_Conf="/etc/ssh/sshd_config"
PrefixLength=`echo "${mgmt_master_net}"| cut -d'/' -f2`
MgmtGW=`echo "${mgmt_slave_net}"|cut -d '.' -f1-3`.1
echo "Starting cloud init script...." > $log_path

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

# The secondary network interface
auto eth1
iface eth1 inet static
        address ${dir_slave_ctrl_ip}/$PrefixLength
EOF
echo -e "Modified /etc/network/interface file. Refer below new interface file content:\n`cat /etc/network/interfaces`" >> $log_path

echo "Adding static routes to /etc/rc.local" >> $log_path
cp /etc/rc.local /etc/rc.local.bak
cat > /etc/rc.local << EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
while [ "$(ip link show eth1 up)" == "" ]; do sleep 1; done
/sbin/ip route add ${mgmt_master_net} via $MgmtGW
/sbin/ip route add ${ctrl_slave_net} via ${router2_dir_ip}
/sbin/ip route add ${master_net} via ${router2_dir_ip}
/sbin/ip route add ${overlay_net} via ${router2_dir_ip}
exit 0
EOF
echo -e "Modified /etc/rc.local file. Routes added:\n`cat /etc/rc.local`" >> $log_path

echo "Modifying /etc/hosts file.." >> $log_path
cp /etc/hosts /etc/hosts.bak
cat > /etc/hosts << EOF
127.0.0.1			localhost
${dir_master_mgmt_ip}			${hostname_dir_master}
${dir_slave_mgmt_ip}			${hostname_dir_slave}
${van_1_mgmt_ip}			${hostname_van_1}
${van_2_mgmt_ip}			${hostname_van_2}

# The following lines are desirable for IPv6 capable hosts cloudeinit
::1localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
echo -e "Modified /etc/hosts file. Refer below new hosts file content:\n`cat /etc/hosts`" >> $log_path

echo "Moditing /etc/hostname file.." >> $log_path
hostname ${hostname_dir_slave}
cp /etc/hostname /etc/hostname.bak
cat > /etc/hostname << EOF
${hostname_dir_slave}
EOF
echo "Hostname modified to : `hostname`" >> $log_path

echo -e "Injecting ssh key into Administrator user.\n" >> $log_path
if [ ! -d "$KeyDir" ]; then
	echo -e "Creating the .ssh directory and injecting the SSH Key.\n" >> $log_path
	sudo mkdir $KeyDir
	sudo echo $SSHKey >> $KeyFile
	sudo chown Administrator:versa $KeyDir
	sudo chown Administrator:versa $KeyFile
	sudo chmod 600 $KeyFile
elif ! grep -Fq "$SSHKey" $KeyFile; then
	echo -e "Key not found. Injecting the SSH Key.\n" >> $log_path
	sudo echo $SSHKey >> $KeyFile
	sudo chown Administrator:versa $KeyDir
	sudo chown Administrator:versa $KeyFile
	sudo chmod 600 $KeyFile
else
	echo -e "SSH Key already present in file: $KeyFile.." >> $log_path
fi

echo -e "Enanbling ssh login using password." >> $log_path
if ! grep -Fq "$Address" $SSH_Conf; then
	echo -e "Adding the match address exception for Analytics Management IP to install certificate.\n" >> $log_path
	sed -i.bak "\$a\Match Address $Van1IP,$Van2IP\n  PasswordAuthentication yes\nMatch all" $SSH_Conf
	sudo service ssh restart
else
	echo -e "Analytics Management IP address is alredy present in file $SSH_Conf.\n" >> $log_path
fi

echo "Adding north bond and south bond interface in setup.json file.." >> $log_path
cat > /opt/versa/etc/setup.json << EOF
{
	"input":{
		"version": "1.0",
		"south-bound-interface":[
		  "eth1"
		],
		"hostname": "${hostname_dir_slave}"
	 }
}
EOF
echo -e "Got below data from setup.json file:\n `cat /opt/versa/etc/setup.json`" >> $log_path
echo "Executing rc.local to install routes..." >> $log_path
sudo source /etc/rc.local
echo -e "Resulting route table:\n `route`" >> $log_path
echo "Executing the startup script in non interactive mode.." >> $log_path
sudo -u Administrator /opt/versa/vnms/scripts/vnms-startup.sh --non-interactive
fi
