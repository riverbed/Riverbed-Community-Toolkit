#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: create_hostgroup_from_json
short_description: Create a hostgroup via a json file on Netprofiler via REST API
options:
    host:
        description:
            - Hostname or IP Address of the Netprofiler.
        required: True
    access_code:
        description:
            - REST API access code created on the Netprofiler.
        required: True
    json_file:
        description:
            - Hostgroup JSON file.
        required: True
"""
EXAMPLES = """
#Usage Example
    - name: Create Hostgroup on Netprofiler via REST API
      create_hostgroup_from_json:
        host: 192.168.1.1
        access_code: eyJhdWQiOiAiaHR0cHM6Ly9jbGllbnQt==
        json_file: epg.json
      register: results

    - name: Display Hostgroup creation result via REST API 
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


class NetprofilerCLIApp(Application):

    def __init__(self, host, code, json_file):
        super(Application).__init__()
        self.api_url = "/api/profiler/1.14/host_group_types"
        self.host = host
        self.json_file = json_file
        self.access_code = code


    def main(self, module):

        try:
            netprofiler = Service("netprofiler",self.host, auth=OAuth(self.access_code),supports_auth_basic=False,supports_auth_oauth=True)

            contents = open(self.json_file, 'rb').read()

            content_dict = netprofiler.conn.upload(self.api_url, contents, extra_headers={'Content-Type': 'application/json'})

            del netprofiler

            result = content_dict['Location-Header'].replace("/api/profiler/1.14/host_group_types/", '')

            module.exit_json(changed=True,output="Hostgroup created with id: "+result)

        except RvbdHTTPException as e:
            if e.status == 409:
                results="EPG hostgroup already exists!"
                module.fail_json(changed=False,msg=results,reason=str(e))
            else:
                results = "Error retrieving information on '{}'".format(self.api_url)
                module.fail_json(changed=False, msg=results, reason=str(e))


def main():
    fields = {
        "host": {"required": True, "type": "str"},
        "access_code": {"required": True, "type": "str", "no_log": True},
        "json_file": {"required": True, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_app = NetprofilerCLIApp(module.params["host"],module.params["access_code"],module.params["json_file"],)

    my_app.main(module)


if __name__ == '__main__':
    main()
