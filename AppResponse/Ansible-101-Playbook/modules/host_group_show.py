#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: host_group_show
author: Wim Verhaeghe (@rvbd-wimv)
short_description: Show the hostgroups available in a Riverbed AppResponse appliance
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
"""
EXAMPLES = """
#Usage Example
    - name: Get hostgroups on the AppResponse
      host_group_show:
        host: 192.168.1.1
        username: admin
        password: admin
      register: results
      
    - name: Show hostgroups available on the AppResponse 
      debug: var=results
"""
RETURN = r'''
output:
    description: Available hostgroups on the AppResponse
    returned: always
    type: list
'''


from ansible.module_utils.basic import AnsibleModule
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth


class HostGroupApp(AppResponseApp):

    def __init__(self):
        super(AppResponseApp).__init__()

    def main(self,module):

            total = []
            headers = ['id', 'name', 'active', 'definition']
            data = [[hg.id, hg.name, hg.data.enabled, hg.data.hosts]
                    for hg in self.appresponse.classification.get_hostgroups()
                    ]
            total.append(headers)
            total.append(data)
            module.exit_json(changed=False,output=total)


def main():
    fields = {
        "host": {"required":True, "type": "str"},
        "username": {"required":True, "type": "str"},
        "password": {"required":True, "type": "str", "no_log":True}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp()
    t.appresponse = my_ar

    t.main(module)


if __name__ == '__main__':
    main()
