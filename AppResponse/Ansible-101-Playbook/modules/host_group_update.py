#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: host_group_update
short_description: Update a host group on the Riverbed AppResponse appliance
options:
    host:
        description:
            - Hostname or IP Address of the AppResponse appliance.
        required: True
    username:
        description:
            - Username used to login to the AppResponse appliance.
        required: True
    password:
        description:
            - Password used to login to the AppResponse appliance
        required: True
    hostgroup_id:
        description:
            - ID of the hostgroup to be updated on the AppResponse appliance
    hostgroup_name:
        description:
            - Name of the hostgroup to be updated on the AppResponse appliance
    hostgroup_hosts:
        description:
            - List of hosts to be updated on the selected hostgroup by Name or ID on the AppResponse appliance
"""
EXAMPLES = """
#Usage Example
    - name: Update a hostgroup on the AppResponse
      host_group_update:
        host: 192.168.1.1
        username: admin
        password: admin
        hostgroup_name: my_hostgroup_name
        hostgroup_hosts: 10.10.10.0/24,192.168.3.4/32,192.168.10.10
      register: results
    - debug: var=results
    
    - name: Update a hostgroup on the AppResponse
      host_group_update:
        host: 192.168.1.1
        username: admin
        password: admin
        hostgroup_id: 6
        hostgroup_hosts: 10.10.10.0/24,192.168.3.4/32,192.168.10.10
      register: results
    - debug: var=results
"""
RETURN = r'''
msg:
    description: Status on updating the hostgroup
    returned: always
    type: str
'''

from ansible.module_utils.basic import AnsibleModule
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth
from steelscript.appresponse.core.classification import HostGroupConfig
from steelscript.common.exceptions import RvbdHTTPException



class HostGroupApp(AppResponseApp):

    def __init__(self,id=None,name=None,hosts=None):
        super(AppResponseApp).__init__()
        self.id = id
        self.name = name
        self.hosts = hosts

    def main(self,module):

        try:

            if self.id:
                hg = self.appresponse.classification.get_hostgroup_by_id(
                    self.id)
            else:
                hg = self.appresponse.classification.get_hostgroup_by_name(
                    self.name)

            hgc = HostGroupConfig(name=self.name or hg.data.name,
                              hosts=(self.hosts.split(',')
                                     if self.hosts
                                     else hg.data.hosts),
                              enabled=True)
            hg.update(hgc)
            results = "Successfully updated hostgroup '{}'".format(hg.name)
            module.exit_json(changed=True,msg=results)

        except RvbdHTTPException as e:
            results = "Error updating hostgroup '{}'".format(self.name)
            module.fail_json(changed=False,msg=results,reason=str(e))



def main():
    fields = {
        "host": {"required": True, "type": "str"},
        "username": {"required": True, "type": "str"},
        "password": {"required": True, "type": "str", "no_log":True},
        "hostgroup_id": {"default": None, "type": "str"},
        "hostgroup_name": {"default": None, "type": "str"},
        "hostgroup_hosts": {"default": None, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_id'],module.params['hostgroup_name'],module.params['hostgroup_hosts'])
    t.appresponse = my_ar

    t.main(module)


if __name__ == '__main__':
    main()
