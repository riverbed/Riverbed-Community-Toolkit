# 1. Ansible NetIM module - IP subnet to group mappings file from txt file

Here is a example of an [ansible module](modules/create_ip_subnet_to_group_mapping.py) extracting hostgroup information from a Netprofiler putting it into a txt file and upload it to a NetIM as the IP subnet to hostgroup mappings file.  

## Usage:

```shell
mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
cp modules/create_ip_subnet_to_group_mapping.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
ansible-playbook create_file.yml
```

## Example output:

[output.txt](output.txt)


## Copyright (c) 2021 Riverbed Technology
