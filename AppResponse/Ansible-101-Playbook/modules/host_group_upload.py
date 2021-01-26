#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: host_group_upload
author: Wim Verhaeghe (@rvbd-wimv)
short_description: Upload a file with hostgroups to Riverbed AppResponse appliance
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
    hostgroup_file:
        description:
            - Name of the file which contains the hostgroups to be uploaded to the AppResponse appliance
            - Format <hostgroup_name> <subnet_1>,<subnet_2>
        required: True
"""
EXAMPLES = """
#Usage Example
    - name: Upload a list of hostgroups to the AppResponse
      host_group_upload:
        host: 192.168.1.1
        username: admin
        password: admin
        hostgroup_file: my_hostgroup_file.txt
      register: results
    - debug: var=results
"""
RETURN = r'''
msg:
    description: Status on uploading the hostgroup file
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

    def __init__(self,file):
        super(AppResponseApp).__init__()
        self.file = file

    def main(self,module):

        try:

            with open(self.file) as f:
                hgs = []
                for ln in f.readlines():
                    if not ln:
                        continue
                    name, *hosts = ln.split()
                    hosts = ' '.join([str(elem) for elem in hosts])
                    hgs.append(HostGroupConfig(name=name,
                                               hosts=hosts.split(','),
                                               enabled=True))
                self.appresponse.classification.create_hostgroups(hgs)
                results = "Successfully uploaded {} hostgroup definitions.".format(len(hgs))
                module.exit_json(changed=True,msg=results)


        except RvbdHTTPException as e:
            results = "Error uploading hostgroup definitions"
            module.fail_json(changed=False,msg=results,reason=str(e))



def main():
    fields = {
        "host": {"required":True, "type": "str"},
        "username": {"required":True, "type": "str"},
        "password": {"required":True, "type": "str", "no_log":True},
        "hostgroup_file": {"required":True, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_file'])
    t.appresponse = my_ar

    t.main(module)


if __name__ == '__main__':
    main()
