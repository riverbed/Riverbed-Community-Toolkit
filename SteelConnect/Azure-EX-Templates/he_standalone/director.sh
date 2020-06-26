#!/bin/bash
# Riverbed Community Toolkit
# SteelConnect-EX Director VM Initialization script

log_path="/var/log/riverbed-community-boot.log"
if [ -f "$log_path" ]
then
    if [ -s "$log_path" ] 
    then
        logger "Cloud Init user-data script: exiting"
        date >> $log_path
        echo "A previous execution has been detected ($log_path is not empty). This initialization script should run only once" | tee -a $log_path
        exit 500
    fi
else
    logger "Cloud Init user-data script: delaying execution in 2 minutes to avoid conflicts with first boot sequence"
    touch $log_path
    service atd start
    echo "bash /var/lib/cloud/instance/scripts/part-001" | at now + 2 minute
    exit 0
fi

logger "Cloud Init user-data script: starting..."
date >> $log_path

echo "Wait for all Director services to be up (when the VM looks ready for initialization)"  | tee -a $log_path
wait_time=30
retries_limit=5
counter=0
until [ `service vnms status | grep RUNNING | wc -l` -eq `service vnms status | wc -l` ];
do
    echo "Wait for VNMS services..." | tee -a $log_path
    sleep $wait_time
    ((counter++))
    if [ $counter -gt $retries_limit ]
    then
        echo "Cannot detect all VNMS services UP but will continue" | tee -a $log_path
        break
    fi
done

SSHKey="${sshkey}"
VanIP="${van_mgmt_ip}"
Address="Match Address $VanIP"

KeyDir="/home/Administrator/.ssh"
KeyFile="/home/Administrator/.ssh/authorized_keys"
SSH_Conf="/etc/ssh/sshd_config"

whoami >> $log_path
echo "Modify /etc/network/interface file" | tee -a $log_path
echo "Add a route to Overlay Network via the Azure default gateway of the subnet Control (the Azure Route Table has a route to forward to the Controller" | tee -a $log_path
cp /etc/network/interfaces /etc/network/interfaces.bak
cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system, see interfaces(5).

auto lo
iface lo inet loopback

# Management interface
auto eth0
iface eth0 inet dhcp

# Control interface
auto eth1
iface eth1 inet dhcp
    up route add -net ${overlay_net} gw ${azure_default_gw_ip_subnet_control} dev eth1
EOF
echo -e "Modified /etc/network/interface file. Refer below new interface file content:\n`cat /etc/network/interfaces`" >> $log_path

echo "Reset interface eth1" | tee -a $log_path
{ ifdown eth1  && ifup eth1 ;} >> $log_path

echo "Modify /etc/hosts file" | tee -a $log_path
cp /etc/hosts /etc/hosts.bak
cat > /etc/hosts << EOF
127.0.0.1           localhost localhost.localdomain
${dir_mgmt_ip}         ${hostname_dir}
${van_mgmt_ip}         ${hostname_van}

# The following lines are desirable for IPv6 capable hosts cloudeinit
::1localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
echo -e "Modified /etc/hosts file:\n`cat /etc/hosts`" >> $log_path

echo "Modifying /etc/hostname file.." | tee -a $log_path
hostname ${hostname_dir}
echo "${hostname_dir}" > /etc/hostname
echo "New hostname: `hostname`" | tee -a $log_path

echo "Inject ssh key into Administrator user" | tee -a $log_path
if [ ! -d "$KeyDir" ]; then
    echo -e "Creating the .ssh directory and injecting the SSH Key.\n" >> $log_path
    mkdir $KeyDir
    echo $SSHKey >> $KeyFile
    chown Administrator:versa $KeyDir
    chown Administrator:versa $KeyFile
    chmod 600 $KeyFile
elif ! grep -Fq "$SSHKey" $KeyFile; then
    echo -e "Key not found. Injecting the SSH Key.\n" >> $log_path
    echo $SSHKey >> $KeyFile
    chown Administrator:versa $KeyDir
    chown Administrator:versa $KeyFile
    chmod 600 $KeyFile
else
    echo -e "SSH Key already present in file: $KeyFile.." >> $log_path
fi

echo "Enabling ssh login using password." | tee -a $log_path
if ! grep -Fq "$Address" $SSH_Conf; then
    echo -e "Adding the match address exception for Analytics Management IP to install certificate.\n" >> $log_path
    sed -i.bak "\$a\Match Address $VanIP\n  PasswordAuthentication yes\nMatch all" $SSH_Conf
    service ssh restart
else
    echo "Analytics Management IP address is already present in file $SSH_Conf" | tee -a $log_path
fi

echo "Add south bound interface in setup.json file" | tee -a $log_path
cat > /opt/versa/etc/setup.json << EOF
{
    "input":{
        "version": "1.0",
        "south-bound-interface":[
          "eth1"
        ],
        "hostname": "${hostname_dir}"
     }
}
EOF
chown versa:versa /opt/versa/etc/setup.json
echo -e "Got below data from setup.json file:\n `cat /opt/versa/etc/setup.json`" >> $log_path

echo "Generate Director self signed certififcates" | tee -a $log_path
rm -Rf /var/versa/vnms/data/certs/
sudo -u versa /opt/versa/vnms/scripts/vnms-certgen.sh --cn ${hostname_dir} --storepass versa123 >> $log_path
chown -R versa:versa /var/versa/vnms/data/certs/

echo "Execute the startup script in non interactive mode" >> $log_path
# TODO: clean output, when vnms-startup script run as Administrator it generates a message "hostname: you must be root to change the host name" (not a big problem as the hostname has been set properly earlier)
sudo -u Administrator /opt/versa/vnms/scripts/vnms-startup.sh --non-interactive 
service vnms restart >> $log_path

date >> $log_path
echo "Done" | tee -a $log_path
logger "Cloud Init script: done"