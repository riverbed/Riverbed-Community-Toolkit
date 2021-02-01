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

# DAL UDM Metric Class for the docker self monitoring metrics
DAL_NETIM_METRIC_CLASS = "CM_201111130116"

# CHE UDM Metric Class for the docker self monitoring metrics
CHE_NETIM_METRIC_CLASS = "CM_201224033345"

# DAL credentials
DAL_NETIM_CLI_USER     = 'netimadmin' 
DAL_NETIM_CLI_PASSWORD = 'netimadmin'
DAL_NETIM_API_USER     = ''
DAL_NETIM_API_PASSWORD = ''

# CHE credentials
CHE_NETIM_CLI_USER     = 'netimadmin' 
CHE_NETIM_CLI_PASSWORD = 'netimadmin'
CHE_NETIM_API_USER     = 'admin'
CHE_NETIM_API_PASSWORD = ''

# DAL netim manager and work nodes list and crednetials
DAL_NETIM_DOCKER_NODES = [{'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimmgr',  'id':'1605119506378', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimdtmgr','id':'1605119506405', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk1', 'id':'1605119506427', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk2', 'id':'1605119506450', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk3', 'id':'1605119506472', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk4', 'id':'1605119506493', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk5', 'id':'1608614615695', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk6', 'id':'1608614615716', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD},
                          {'udm_metric_class' : DAL_NETIM_METRIC_CLASS,'access_address':'dalnetimwrk7', 'id':'1608614615754', 'username':DAL_NETIM_CLI_USER,'password':DAL_NETIM_CLI_PASSWORD,'core':'dalnetimcore','apiuser':DAL_NETIM_API_USER,'apipassword':DAL_NETIM_API_PASSWORD}]

# CHE netim manager and work nodes list and crednetials
CHE_NETIM_DOCKER_NODES = [{'udm_metric_class' : CHE_NETIM_METRIC_CLASS,'access_address':'chenetimmgr',  'id':'1608763192565', 'username':CHE_NETIM_CLI_USER,'password':CHE_NETIM_CLI_PASSWORD,'core':'chenetimcore','apiuser':CHE_NETIM_API_USER,'apipassword':CHE_NETIM_API_PASSWORD},
                          {'udm_metric_class' : CHE_NETIM_METRIC_CLASS,'access_address':'chenetimdtmgr','id':'1608763192588', 'username':CHE_NETIM_CLI_USER,'password':CHE_NETIM_CLI_PASSWORD,'core':'chenetimcore','apiuser':CHE_NETIM_API_USER,'apipassword':CHE_NETIM_API_PASSWORD},
                          {'udm_metric_class' : CHE_NETIM_METRIC_CLASS,'access_address':'chenetimwrk1', 'id':'1608763192614', 'username':CHE_NETIM_CLI_USER,'password':CHE_NETIM_CLI_PASSWORD,'core':'chenetimcore','apiuser':CHE_NETIM_API_USER,'apipassword':CHE_NETIM_API_PASSWORD},
                          {'udm_metric_class' : CHE_NETIM_METRIC_CLASS,'access_address':'chenetimwrk2', 'id':'1608763192635', 'username':CHE_NETIM_CLI_USER,'password':CHE_NETIM_CLI_PASSWORD,'core':'chenetimcore','apiuser':CHE_NETIM_API_USER,'apipassword':CHE_NETIM_API_PASSWORD},
                          {'udm_metric_class' : CHE_NETIM_METRIC_CLASS,'access_address':'chenetimwrk3', 'id':'1608763192656', 'username':CHE_NETIM_CLI_USER,'password':CHE_NETIM_CLI_PASSWORD,'core':'chenetimcore','apiuser':CHE_NETIM_API_USER,'apipassword':CHE_NETIM_API_PASSWORD},
                          {'udm_metric_class' : CHE_NETIM_METRIC_CLASS,'access_address':'chenetimwrk4', 'id':'1608763192676', 'username':CHE_NETIM_CLI_USER,'password':CHE_NETIM_CLI_PASSWORD,'core':'chenetimcore','apiuser':CHE_NETIM_API_USER,'apipassword':CHE_NETIM_API_PASSWORD}]


# netim core URL for pushing metrics
metric_sample   = {"sampleInfo":"null","fieldValues":{"container_cpu_util":"","container_mem_util":"","container_name":"","timestamp":""}}
metrics_request = {"source":"external","metricClass":"","identifiers":{"VNES_OE":{"deviceID":""}},"maxTimestamp":"","minTimestamp":"","sampleList":[]}
metric_samples  = []

epoch_ms = int(time.time()) * 1000
headers = {'Content-type': 'application/json'}

for node in DAL_NETIM_DOCKER_NODES:
 # Setup for SSH 
 client = paramiko.SSHClient()
 client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
 client.connect(node['access_address'] + '.fringe.example.com',username=node['username'],password=node['password'])

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
  r = requests.post('https://' + node['core'] + '.fringe.example.com:8543/swarm/NETIM_NETWORK_METRIC_IMPORT_SERVICE/api/v1/network-metric-import', data=json.dumps(new_metrics_request).replace('"null"','null'),
                                    headers=headers, verify=False, auth=(node['apiuser'], node['apipassword']))
  print(r.content)

 finally:
  client.close()
 del stdin, stdout, stderr

for node in CHE_NETIM_DOCKER_NODES:
 # Setup for SSH 
 client = paramiko.SSHClient()
 client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
 client.connect(node['access_address'] + '.fringe.example.com',username=node['username'],password=node['password'])

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
  r = requests.post('https://' + node['core'] + '.fringe.example.com:8543/swarm/NETIM_NETWORK_METRIC_IMPORT_SERVICE/api/v1/network-metric-import', data=json.dumps(new_metrics_request).replace('"null"','null'),
                                    headers=headers, verify=False, auth=(node['apiuser'], node['apipassword']))
  print(r.content)

 finally:
  client.close()
 del stdin, stdout, stderr
