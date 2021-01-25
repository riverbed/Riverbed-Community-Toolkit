# 1. Ansible AppResponse11 module - list sources

Here is a example of an [ansible module](modules/list_sources.py) showing how to connect to the AppResponce (AR11).

## Usage:

```shell
#mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#cp modules/list_sources.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#ansible-playbook list_sources.yml
```

## Example output:

[output.txt](output_list_sources.txt)


# 2. Ansible AppResponse11 module - Host groups (add, delete, update, upload, show)

Here is an example of an [ansible module](modules/host_group_show.py) showing the AppResponce (AR11) host groups.  
Here is an example of an [ansible module](modules/host_group_add.py) adding a hostgroup to the AppResponce (AR11).  
Here is an example of an [ansible module](modules/host_group_delete.py) deleting a hostgroup of the AppResponce (AR11).  
Here is an example of an [ansible module](modules/host_group_update.py) updating a hostgroup of the AppResponce (AR11).  
Here is an example of an [ansible module](modules/host_group_upload.py) uploading a list of hostgroups to the AppResponce (AR11).


## Usage:

```shell
#mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#cp modules/host_group*.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#ansible-playbook host_groups.yml
```

## Example output:

[output.txt](output_host_groups.txt)



## Copyright (c) 2021 Riverbed Technology