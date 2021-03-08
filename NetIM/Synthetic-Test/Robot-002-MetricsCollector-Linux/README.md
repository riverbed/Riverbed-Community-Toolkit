# Metrics Collector Linux ROBOT Cookbook

This robot is a simple configuration that will be able to collect metrics and send them to NetIM using scripts directly from the [GMC-Library](https://github.com/riverbed/Riverbed-Community-Toolkit/tree/master/NetIM/GMC-Library) or embedded in a [Synthetic-Test](https://github.com/riverbed/Riverbed-Community-Toolkit/tree/master/NetIM/Synthetic-Test). The robot will be connected to NetIM so that you can orchestrate the metrics collection from the NetIM webconsole.

Capabilities summary:

- Linux machine (based on https://ubuntu.com)
- Python3
- SSH from Python script (using http://www.paramiko.org)
- Riverbed NetIM Synthetic Agent

The next paragraph explains how to prepare a Linux Ubuntu machine from scratch. It includes the installation of Riverbed agent.

## Prerequisites

- a fresh Ubuntu machine with root or sudo permissions. Tested with Ubuntu 20.04
- a [Riverbed NetIM](https://www.riverbed.com/products/steelcentral/infrastructure-management.html) instance for Synthetic Test orchestration
- Internet access
- Connectivity between the machine and the NetIM Core node

## Preparation

### Prepare a Robot - Step by step

Connect to the machine, for example via ssh

- Get root access

```bash
sudo su
```

- Install few packages

```bash
apt-get update -y

apt-get install unzip -y

apt-get install python3-pip -y

python3 -m pip install paramiko
```

- Fetch Riverbed NetIM agent installer and prepare the installation

Set the mandatory parameters to your environment in the following script and execute it.

```bash
# mandatory parameters
netim_core_reachable_ip='10.10.10.148'

# optional parameters
netim_core_user=netimadmin
netim_agent_version='3.1.5'
netim_agent_user='netim-agent'
netim_agent_group='netim-agent'

################

# prepare NetIM agent installation
useradd --create-home $netim_agent_user

testengine_path='/data1/riverbed/NetIM/latest/external/TestEngine/'
cd /home/$netim_agent_user
scp $netim_core_user@$netim_core_reachable_ip:$testengine_path/TestEngine-linux*.zip .
unzip TestEngine-linux.zip
chown -R $netim_agent_user:$netim_agent_group /home/$netim_agent_user/Riverbed

# installer
cd Riverbed/TE/$netim_agent_version/
./install.sh
```

At this point the interactive installer will start asking questions. You can just fill the main parameters and skip other steps.

Main parameters are:
> 1. NetIMm host: {{netim_core_reachable_ip}
> 2. user name to which the ownership of the Test Engine files will be set: netim-agent
> 3. group name to which the ownership of the Test Engine files will be set: netim-agent


## Metrics collectors

To collect metrics you can now deploy and use scripts from the GMC or Synthetic-Test libraries available in the [Riverbed Community Toolkit](https://github.com/riverbed/Riverbed-Community-Toolkit).

Next we have to get a local copy of the Riverbed Community Toolkit on the robot, customize and configure a synthetic test in NetIM.

- Fetch a local copy of the Riverbed Community Toolkit

```bash
cd /home/netim-agent

git clone https://github.com/riverbed/Riverbed-Community-Toolkit.git
chown -R netim-agent:netim-agent /home/netim-agent/Riverbed-Community-Toolkit
```

By default the local copy should now be in the folder: **/home/netim-agent/Riverbed-Community-Toolkit**

- Customize a script from the Library

Those scripts can now be customized locally, directly in there subfolders.
By default they will be in folders **/home/netim-agent/Riverbed-Community-Toolkit/NetIM/GMC-Library** or  **/home/netim-agent/Riverbed-Community-Toolkit/NetIM/Synthetic-Test**

If necessary refer to the README that normally comes with the script  [Riverbed Community Toolkit](https://github.com/riverbed/Riverbed-Community-Toolkit/tree/master/NetIM)

- Configure a Synthetic Test in NetIM

In NetIM a Synthetic Test can be defined as below and deployed to run on the agent.

| Parameters | value |
| --- | --- |
| Type | External Script |
| Command | python /home/netim-agent/Riverbed-Community-Toolkit/NetIM/GMC-Library/002-NetIM-GMC-Lightweight-Self-Docker-Monitoring/scripts-metrics-api.py |

## License

The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.

## Copyright (c) 2021 Riverbed Technology, Inc.
