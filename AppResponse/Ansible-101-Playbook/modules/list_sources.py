#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: list_sources
author: Wim Verhaeghe (@rvbd-wimv)
short_description: Show the list of available packet sources on a Riverbed AppResponse appliance
options:
    host:
        description:
            - Hostname or IP Address of the AppResponse appliance.
        required: True
    username:
        description:
            - Username used to login to the AppResponse appliance.
        required: True
    password:
        description:
            - Password used to login to the AppResponse appliance
        required: True
    output_file:
        description:
            - File name for write output
        required: False
"""
EXAMPLES = """
#Usage Example
    - name: Get sources from the AppResponse
      list_sources:
        host: 192.168.1.1
        username: admin
        password: admin
      register: results

    - name: List sources available on the AppResponse 
      debug: var=results
    
    - name: Get sources from the AppResponse and write to output file
      list_sources:
        host: 192.168.1.1
        username: admin
        password: admin
        output_file: test.txt
      register: results

    - name: Display status on writing to output file 
      debug: var=results
"""
RETURN = r'''
output:
    description: Available hostgroups on the AppResponse
    returned: success
    type: list
msg:
    description: Status of writing to the output file
    returned: success
    type: str
'''

from ansible.module_utils.basic import AnsibleModule
from collections import namedtuple
from steelscript.appresponse.core.app import AppResponseApp
from steelscript.appresponse.core.appresponse import AppResponse
from steelscript.common.api_helpers import APIVersion
from steelscript.common.datautils import Formatter
from steelscript.common.service import UserAuth
from steelscript.common.exceptions import RvbdHTTPException

IFG = namedtuple('IFG', 'type get_id get_items')


class PacketCaptureApp(AppResponseApp):

    def __init__(self,output_file=None):
        super(AppResponseApp).__init__()
        self.output_file = output_file
        self.first_line = True

    def console(self, source_type, data, headers):
        if self.output_file is not None:
            f = open(self.output_file, "a+")
            f.write('')
            if not self.first_line:
                f.write("\n")
            f.write(source_type + "\n")
            f.write('-' * len(source_type) + "\n")
            f.close()
            self.first_line = False

        if data:
            Formatter.print_table(data, headers,self.output_file)


    def main(self,module):

        try:

            # handle new packet capture version
            version = APIVersion(self.appresponse.versions['npm.packet_capture'])
            if version < APIVersion('2.0'):
                ifg = IFG('mifg_id',
                        lambda job: job.data.config.mifg_id,
                        self.appresponse.capture.get_mifgs)
            else:
                ifg = IFG('vifgs',
                        lambda job: job.data.config.vifgs,
                        self.appresponse.capture.get_vifgs)

        # Show Interfaces and VIFGs (skip if MIFG appliance)
            if ifg.type == 'vifgs':
                total = []
                # Show interfaces
                headers = ['name', 'description', 'status', 'bytes_total',
                           'packets_dropped', 'packets_total']
                data = []
                for iface in self.appresponse.capture.get_interfaces():
                    data.append([
                        iface.name,
                        iface.data.config.description,
                        iface.status,
                        iface.stats.bytes_total.total,
                        iface.stats.packets_dropped.total,
                        iface.stats.packets_total.total,
                    ])
                if self.output_file is not None:
                    self.console('Interfaces', data, headers)
                total.append(headers)
                total.append(data)

                headers = ['id', 'name', 'enabled', 'filter', 'bytes_received',
                           'packets_duped', 'packets_received']
                data = []
                for vifg in self.appresponse.capture.get_vifgs():
                    data.append([
                        vifg.data.id,
                        vifg.data.config.name,
                        vifg.data.config.enabled,
                        vifg.data.config.filter,
                        vifg.data.state.stats.bytes_received.total,
                        vifg.data.state.stats.packets_duped.total,
                        vifg.data.state.stats.packets_received.total,
                    ])
                if self.output_file is not None:
                    self.console('VIFGs', data, headers)
                total.append(headers)
                total.append(data)

            # Show capture jobs
            headers = ['id', 'name', ifg.type, 'filter', 'state',
                       'start_time', 'end_time', 'size']
            data = []
            for job in self.appresponse.capture.get_jobs():
                data.append([job.id, job.name,
                             ifg.get_id(job),
                             getattr(job.data.config, 'filter', None),
                             job.data.state.status.state,
                             job.data.state.status.packet_start_time,
                             job.data.state.status.packet_end_time,
                             job.data.state.status.capture_size])
            if self.output_file is not None:
                self.console('Capture Jobs', data, headers)
            total.append(headers)
            total.append(data)

            # Show clips

            headers = ['id', 'job_id', 'start_time', 'end_time', 'filters']
            data = []
            for clip in self.appresponse.clips.get_clips():
                data.append([clip.id, clip.data.config.job_id,
                             clip.data.config.start_time,
                             clip.data.config.end_time,
                             getattr(clip.data.config, 'filters',
                                     dict(items=None))['items']])
            if self.output_file is not None:
                self.console('Clips', data, headers)
            total.append(headers)
            total.append(data)

            # Show files

            headers = ['type', 'id', 'link_type', 'format',
                       'size', 'created', 'modified']
            data = []
            for obj in self.appresponse.fs.get_files():
                data.append([obj.data.type, obj.id, obj.data.link_type,
                             obj.data.format, obj.data.size,
                             obj.data.created, obj.data.modified])
            if self.output_file is not None:
                self.console('Uploaded Files/PCAPs', data, headers)
            total.append(headers)
            total.append(data)

            if self.output_file is None:
                module.exit_json(changed=False,output=total)
            else:
                result="Successfully wrote output to '{}'".format(self.output_file)
                module.exit_json(changed=False, msg=result)

        except RvbdHTTPException as e:
            results = "Error getting list of sources from AppResponse appliance"
            module.fail_json(changed=False,msg=results,reason=str(e))

def main():
    fields = {
        "host": {"required":True, "type": "str"},
        "username": {"required":True, "type": "str"},
        "password": {"required":True, "type": "str", "no_log":True},
        "output_file": {"required": False, "type": "str"}
    }

    module = AnsibleModule(argument_spec=fields)

    my_ar = AppResponse(module.params['host'], UserAuth(module.params['username'], module.params['password']))

    t = PacketCaptureApp(module.params['output_file'])
    t.appresponse = my_ar

    t.main(module)


if __name__ == '__main__':
    main()

