# Description

The python script searches through the packet buffer of the appliance and loops though all capture jobs to find IP conversation specified in the python code

## Usage:

Make sure the ```ar11.py``` file is present in the same directory along with the script itself.
Ensure you provide the AR11 IP address or FQDN here

![ar11 address](ar11_line_code.png)

as well as the IP addresses of conversation endpoints

![ip conversation](ip_conv_line_code.png)

The credentials supplied here

![creds](creds_line_code.png)

and finally, simply run

```shell
python download_ip_conversation.py
```
## Example output:

![sample output](output.png)

## Requirements

Requires Python modules (with their related dependencies):

	requests

## Copyright (c) 2021 Riverbed Technology
