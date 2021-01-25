#!/usr/bin/env python

# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

"""
Host Group information on AppResponse appliance:
Delete one host group
"""

__author__ = "Wim Verhaeghe"
__email__ = "wim.verhaeghe@riverbed.com"
__version__= "1"

from ansible.module_utils.basic import *
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth
from steelscript.common.exceptions import RvbdHTTPException


class HostGroupApp(AppResponseApp):

    def __init__(self,id=None,name=None):
        super(AppResponseApp).__init__()
        self.id = id
        self.name = name


    def main(self):

        try:
            if self.id:
                hg = self.appresponse.classification.get_hostgroup_by_id(
                    self.id)
            else:
                hg = self.appresponse.classification.get_hostgroup_by_name(
                    self.name)

            hg.delete()
            results = "Successfully deleted hostgroup with ID/name {}".format(self.id or self.name)
            return results

        except RvbdHTTPException:
            results = "Error deleting hostgroup with ID/name {}".format(self.id or self.name)
            return results

def main():
    fields = {
        "host": {"type": "str"},
        "username": {"type": "str"},
        "password": {"type": "str"},
        "hostgroup_id": {"default": None, "type": "str"},
        "hostgroup_name": {"default": None, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_id'],module.params['hostgroup_name'])
    t.appresponse = my_ar

    results = t.main()

    module.exit_json(changed=True, meta=results)


if __name__ == '__main__':
    main()
