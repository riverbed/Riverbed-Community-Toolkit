from ar11 import AR11Connection
from ar11 import AR11Rest
import json
import time
import requests
from datetime import datetime
import sys

ip_a             = '10.38.7.22'

# ip_b            = '10.64.8.78'

ip_b             = '10.38.7.25'

#ar11             = '10.38.7.78'

ar11             = 'supca-ar11-4.lab.nbttech.com'

dl_filter        = f'ip.addr=={ip_a} && ip.addr=={ip_b}'

rest             = AR11Rest(ar11, 'admin', 'admin')

jobs_resp        = ''

try:
    jobs_resp        = rest.json_request('GET', '/npm.packet_capture/3.0/jobs', timeout=30)
except(requests.exceptions.HTTPError , requests.exceptions.ConnectionError):
    print("could not connect to AR11 : " + ar11)
    sys.exit()

jobs_list        = jobs_resp['items']

running_jobs     = []

output_filename  = 'my_automation_pcap.pcap'

end_time         = str(int(time.time()))

start_time       = str(int(time.time() - 60))

packets_found    = False

packets_captured = False

packets_received = False

filename         = ''

for job in jobs_list:
    if job['state']['status']['state'] == 'RUNNING':
        running_jobs.append(job['id'])

for default_job_id in running_jobs:
    capture_request = dict(config=dict(handle_timeout_msec=3600000,
                                   connection_timeout_msec=3600000,
                                   start_time=start_time,
                                   end_time=end_time,
                                   path=f'jobs/{default_job_id}',
                                   mode='STREAM_TO_FILE',
                                   output_filename = '/admin/' + output_filename,
                                   output_format='PCAP_US',
                                   stop_rule=dict(size_limit=10*10000*100),
                                   filters=dict(items=[])))

    capture_request['config']['filters']['items'].append(dict(value=dl_filter,
                                                          type='STEELFILTER',
                                                          id='packet_automation1'))
    print(capture_request)

# you then issue a POST to '/npm.packet_export/1.3/exports' sending the capture_request above as json.
    try:
     pcap_resp      = rest.json_request('POST', url = '/npm.packet_export/1.3/exports', post_data = capture_request, timeout=30)

     print(pcap_resp['id'])

     packets_found = True

     print('waiting on pcap to be produced')

     done           = False
     job_id = pcap_resp['id']
     url = f'/npm.packet_export/1.3/exports/items/{job_id}'
     i = 0

     while not done:
        time.sleep(1)
        done_resp = rest.json_request('GET', url=url, timeout=30)
        print(done_resp)
        if done_resp['status']['state'] in ('DONE', 'ERROR'):
            done = True
            packets_found = True

     print('pcap ready')
     url           = f'/npm.filesystem/1.0/fileop/download/admin/{output_filename}'

     print('checking if pcap contains packets')

     try:
        # get the .pcap file
        file_resp = rest.request('GET', url=url, timeout=60*30)
        packets_received = True
        # be a good citizen and delete the .pcap file
        url = f'/npm.filesystem/1.0/fs/admin/{output_filename}'
        if file_resp:
         delete_resp = rest.request('DELETE', url=url, timeout=10)
         print('pcap deleted from AppResponse')
        if file_resp :
         filename = f'{ar11}_{ip_a}_{ip_b}_jobid_{pcap_resp["id"]}_{datetime.utcnow().strftime("%Y-%m-%dT%H-%m-%S")}_automation.pcap'
         with open(filename,'wb') as fh:
          fh.write(file_resp)
     except (requests.exceptions.HTTPError, requests.exceptions.ConnectionError):
         continue # no packets were found
    except (requests.exceptions.HTTPError , requests.exceptions.ConnectionError):
        continue # no pcap was found
if not packets_found:
    print('no packets were found on any capture jobs on the AR11 : ' + ar11 + ' check for errors in above log')
if not packets_received:
    print('no packets could be downloaded from AR11 : ' + ar11 + ' check for errors in above log')

