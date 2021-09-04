#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: aci_mysql_endpoints_to_epg_hostgroups_json
short_description: Create a json file from information extracted from ACItoolkit MySQL database
options:
    mysql_host:
        description:
            - Hostname or IP Address of the MySQL database server.
        required: True
    mysql_username:
        description:
            - Username to access the database.
        required: True
    mysql_pass:
        description:
            - Password to access the database.
        required: True
    mysql_db:
        description:
            - MySQL database name to Query.
        required: True
    mysql_table:
        description:
            - MySQL table to Query.
        required: True
    tenant:
        description:
            - For which ACI Tenant we like to extract the information.
        required: True
    json_file:
        description:
            - Hostgroup JSON file.
        required: True
"""
EXAMPLES = """
#Usage Example
    - name: Create Hostgroup JSON file
      aci_mysql_endpoints_to_epg_hostgroups_json:
        mysql_host: 192.168.1.1
        mysql_username: "root"
        mysql_pass: "password"
        mysql_db: "endpointtracker"
        mysql_table: "endpoints"
        tenant: "cisco"
        json_file: epg.json
      register: results

    - name: Display Hostgroup file creation result 
      debug: var=results
"""
RETURN = r'''
output:
    description: API response in json dict format
    returned: success
    type: dict
'''

import json
import mysql.connector # pip install mysql-connector-python
import sys
import fileinput
from ansible.module_utils.basic import AnsibleModule

class ACIMysqlEnpointsApp():

    def __init__(self,mysql_host,mysql_username,mysql_pass,mysql_db,mysql_table,tenant,json_file):
        self._tenant = tenant
        self._json_file = json_file
        self._mysql_host = mysql_host
        self._mysql_username = mysql_username
        self._mysql_pass = mysql_pass
        self._mysql_db = mysql_db
        self._mysql_table = mysql_table

    def get_all_epg(self):
        mydb = mysql.connector.connect(host=self._mysql_host, user=self._mysql_username, passwd=self._mysql_pass, database=self._mysql_db)
        cursor = mydb.cursor()
        sql = "SELECT distinct epg FROM "+self._mysql_table+" where tenant = '"+self._tenant+"';"
        cursor.execute(sql)
        rows = cursor.fetchall()
        my_epg_list = []
        for row in rows:
            my_epg_list.append(row)
        return my_epg_list


    def get_all_app(self):
        mydb = mysql.connector.connect(host=self._mysql_host, user=self._mysql_username, passwd=self._mysql_pass, database=self._mysql_db)
        cursor = mydb.cursor()
        sql = "SELECT distinct app FROM "+self._mysql_table+" where tenant = '"+self._tenant+"';"
        cursor.execute(sql)
        rows = cursor.fetchall()
        my_app_list = []
        for row in rows:
            my_app_list.append(row)
        return my_app_list


    def get_all_endpoints_for_epg(self,_epg,_app):
        mydb = mysql.connector.connect(host=self._mysql_host, user=self._mysql_username, passwd=self._mysql_pass, database=self._mysql_db)
        cursor = mydb.cursor(dictionary=True)
        sql = "Select distinct ip,app,epg from "+self._mysql_table+" where epg like '"+_epg[0]+"' and app like '"+_app[0]+"' and tenant like '"+self._tenant+"';"
        cursor.execute(sql)
        rows = cursor.fetchall()
        my_epg_list = []
        my_epg_line = {}
        for line in rows:
            my_epg_line['name']=line['app']+"_"+line['epg']
            my_epg_line['cidr']=line['ip']+"/32"
            my_epg_list.append(my_epg_line.copy())
        return my_epg_list


    def add_json_file(self,_all_endpoints):
        f = open(self._json_file, "a")
        d = json.dumps(_all_endpoints, indent=6)
        f.write(d)
        f.close()

    def end_json_file(self):
        f = open(self._json_file, "a")
        f.write(',\n')
        f.write('  "description": "Group by EGP",\n')
        f.write('  "name": "ByEPG"\n')
        f.write('}\n')
        f.close()

        f = open(self._json_file, "r")
        data = f.read()
        data = data.replace('],', '   ],')
        data = data.replace('][','')
        data = data.replace('}\n','},\n')
        data = '}'.join(data.rsplit('},',1))
        data = '}'.join(data.rsplit('},',1))
        f.close()
        f = open(self._json_file, "w")
        f.write(data)
        f.close()

        for line_number, line in enumerate(fileinput.input(self._json_file, inplace=1)):
            if len(line) > 1:
                sys.stdout.write(line)


    def create_json_file(self):
        f = open(self._json_file,"w")
        f.write('{\n')
        f.write('  "favorite": true,\n')
        f.write('  "config": ')
        f.close()


    def main(self,module):
        all_epg = self.get_all_epg()
        all_app = self.get_all_app()
        self.create_json_file()
        for elem in all_epg:
            for elem_app in all_app:
                all_endpoints = self.get_all_endpoints_for_epg(elem, elem_app)
                if all_endpoints:
                    self.add_json_file(all_endpoints)
        self.end_json_file()

        module.exit_json(changed=True, output="Hostgroup file " + self._json_file + " Created!")

def main():

    fields = {
        "mysql_host": {"required": True, "type": "str"},
        "mysql_username": {"required": True, "type": "str"},
        "mysql_pass": {"required": True, "type": "str", "no_log": True},
        "mysql_db": {"required": True, "type": "str"},
        "mysql_table": {"required": True, "type": "str"},
        "tenant": {"required": True, "type": "str"},
        "json_file": {"required": True, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_app = ACIMysqlEnpointsApp(module.params["mysql_host"],module.params["mysql_username"],module.params["mysql_pass"],module.params["mysql_db"],module.params["mysql_table"],module.params["tenant"],module.params["json_file"])

    my_app.main(module)

if __name__ == '__main__':
    main()