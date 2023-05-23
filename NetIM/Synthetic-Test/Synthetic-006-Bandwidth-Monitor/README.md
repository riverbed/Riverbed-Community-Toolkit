# Synthetic Test - Monitor Bandwidth To a Remote Host

Usecase: Infrastruture Health Monitoring

Instructions for using the `bandwidth_monitor.py` script to measure the bandwidth from current host to a remote host.

## Preparation

1. Python3 should be installed properly on the machine where synthetic tests are going to be executed.

2. The NetIM Testing Engine must be properly instaled and sync'd with a NetIM instance.

3. You may also need to configure your firewall or network settings to allow the script to communicate with the target device.

4. If you are using SNMPv3, you must also have the following information:

- The security name to use for authentication and privacy.
- The authentication and privacy protocols and passwords to use, if authentication and/or privacy are enabled.

## Manual Testing

### Step 1. Get the python script

Download the [`bandwidth_monitor.py`](./bandwidth_monitor.py) script and save it to a directory of your choice.

### Step 2. Navigate to the file

Open a command prompt and navigate to the directory where `bgp_peer_monitor.py` is saved.

### Step 3. Run the command manually

Run the script with the desired command-line arguments. The available arguments are as follows:

- `target_ip` : This argument is required and specifies the IP address of the target device or server to which you want to measure the network bandwidth.

- `num_packets` : This argument is optional and specifies the number of ping packets to send to the target IP address to measure the network bandwidth. The default value is 10. You can set this value using the `-n` or `--num_packets` option, followed by an integer value.

- `packet_size` : This argument is optional and specifies the size of each ping packet to send to the target IP address to measure the network bandwidth, in bytes. The default value is 56. You can set this value using the `-s` or `--packet_size` option, followed by an integer value.

- `bandwidth_limit` : This argument is optional and specifies the maximum allowed network bandwidth, in Mbps. If specified, the script will check whether the measured bandwidth exceeds this limit and exit with an error message if it does. The default value is None. You can set this value using the -l or --bandwidth_limit option, followed by a float value.

- `bandwidth_percent` : This argument is optional and specifies the maximum allowed network bandwidth as a percentage of the maximum possible bandwidth based on the packet size. If specified, the script will convert the percentage to Mbps and use this value as the bandwidth limit. The default value is None. You can set this value using the `-p` or `--bandwidth_percent` option, followed by a float value.

Note that you can combine the `-l` and `-p` options, but you should only use one of them at a time. If both options are specified, the script will exit with an error message.

If the measured bandwidth exceeds the specified limit or percentage limit, the script will exit with code 1 and print an error message. If the measured bandwidth is below the limit and above the percentage limit (if specified), the script will exit with code 0 and print a success message.

### Step 4. Examples

`python bandwidth_monitor.py 192.168.0.1`

`python bandwidth_monitor.py 192.168.0.1 -n 20 -s 1000 -l 100`

`python bandwidth_monitor.py 192.168.0.1 -n 50 -s 1500 -l 200 -p 80`

## Possible Improvements

Note that you can use any combination of command-line arguments that makes sense for your use case. The script will use default values for any arguments that are not specified.

You can also modify the script as needed to customize it for your specific use case or to add additional functionality. For example, you could add support for other network protocols, such as UDP or TCP, or you could add a graphical user interface (GUI) to make it easier to use.

When running the script, you should ensure that you have appropriate permissions to execute it and that any required dependencies are installed on your system. You may also need to configure your firewall or network settings to allow the script to communicate with the target device or server.

Overall, the bandwidth_monitor.py script can be a useful tool for measuring network bandwidth and checking against a bandwidth limit. By using the script, you can quickly and easily diagnose network performance issues and ensure that your network is operating as expected.

## License

The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.

## Copyright (c) 2023 Riverbed Technology, Inc.
