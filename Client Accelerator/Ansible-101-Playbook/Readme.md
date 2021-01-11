# Ansible Client Accelerator Controller module

Here is a example of an [ansible module](modules/cac_rest_api.py) showing how to connect to the Client Accelerator Controller API.

## Usage:
be sure to use the updated version of the steelscript common/service.py

```shell
#mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#cp modules/cac_rest_api.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#ansible-playbook cac_get_license.yml
```

## Example output:

[ouput.txt](ouput.txt)


## Copyright (c) 2021 Riverbed Technology