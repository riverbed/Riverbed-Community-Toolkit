#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: host_group_delete
short_description: delete a hostgroup from Riverbed AppResponse appliance
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
            - ID of the AppResponse hostgroup to delete
    hostgroup_name:
        description:
            - Name of the AppResponse hostgroup to delete
"""
EXAMPLES = """
#Usage Example
    - name: Delete a hostgroup by hostgroup name on the AppResponse
      host_group_delete:
        host: 192.168.1.1
        username: admin
        password: admin
        hostgroup_name: my_hostgroup_name
      register: results
    - debug: var=results
    
    - name: Delete a hostgroup by hostgroup ID on the AppResponse
      host_group_delete:
        host: 192.168.1.1
        username: admin
        password: admin
        hostgroup_id: 6
      register: results
    - debug: var=results
"""
RETURN = r'''
msg:
    description: Status on deletion of the hostgroup
    returned: always
    type: str
'''


from ansible.module_utils.basic import AnsibleModule
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth
from steelscript.common.exceptions import RvbdHTTPException


class HostGroupApp(AppResponseApp):

    def __init__(self,id=None,name=None):
        super(AppResponseApp).__init__()
        self.id = id
        self.name = name


    def main(self,module):

        try:
            if self.id:
                hg = self.appresponse.classification.get_hostgroup_by_id(
                    self.id)
            else:
                hg = self.appresponse.classification.get_hostgroup_by_name(
                    self.name)

            hg.delete()
            results = "Successfully deleted hostgroup with ID/name {}".format(self.id or self.name)
            module.exit_json(changed=True,msg=results)

        except RvbdHTTPException as e:
            results = "Error deleting hostgroup with ID/name {}".format(self.id or self.name)
            module.fail_json(changed=False,msg=results,reason=str(e))

def main():
    fields = {
        "host": {"required": True, "type": "str"},
        "username": {"required": True, "type": "str"},
        "password": {"required": True, "type": "str", "no_log": True},
        "hostgroup_id": {"default": None, "type": "str"},
        "hostgroup_name": {"default": None, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_id'],module.params['hostgroup_name'])
    t.appresponse = my_ar

    t.main(module)


if __name__ == '__main__':
    main()
