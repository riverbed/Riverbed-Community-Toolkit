import copy
import paramiko
import requests
import time
import json
import re
from re import search
import urllib3

urllib3.disable_warnings()
DOCKER_STATS_COMMAND = 'docker stats --no-stream --format \"{\\\"container_name\\\":\\\"{{ .Name }}\\\",\\\"container_mem_util\\\":\\\"{{ .MemPerc }}\\\",\\\"container_cpu_util\\\":\\\"{{ .CPUPerc }}\\\"}\"' 

# These columns match the netim_docker.mib
COLUMNS = ("container_cpu_util","container_mem_util","container_name")

# UDM Metric Class for the docker self monitoring metrics
NETIM_METRIC_CLASS = "CM_220119221219"

# NetIM credentials
NETIM_CLI_USER     = 'netimadmin' 
NETIM_CLI_PASSWORD = 'netimadmin'
NETIM_API_USER     = 'admin'
NETIM_API_PASSWORD = 'admin'


# NetIM manager and work nodes list and crednetials
NETIM_DOCKER_NODES = [{'udm_metric_class' : NETIM_METRIC_CLASS,'access_address':'10.99.31.76', 'id':'1642655999625', 'username':NETIM_CLI_USER,'password':NETIM_CLI_PASSWORD,'core':'10.99.31.75','apiuser':NETIM_API_USER,'apipassword':NETIM_API_PASSWORD},
                          {'udm_metric_class' : NETIM_METRIC_CLASS,'access_address':'10.99.31.78', 'id':'1642655999669', 'username':NETIM_CLI_USER,'password':NETIM_CLI_PASSWORD,'core':'10.99.31.75','apiuser':NETIM_API_USER,'apipassword':NETIM_API_PASSWORD},                         
                          {'udm_metric_class' : NETIM_METRIC_CLASS,'access_address':'10.99.31.77', 'id':'1642655999590', 'username':NETIM_CLI_USER,'password':NETIM_CLI_PASSWORD,'core':'10.99.31.75','apiuser':NETIM_API_USER,'apipassword':NETIM_API_PASSWORD}]

# setting up for POST'ing data to NetIM's Metrics Import API
metric_sample   = {"sampleInfo":"null","fieldValues":{"container_cpu_util":"","container_mem_util":"","container_name":"","timestamp":""}}
metrics_request = {"source":"external","metricClass":"","identifiers":{"VNES_OE":{"deviceID":""}},"maxTimestamp":"","minTimestamp":"","sampleList":[]}
metric_samples  = []

epoch_ms = int(time.time()) * 1000
headers = {'Content-type': 'application/json'}

for node in NETIM_DOCKER_NODES:
 # Setup for SSH 
 client = paramiko.SSHClient()
 client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
 client.connect(node['access_address'],username=node['username'],password=node['password'])

 # ssh in there and run docker stats
 try:
  stdin, stdout, stderr = client.exec_command(DOCKER_STATS_COMMAND)
  new_metric_samples  = copy.deepcopy(metric_samples)
  new_metrics_request = copy.deepcopy(metrics_request)
  new_metrics_request["identifiers"]["VNES_OE"]["deviceID"]    = node['id']
  for line in stdout.readlines():
   json_data = json.loads(line)
   new_metric_sample                     = copy.deepcopy(metric_sample)
   # Try to shorten container name so that that only the UUIDs part is removed
   if "." not in json_data["container_name"]:
    new_metric_sample["fieldValues"]["container_name"]     = json_data["container_name"]
   elif not re.search(r'(1\.\d\.\w+$)',json_data["container_name"]):
    new_metric_sample["fieldValues"]["container_name"]     = re.sub(r'(\.\w+\.\w+$)','',json_data["container_name"])
   else:
    new_metric_sample["fieldValues"]["container_name"]     = re.sub(r'(\.\w+$)','',json_data["container_name"])
   # Copy all the FG metrics over to metric sample
   new_metric_sample["fieldValues"]["container_mem_util"] = str(json_data["container_mem_util"])[:-1]
   new_metric_sample["fieldValues"]["container_cpu_util"] = str(json_data["container_cpu_util"])[:-1]
   new_metric_sample["fieldValues"]["timestamp"]          = str(epoch_ms)
   # Try to shorten container name so that that only the UUIDs part is removed
   new_metric_samples.append(new_metric_sample)
   print(line)
  new_metrics_request["sampleList"]      = new_metric_samples
  new_metrics_request["maxTimestamp"]    = epoch_ms
  new_metrics_request["minTimestamp"]    = epoch_ms
  new_metrics_request["metricClass"]     = node['udm_metric_class'] 
  print(json.dumps(new_metrics_request).replace('"null"','null'))
  r = requests.post('https://' + node['core'] + ':8543/swarm/NETIM_NETWORK_METRIC_IMPORT_SERVICE/api/v1/network-metric-import', data=json.dumps(new_metrics_request).replace('"null"','null'),
                                    headers=headers, verify=False, auth=(node['apiuser'], node['apipassword']))
  print(r.content)

 finally:
  client.close()
 del stdin, stdout, stderr