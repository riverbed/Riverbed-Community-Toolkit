#!/usr/bin/env python

# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

"""
Host Group information on AppResponse appliance:
Upload file for host group creation
format: <hostgroup_name> <subnet_1>,<subnet_2>
"""

__author__ = "Wim Verhaeghe"
__email__ = "wim.verhaeghe@riverbed.com"
__version__= "1"

from ansible.module_utils.basic import *
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth
from steelscript.appresponse.core.classification import HostGroupConfig
from steelscript.common.exceptions import RvbdHTTPException



class HostGroupApp(AppResponseApp):

    def __init__(self,file):
        super(AppResponseApp).__init__()
        self.file = file

    def main(self):

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
                result = "Successfully uploaded {} hostgroup definitions.".format(len(hgs))
            return result

        except RvbdHTTPException:
            results = "Error uploading hostgroup definitions, one of hostgroups already exist"
            return results


def main():
    fields = {
        "host": {"type": "str"},
        "username": {"type": "str"},
        "password": {"type": "str"},
        "hostgroup_file": {"type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_file'])
    t.appresponse = my_ar

    results = t.main()

    module.exit_json(changed=True, meta=results)


if __name__ == '__main__':
    main()
