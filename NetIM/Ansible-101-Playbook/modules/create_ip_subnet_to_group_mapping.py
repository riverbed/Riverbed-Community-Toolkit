#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: create_ip_subnet_to_group_mapping
short_description: Create a txt file from information extracted from a Netprofiler Hostgroup
options:
    netprofiler:
        description:
            - Hostname or IP Address of the Netprofiler.
        required: True
    access_code:
        description:
            - OAuth access code created on the Netprofiler.
        required: True
    hostgroup_name:
        description:
            - Hostgroup name to be queried.
        required: True
    filename:
        description:
            - Filename to save the result.
        required: True
"""
EXAMPLES = """
#Usage Example
    - name: Create IP subnet to Group mappings txt file
      create_ip_subnet_to_group_mapping:
        netprofiler: 192.168.1.1
        access_code: "aefsdfea23ae=="
        hostgroup_name: "ByLocation"
        filename: "somefilename.txt"
      register: results
    
    - name: Create IP subnet to Group mappings txt file
      create_ip_subnet_to_group_mapping:
        netprofiler: 192.168.1.1
        access_code: "aefsdfea23ae=="
      register: results

    - name: Display file creation result 
      debug: var=results
"""
RETURN = r'''
output:
    description: API response in json dict format
    returned: success
    type: dict
'''

import json
import requests
import xmltodict
import base64
from ansible.module_utils.basic import AnsibleModule

class NetprofilerMappings():

    def __init__(self,netprofiler,access_code,hostgroup_name,filename):
        self._netprofiler = netprofiler
        self._access_code = access_code
        self._hostgroup_name = hostgroup_name
        self._filename = filename


    def get_token(self):

        api_url = '/api/common/1.1/oauth/token'

        a=base64.b64encode(b'{"alg":"none"}\n')
        b=self._access_code
        c=''

        total_access_code=a.decode("ascii")+"."+b+"."+c

        payload = {'grant_type': 'access_code','assertion': total_access_code, 'state': 'state_string'}

        r = requests.post(self._netprofiler+api_url, verify=False, data=payload)

        content_dict = self.conver_xml_to_jsondict(r.text)

        return content_dict['token_response']['access_token']


    def conver_xml_to_jsondict(self,xmlstring):
        r_xml = xmltodict.parse(xmlstring)
        str_dict = json.dumps(r_xml).replace('@','')
        content_dict = json.loads(str_dict)
        return content_dict


    def get_users(self,token):
            api_url = '/api/profiler/1.14/users'
            headers = {"Authorization": "Bearer " + token}
            r = requests.get(self._netprofiler + api_url, verify=False, headers=headers)
            content_dict = self.conver_xml_to_jsondict(r.text)
            return content_dict


    def get_hostgroup(self,token):
            api_url = '/api/profiler/1.14/host_group_types'
            headers = {"Authorization": "Bearer " + token, 'Content-Type': 'application/json' }
            try:
                r = requests.get(self._netprofiler + api_url, verify=False,headers=headers)
                content_dict = self.conver_xml_to_jsondict(r.text)
                return content_dict
            except requests.exceptions.HTTPError as e:
                print("Something went wrong"+e.strerror+"!\n")


    def get_hostgroup_type_conf(self,search_id,token):
        api_url = '/api/profiler/1.14/host_group_types/'+search_id+'/config'
        headers = {"Authorization": "Bearer " + token, 'Content-Type': 'application/json'}
        try:
            r = requests.get(self._netprofiler + api_url, verify=False, headers=headers)
            content_dict = self.conver_xml_to_jsondict(r.text)
            return content_dict
        except requests.exceptions.HTTPError as e:
            print("Something went wrong"+e.strerror+"!\n")


    def get_hostgroup_id(self,content_dict):
        t_value=0
        _search_id=0
        for v in content_dict.values():
            for v2 in v.values():
                for l in v2:
                    for key, value in l.items():
                        if key == 'id':
                            t_value = value
                        if key == 'name' and value == self._hostgroup_name:
                            _search_id = t_value

        return _search_id


    def extract_subnet_location(self,content_dict):
        _result_list = []
        for v in content_dict.values():
            for v2 in v.values():
                for l in v2:
                    _result_list.append(l)

        return _result_list


    def create_import_file(self):
        f = open(self._filename,'w+')
        f.close()


    def add_location_import_file(self,result_list):
        f = open(self._filename,'a+')
        for elem in result_list:
            for k,v in elem.items():
                f.write(v)
                if k == 'cidr':
                    f.write(':')
            f.write('\n')
        f.close()


    def main(self,module):

        my_token = self.get_token()
        content = self.get_hostgroup(my_token)
        search_id = self.get_hostgroup_id(content)
        content = self.get_hostgroup_type_conf(search_id,my_token)
        result_list = self.extract_subnet_location(content)
        self.create_import_file()
        self.add_location_import_file(result_list)

        module.exit_json(changed=True, output="IP_Subnet_to_Group_Mapping file " + self._filename + " Created!")


def main():

    fields = {
        "netprofiler": {"required": True, "type": "str"},
        "access_code": {"required": True, "type": "str"},
        "hostgroup_name": {"required": False, "type": "str", "default": "ByLocation"},
        "filename":  {"required": False, "type": "str", "default": "append.txt"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_app = NetprofilerMappings(module.params["netprofiler"],module.params["access_code"],module.params["hostgroup_name"],module.params["filename"])

    my_app.main(module)


if __name__ == '__main__':
    main()

