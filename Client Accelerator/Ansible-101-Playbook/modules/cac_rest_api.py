# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

#!/usr/bin/python

from __future__ import (absolute_import, unicode_literals, print_function,
                        division)

__author__ = "Wim Verhaeghe"
__email__ = "wim.verhaeghe@riverbed.com"
__version__= "2"

from ansible.module_utils.basic import *
from steelscript.common.app import Application
from steelscript.common.service import OAuth
from steelscript.common import Service


class ClientAcceleratorControllerCLIApp(Application):

    def __init__(self, host, api_url, code):
        super(Application).__init__()
        self.host = host
        self.api_url = api_url
        self.access_code = code

    def main(self):
        cac = Service("cac", self.host, auth=OAuth(self.access_code))

        path = self.api_url
        content_dict = cac.conn.json_request('GET', path)

        del cac

        return content_dict


def main():
    fields = {
        "host": {"default": True, "type": "str"},
        "api_url": {"default": True, "type": "str"},
        "access_code": {"default": True, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_app = ClientAcceleratorControllerCLIApp(module.params["host"],module.params["api_url"],module.params["access_code"])
    results = my_app.main()

    module.exit_json(changed=True, meta=results)


if __name__ == '__main__':
    main()