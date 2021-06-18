# 1. Ansible AppResponse Python modules - List sources

Here is a example of an [ansible module](modules/list_sources.py) showing how to connect to the AppResponse.

## Usage:

```shell
mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
cp modules/list_sources.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
ansible-playbook list_sources.yml
```

## Example output:

[output.txt](output_list_sources.txt)


# 2. Ansible AppResponse Python module - Host groups (add, delete, update, upload, show)

Here is an example of an [ansible module](modules/host_group_show.py) showing the AppResponse (AR11) host groups.  
Here is an example of an [ansible module](modules/host_group_add.py) adding a Host Group to the AppResponse (AR11).  
Here is an example of an [ansible module](modules/host_group_delete.py) deleting a Host Group of the AppResponse (AR11).  
Here is an example of an [ansible module](modules/host_group_update.py) updating a Host Group of the AppResponse (AR11).  
Here is an example of an [ansible module](modules/host_group_upload.py) uploading a list of Host Groups to the AppResponse (AR11).

## Usage:

```shell
mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
cp modules/host_group*.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
ansible-playbook host_groups.yml
```

## Example output:

[output.txt](output_host_groups.txt)


# 3. Ansible AppResponse Python module - Bootstrap

Here is an example of an [ansible module](modules/bootstrap.py) that handles initial setup of the AppResponse appliance.

## Usage
```shell
mkdir /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
cp modules/bootstrap.py /usr/lib/python3/dist-packages/ansible/modules/network/riverbed
ansible-playbook bootstrap.yml
```

## Copyright (c) 2021 Riverbed Technology
