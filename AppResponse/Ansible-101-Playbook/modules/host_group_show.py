#!/usr/bin/env python

# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

"""
Host Group information on AppResponse appliance:
Show host groups
"""

__author__ = "Wim Verhaeghe"
__email__ = "wim.verhaeghe@riverbed.com"
__version__= "1"

from ansible.module_utils.basic import *
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth



class HostGroupApp(AppResponseApp):

    def __init__(self):
        super(AppResponseApp).__init__()

    def main(self):

            total = []
            headers = ['id', 'name', 'active', 'definition']
            data = [[hg.id, hg.name, hg.data.enabled, hg.data.hosts]
                    for hg in self.appresponse.classification.get_hostgroups()
                    ]
            total.append(headers)
            total.append(data)
            return total



def main():
    fields = {
        "host": {"type": "str"},
        "username": {"type": "str"},
        "password": {"type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp()
    t.appresponse = my_ar

    results = t.main()

    module.exit_json(changed=True, meta=results)


if __name__ == '__main__':
    main()
