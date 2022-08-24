# Backup and restore of a Cloud SteelHead using Azure snopshots
The following cookbook contains a description of ansible playbooks that backup and restore a **Cloud SteelHead**.

## Backup or Restore the Cloud SteelHead using a docker container
Backup workflow consists of the following parts:  
1. Docker container which runs [Ansible](https://www.ansible.com/)

### Clone the Repo to your favourite location
```
cd myfavourite_location
git clone https://github.com/riverbed/Riverbed-Community-Toolkit.git
cd Riverbed-Community-Toolkit/SteelHead/104-Backup-and-Restore
```

### Building the Docker container
The custom Ansible container needs to be build with the following [docker-file](dockerfile-ansible).
```
docker build -t m_ansible:cloud_sh -f dockerfile-ansible .
```
Verify that the container image is existing:
```
docker images m_ansible:cloud_sh
```

## Backup

### Edit the ansible Backup playbook
```
vi SHCloud_Backup.yml
```
Change the vars section
```
  vars:
    steelhead_name: "Steelhead-name"                           #Steelhead to backup
    resource_group: "my_resource_group"                        #Resource group to monitor (export flows from)
```

### The Docker container
Run and connect to the docker container from the image.
```
docker run --rm -ti --name ansible_container -v $PWD:/app m_ansible:cloud_sh /bin/bash
```
Connect via the cli to Azure
```
#az login -u myusername@mydomain.com
```
Run the ansible playbook for Backup
```
#ansible-playbook -v SHCloud_BackUp.yml
```

Verify that the snapshots for the OSDisk and the DataDisk have been successfully created:
```
#az snapshot list -g myresource_group --query [].name -o tsv
```

Note down the names for the Restore

## Restore

### Edit the ansible Restore playbook
```
vi SHCloud_Restore.yml
```
Change the vars section:
```
 vars:
    steelhead_name: "SteelHead_Nmae"                                       #Steelhead name to restore
    resource_group: "myresource_group"                                       #Resource group to put the restore steelhead
    osdisk_snapshotname: "Name-osDisk-backup-epoch"
    datadisk_snapshotname: "Name-DataDisk-backup-epoch"
    NSG_group: "my_nsg_group"
    vnet_name: "my_vnet"
    subnet_name: "my_subnet"
    vm_size: "Standard_A2m_v2"                                         #size of the original steelhead ex. Standard A2m v2
```

### The Docker container
Run and connect to the docker container from the image.
```
docker run --rm -ti --name ansible_container -v $PWD:/app m_ansible:cloud_sh /bin/bash
```
Connect via the cli to Azure
```
#az login -u myusername@mydomain.com
```
Run the ansible playbook for Restore
```
#ansible-playbook -v SHCloud_Restore.yml
```

It can take about 10min before the SteelHead is fully operational and a restart services with data store clear could be required.


## Copyright (c) 2022 Riverbed Technology
