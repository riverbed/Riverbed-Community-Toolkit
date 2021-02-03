#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: host_group_add
short_description: Add a hostgroup to Riverbed AppResponse appliance
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
    hostgroup_name:
        description:
            - Name of the AppResponse hostgroup
        required: True
    hostgroup_hosts:
        description:
            - List of hosts groups to be added to the AppResponse hostgroup
        required: True
"""
EXAMPLES = """
#Usage Example
    - name: Add a hostgroup to the AppResponse
      host_group_add:
        host: 192.168.1.1
        username: admin
        password: admin
        hostgroup_name: my_hostgroup_name
        hostgroup_hosts: 10.10.10.0/24,192.168.3.4/32,192.168.10.10
      register: results
    - debug: var=results
"""
RETURN = r'''
msg:
    description: Status on creating the hostgroup
    returned: always
    type: str
'''

from ansible.module_utils.basic import AnsibleModule
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.classification import HostGroupConfig
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth
from steelscript.common.exceptions import RvbdHTTPException


class HostGroupApp(AppResponseApp):

    def __init__(self,name,hosts):
        super(AppResponseApp).__init__()
        self.name = name
        self.hosts = hosts

    def main(self,module):

        try:
            hg = HostGroupConfig(name=self.name,
                                 hosts=self.hosts.split(','),
                                 enabled=True)
            ret = self.appresponse.classification.create_hostgroup(hg)
            results = "Successfully created hostgroup '{}'".format(ret.data.name)
            module.exit_json(changed=True,msg=results)

        except RvbdHTTPException as e:
            results = "Error creating hostgroup '{}'".format(self.name)
            module.fail_json(changed=False, msg=results, reason=str(e))

def main():
    fields = {
        "host": {"required": True, "type": "str"},
        "username": {"required": True, "type": "str"},
        "password": {"required": True, "type": "str", "no_log": True},
        "hostgroup_name": {"required": True, "default": None, "type": "str"},
        "hostgroup_hosts": {"required": True, "default": None, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_name'],module.params['hostgroup_hosts'])
    t.appresponse = my_ar

    t.main(module)


if __name__ == '__main__':
    main()
