import paramiko
import os

MTR_LOCAL_ROOT_PATH  = '/root/input/'
NETIM_CORE         = {'access_address':'10.99.31.75','name':'n31-netimcore','username':'netimadmin',
                      'password':'netimadmin','mtr_path':'/data1/riverbed/NetIM/op_admin/tmp/vne/generic_metrics/input/'}

# Setup for SSH

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(NETIM_CORE['access_address'],username=NETIM_CORE['username'],password=NETIM_CORE['password'])

# Open a transport
host,port = NETIM_CORE['access_address'],22
transport = paramiko.Transport((host,port))

# Auth
username,password = NETIM_CORE['username'],NETIM_CORE['password']
transport.connect(None,username,password)

# Go!
sftp = paramiko.SFTPClient.from_transport(transport)

# Upload
all_files = os.listdir(MTR_LOCAL_ROOT_PATH)
for file in all_files:
 if file.endswith('.mtr'):
 # print(file)
  filepath  = NETIM_CORE['mtr_path'] + file
  localpath = MTR_LOCAL_ROOT_PATH    + file
  sftp.put(localpath,filepath)

# Close
if sftp: sftp.close()
if transport: transport.close()

# Check if the file uploaded
try:
 stdin, stdout, stderr = client.exec_command('ls -alrth ' + NETIM_CORE['mtr_path'])
 for line in stdout.readlines():
  print(line)
finally:
 client.close()
del stdin, stdout, stderr
