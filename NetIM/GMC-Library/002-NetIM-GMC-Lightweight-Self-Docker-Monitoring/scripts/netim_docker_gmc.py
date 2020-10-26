import paramiko
import os
import time
import json
import re
from re import search

MTR_LOCAL_ROOT_PATH  = '/root/input/'
DOCKER_STATS_COMMAND = 'docker stats --no-stream --format \"{\\\"container_name\\\":\\\"{{ .Name }}\\\",\\\"container_mem_util\\\":\\\"{{ .MemPerc }}\\\",\\\"container_cpu_util\\\":\\\"{{ .CPUPerc }}\\\"}\"' 

# custom metric name from when you imported the .mib file (folder <NetIMDirectory>\lib\xml\res\custommetrics\headers)
HEADER_FILE_NAME="CM_200922231140"

# These columns match the netim_docker.mib
COLUMNS = ("container_cpu_util","container_mem_util","container_name")

# used in the data header and also as the base name for the .mtr output files
HEADER_NAME = "netimdockerstats"

# netim manager and work nodes list and crednetials

NETIM_DOCKER_NODES = [{'access_address':'10.99.31.77','name':'n31-netimwrk',    'username':'netimadmin','password':'netimadmin'},{'access_address':'10.99.31.76','name':'n31-netimmgr',    'username':'netimadmin','password':'netimadmin'},{'access_address':'10.99.31.78','name':'n31-netimdatamgr','username':'netimadmin','password':'netimadmin'}]
NETIM_CORE         = {'access_address':'10.99.31.75','name':'n31-netimcore','username':'netimadmin','password':'netimadmin'}

mtr_header = "[SampleDataHeader][name={header_name}][metricClass={header_file_name}]timestamp,{columns}\n"
mtr_header = mtr_header.format(header_name=HEADER_NAME,
                               header_file_name=HEADER_FILE_NAME,
                               columns=",".join(COLUMNS))
mtr_header += "[TargetInfoHeader]HEADERNAME,SYSNAME\n"
data_line_template = "[TI]{header}[SI][SD]{data}\n"
output = [mtr_header, ]
epoch_ms = int(time.time()) * 1000

for node in NETIM_DOCKER_NODES:
 # Setup for SSH 
 client = paramiko.SSHClient()
 client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
 client.connect(node['access_address'],username=node['username'],password=node['password'])

 # ssh in there and run docker stats
 try:
  stdin, stdout, stderr = client.exec_command(DOCKER_STATS_COMMAND)
  for line in stdout.readlines():
   json_data = json.loads(line)
   data = "{},".format(epoch_ms)
   epoch_ms += 1
   data += ",".join(map(lambda field: str(json_data[field])[:-1] if search('util',field) else ( re.sub('(\.1\.\w+$)|(\.\w+\.\w+$)','',json_data[field]) if search('name',field) else str(json_data[field])), COLUMNS ))
   header = "{header_name},{sysname}".format(header_name=HEADER_NAME, sysname=node['name'])
   output.append(data_line_template.format(header=header, data=data))
 finally:
  client.close()
 del stdin, stdout, stderr

filename = "{directory}//{core_node_name}_{header_name}_{epoch_ms}.mtr".format(directory=MTR_LOCAL_ROOT_PATH,
                                                              header_name=HEADER_NAME,
                                                              core_node_name=NETIM_CORE['name'],
                                                              epoch_ms=epoch_ms)
with open(filename, "w+") as fh:
 fh.writelines(output)

