# 1. Ansible Netprofiler module - Hostgroup (create, update) from json file

Here is a example of an [ansible module](modules/create_hostgroup_from_json) creating a Hostgroup on the Netprofiler.  
Here is a example of an [ansible module](modules/update_hostgroup_from_json) updating a Hostgroup on the Netprofiler.  

## Usage:

```shell
mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
cp modules/create_hostgroup_from_json /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
cp modules/update_hostgroup_from_json /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
ansible-playbook create_hostgroup.yml
```

## Example output:

[output.txt](output_hostgroups.txt)


## Copyright (c) 2021 Riverbed Technology
