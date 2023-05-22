# Synthetic Test - Monitor Specific IP Route on Network Device

Usecase: Infrastruture Health Monitoring

Instructions for using the `get_ip_route_state.py` script to check the state of an IP route on a particular device.

## Preparation

1. Python3 and [PySNMP](https://pysnmp.readthedocs.io) should be installed properly on the machine where synthetic tests are going to be executed.

2. The NetIM Testing Engine must be properly instaled and sync'd with a NetIM instance.

3. You may also need to configure your firewall or network settings to allow the script to communicate with the target device or server.

4. If you are using SNMPv3, you must also have the following information:

- The security name to use for authentication and privacy.
- The authentication and privacy protocols and passwords to use, if authentication and/or privacy are enabled.

## Manual Testing

### Step 1. Get the python script

Download the [`get_ip_route_state.py`](./get_ip_route_state.py) script and save it to a directory of your choice.

### Step 2. Navigate to the file

Open a command prompt and navigate to the directory where `get_ip_route_state.py` is saved.

### Step 3. Usage

`python get_ip_route_state.py <ip_address> <snmp_version> <community_string> <dest_ip> [--security_level <security_level>] [--auth_protocol <auth_protocol>] [--auth_password <auth_password>] [--priv_protocol <priv_protocol>] [--priv_password <priv_password>]`

Run the script with the desired command-line arguments. The available arguments are as follows:

- `ip_address` : The IP address of the device to query.
- `snmp_version` : The SNMP version to use (v2 or v3).
- `community_string`: The community string (for SNMPv2) or security name (for SNMPv3).
- `dest_ip`: The destination IP address to retrieve the IP route state for.
- `security_level` (optional): The security level for SNMPv3 (noAuthNoPriv, authNoPriv, or authPriv).`
- `auth_protocol` (optional): The authentication protocol for SNMPv3 (MD5 or SHA).
  `auth_password` (optional): The authentication password for SNMPv3.

* `priv_protocol` (optional): The privacy protocol for SNMPv3 (DES, 3DES, or AES).
* `priv_password` (optional): The privacy password for SNMPv3.

### Step 4. Examples

Example 1 : Retrieve IP route state using SNMPv2

`python get_ip_route_state.py 192.168.1.1 v2 public 8.8.8.8`

Example 2 : Retrieve IP route state using SNMPv3

`python get_ip_route_state.py 192.168.1.1 v3 user123 8.8.8.8 --security_level authPriv --auth_protocol SHA --auth_password password123 --priv_protocol AES --priv_password secret123`

Example 3 : Retrieve IP route state using SNMPv3 with authentication and no privacy

`python get_ip_route_state.py 192.168.1.1 v3 user123 8.8.8.8 --security_level authNoPriv --auth_protocol SHA --auth_password password123`

Above command retrieves the IP route state for the destination IP address `8.8.8.8` from the device with IP address `192.168.1.1` using `SNMPv3` and the security name `user123`. It uses authentication with `SHA` protocol and the password `password123`, but no privacy.

Example 4 : Retrieve IP route state using SNMPv3 with no authentication and no privacy

`python get_ip_route_state.py 192.168.1.1 v3 user123 8.8.8.8 --security_level noAuthNoPriv`

This command retrieves the IP route state for the destination IP address `8.8.8.8` from the device with IP address `192.168.1.1` using `SNMPv3` and the security name `user123`. It does not use authentication or privacy.

Example 5 : Retrieve IP route state using SNMPv3 with authentication and privacy

`python get_ip_route_state.py 192.168.1.1 v3 user123 8.8.8.8 --security_level authPriv --auth_protocol SHA --auth_password password123 --priv_protocol AES --priv_password secret123`

This command retrieves the IP route state for the destination IP address `8.8.8.8` from the device with IP address `192.168.1.1` using SNMPv3 and the security name `user123`. It uses authentication with `SHA` protocol and the password `password123`, and privacy with `AES` protocol and the password `secret123`.

## License

The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.

## Copyright (c) 2023 Riverbed Technology, Inc.
