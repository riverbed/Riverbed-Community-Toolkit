#!/usr/bin/env python

# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

"""
Host Group information on AppResponse appliance:
Update a host group
"""

__author__ = "Wim Verhaeghe"
__email__ = "wim.verhaeghe@riverbed.com"
__version__= "1"

from ansible.module_utils.basic import *
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.service import UserAuth
from steelscript.appresponse.core.classification import HostGroupConfig



class HostGroupApp(AppResponseApp):

    def __init__(self,id=None,name=None,hosts=None):
        super(AppResponseApp).__init__()
        self.id = id
        self.name = name
        self.hosts = hosts

    def main(self):

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
            result = "Successfully updated hostgroup '{}'".format(hg.name)
            return result

        except:
            results = "Error updating hostgroup '{}'".format(self.name)
            return results


def main():
    fields = {
        "host": {"type": "str"},
        "username": {"type": "str"},
        "password": {"type": "str"},
        "hostgroup_id": {"default": None, "type": "str"},
        "hostgroup_name": {"default": None, "type": "str"},
        "hostgroup_hosts": {"default": None, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = HostGroupApp(module.params['hostgroup_id'],module.params['hostgroup_name'],module.params['hostgroup_hosts'])
    t.appresponse = my_ar

    results = t.main()

    module.exit_json(changed=True, meta=results)


if __name__ == '__main__':
    main()
