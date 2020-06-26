#!/bin/bash
# Riverbed Community Toolkit
# SteelConnect-EX Analytics VM Initialization script

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
    logger "Cloud Init user-data script: delaying execution in 3 minutes to avoid conflicts with first boot sequence"
    touch $log_path
    service atd start
    echo "bash /var/lib/cloud/instance/scripts/part-001" | at now + 3 minute
    exit 0
fi

logger "Cloud Init user-data script: starting..."
date >> $log_path

echo "Wait for at least 5 Analytics services to be up (when the VM looks ready for initialization)"  | tee -a $log_path
wait_time=30
retries_limit=5
counter=0
until [ `service versa-analytics status | grep Running | wc -l` -ge 5 ];
do
    echo "Wait for Analytics services..." | tee -a $log_path
    sleep $wait_time
    ((counter++))
    if [ $counter -gt $retries_limit ]
    then
        echo "Cannot detect all Analytics services UP but will continue" | tee -a $log_path
        break
    fi
done

SSHKey="${sshkey}"
VanIP="${van_mgmt_ip}"
DirManagementIP="${dir_mgmt_ip}"
hostname_dir="${hostname_dir}"

KeyDir="/home/versa/.ssh"
KeyFile="/home/versa/.ssh/authorized_keys"

whoami >> $log_path
echo "Modify /etc/network/interface file"  | tee -a $log_path
echo "Add a route to Overlay Network via the Azure default gateway of the subnet Control (the Azure Route Table has a route to forward to the Controller" >> $log_path
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

echo "Modifying /etc/hosts file.." | tee -a $log_path
cp /etc/hosts /etc/hosts.bak
cat > /etc/hosts << EOF
127.0.0.1    localhost localhost.localdomain
$VanIP    ${hostname_van}
$DirManagementIP    ${hostname_dir}

# The following lines are desirable for IPv6 capable hosts cloudeinit
::1localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
echo -e "Modified /etc/hosts file. Refer below new hosts file content:\n`cat /etc/hosts`" | tee -a $log_path

echo "Modify /etc/hostname file" | tee -a $log_path
hostname ${hostname_van}
echo "${hostname_van}" > /etc/hostname
echo "New hostname: `hostname`" | tee -a $log_path

echo -e "Injecting ssh key into versa user" | tee -a $log_path
if [ ! -d "$KeyDir" ]; then
    echo -e "Creating the .ssh directory and injecting the SSH Key.\n" >> $log_path
    mkdir $KeyDir
    echo $SSHKey >> $KeyFile
    chown versa:versa $KeyDir
    chown versa:versa $KeyFile
    chmod 600 $KeyFile
elif ! grep -Fq "$SSHKey" $KeyFile; then
    echo -e "Key not found. Injecting the SSH Key.\n" >> $log_path
    echo $SSHKey >> $KeyFile
    chown versa:versa $KeyDir
    chown versa:versa $KeyFile
    chmod 600 $KeyFile
else
    echo -e "SSH Key already present in file: $KeyFile.." >> $log_path
fi

echo "Import certificates from director - (director must be up)" | tee -a $log_path
echo "Hardcoding cleartext password is bad" | tee -a $log_path
# TODO: fix connector to avoid any password hardcoding
sshpass -p versa123 scp  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$DirManagementIP:/var/versa/vnms/data/certs/versa_director_client.cer /opt/versa/var/van-app/certificates >> $log_path

echo "Install certificates (van-vd-cert-install.py)" | tee -a $log_path
/opt/versa/scripts/van-scripts/van-vd-cert-install.sh /opt/versa/var/van-app/certificates/versa_director_client.cer $hostname_dir >> $log_path

echo "Delete database manually" | tee -a $log_path
rm -Rf /opt/versa/scripts/van-scripts/vaninit.done
rm -Rf /var/lib/cassandra/*

echo "Run vansetup (skip interaction but without --force to block the reboot)"  | tee -a $log_path
python /opt/versa/scripts/van-scripts/vansetup.py --skip-interactive --force >> $log_path 2>&1

echo "Configure log-collector-exporter"  | tee -a $log_path
cli_file="/tmp/configure-analytics-cli-task"
cat > $cli_file << EOF
configure
set log-collector-exporter local collectors VAN address ${analytics_control_ip} port ${analytics_port} storage directory /var/tmp/log format syslog
commit
show log-collector-exporter
EOF
cat $cli_file >> $log_path
/opt/versa/confd/bin/confd_cli -u versa $cli_file >> $log_path 2>&1

date >> $log_path
echo "Done" | tee -a $log_path
logger "Cloud Init script: done"
