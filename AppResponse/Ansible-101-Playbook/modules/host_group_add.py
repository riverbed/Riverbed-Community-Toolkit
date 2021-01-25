#!/usr/bin/env python

# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

"""
Host Group information on AppResponse appliance:
Add one host group
"""

__author__ = "Wim Verhaeghe"
__email__ = "wim.verhaeghe@riverbed.com"
__version__= "1"

from ansible.module_utils.basic import *
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

    def main(self):

        try:
            hg = HostGroupConfig(name=self.name,
                                 hosts=self.hosts.split(','),
                                 enabled=True)
            ret = self.appresponse.classification.create_hostgroup(hg)
            results = "Successfully created hostgroup '{}'".format(ret.data.name)
            return results
        except RvbdHTTPException:
            results = "Error creating hostgroup '{}'".format(self.name)+", group already exists"
            return results

def main():
    fields = {
        "host": {"type": "str"},
        "username": {"type": "str"},
        "password": {"type": "str"},
        "hostgroup_name": {"default": None, "type": "str"},
        "hostgroup_hosts": {"default": None, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_name'],module.params['hostgroup_hosts'])
    t.appresponse = my_ar

    results = t.main()

    module.exit_json(changed=True, meta=results)


if __name__ == '__main__':
    main()
