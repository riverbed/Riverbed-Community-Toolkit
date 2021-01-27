# 1. Ansible Client Accelerator Controller module generic

Here is a example of an [ansible module](modules/cac_rest_api.py) showing how to connect to the Client Accelerator Controller REST API.

## Usage:
be sure to use the updated version of the steelscript common/service.py

```shell
#mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#cp modules/cac_rest_api.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#ansible-playbook cac_get_api_info.yml
```

# 2. Ansible Client Accelerator Controller module endpoint details

Here is a example of an [ansible module](modules/cac_get_endpoint_details.py) showing how to get specific endpoint details on the Client Accelerator Controller via the REST API.


## Usage:
be sure to use the updated version of the steelscript common/service.py

```shell
#mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#cp modules/cac_get_endpoint_details.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
#ansible-playbook cac_get_api_info.yml
```


## Example output:

[ouput.txt](output.txt)


## Copyright (c) 2021 Riverbed Technology