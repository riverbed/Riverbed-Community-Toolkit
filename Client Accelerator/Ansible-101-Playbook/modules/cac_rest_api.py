#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: cac_rest_api
short_description: HTTP GET requests to the Riverbed Client accelerator controller REST API
options:
    host:
        description:
            - Hostname or IP Address of the Client accelerator controller.
        required: True
    access_code:
        description:
            - REST API access code created on the Client accelerator controller.
        required: True
    api_url:
        description:
            - REST API url part to get the required information from the Client accelerator controller.
        required: True
"""
EXAMPLES = """
#Usage Example
    - name: Get license information from Client Accelerator controller via REST API
      cac_rest_api:
        host: 192.168.1.1
        access_code: eyJhdWQiOiAiaHR0cHM6Ly9jbGllbnQt==
        api_url: /api/appliance/1.0.0/status/license
      register: results
      
    - name: Display license information 
      debug: var=results
"""
RETURN = r'''
output:
    description: API response in json dict format
    returned: success
    type: dict
'''


from ansible.module_utils.basic import AnsibleModule
from steelscript.common.app import Application
from steelscript.common.service import OAuth
from steelscript.common import Service
from steelscript.common.exceptions import RvbdHTTPException


class ClientAcceleratorControllerCLIApp(Application):

    def __init__(self, host, api_url, code):
        super(Application).__init__()
        self.host = host
        self.api_url = api_url
        self.access_code = code

    def main(self,module):

        try:
            cac = Service("cac", self.host, auth=OAuth(self.access_code))

            path = self.api_url
            content_dict = cac.conn.json_request('GET', path)

            del cac

            module.exit_json(changed=False,output=content_dict)

        except RvbdHTTPException as e:
            results="Error retrieving information on '{}'".format(self.api_url)
            module.fail_json(changed=False,msg=results,reason=str(e))

def main():
    fields = {
        "host": {"required": True, "type": "str"},
        "api_url": {"required": True, "type": "str"},
        "access_code": {"required": True, "type": "str", "no_log": True}
    }

    module = AnsibleModule(argument_spec=fields)

    my_app = ClientAcceleratorControllerCLIApp(module.params["host"],module.params["api_url"],module.params["access_code"])
    my_app.main(module)


if __name__ == '__main__':
    main()
