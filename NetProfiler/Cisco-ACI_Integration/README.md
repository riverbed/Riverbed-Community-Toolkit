## NetProfiler Cisco ACI integration - mapping ACI EPGs to NetProfiler Host Groups
The following cookbook contains a description of a workflow on how to add **NetProfiler** Host Groups based on the endpoint groups connected to **Cisco ACI**.

## Workflow overview

<img src="images/workflows.png" width="35%"/>

## Prerequisites
1. A host with Docker installed, probably a Linux host, and sufficient access to run create and run Docker containers
2. A NetProfiler with OAuth credentials available for a user able to create and modify Host Groups (Administration > OAuth Access)
3. Access to a Cisco ACI APIC with suitable credentials

## Workflow description
The above workflow consists of the following parts:  
1. Docker container which runs the [Cisco ACI toolkit](https://developer.cisco.com/codeexchange/github/repo/datacenter/acitoolkit). 
2. Docker container which runs [MySQL](https://www.mysql.com) server.
2. Docker container which runs [Ansible](https://www.ansible.com/) and SteelScript which is used to configure NetProfiler.

The Cisco ACI toolkit contains a script [aci_endpointtracker](https://acitoolkit.readthedocs.io/en/latest/endpointtracker.html) which extracts all the endpoints from an indicated Tenant and stores them into a MySQL table (endpoints) with the following structure:
```
MariaDB [endpointtracker]> desc endpoints;
+-----------+-----------+------+-----+---------------------+-------------------------------+
| Field     | Type      | Null | Key | Default             | Extra                         |
+-----------+-----------+------+-----+---------------------+-------------------------------+
| mac       | char(18)  | NO   |     | NULL                |                               |
| ip        | char(16)  | YES  |     | NULL                |                               |
| tenant    | char(100) | NO   |     | NULL                |                               |
| app       | char(100) | NO   |     | NULL                |                               |
| epg       | char(100) | NO   |     | NULL                |                               |
| interface | char(100) | NO   |     | NULL                |                               |
| timestart | timestamp | NO   |     | current_timestamp() | on update current_timestamp() |
| timestop  | timestamp | YES  |     | NULL                |                               |
+-----------+-----------+------+-----+---------------------+-------------------------------+
```

## Setting up

Before starting the [docker-compose](docker-compose-final.yml) process, the custom Ansible container needs to be built using the following [docker-file](dockerfile-ansible).
```
docker build -t m_ansible:aci -f dockerfile-ansible .
```
Verify that the container image is now existing:
```
docker images m_ansible:aci
```
Modify the docker-compose file environment variables APIC_URL, APIC_LOGIN and APIC_PASSWORD to the working environment values:
```
   environment:
      - APIC_URL=https://myapic.url
      - APIC_LOGIN=admin
      - APIC_PASSWORD=mysecret_password
```

Start the docker-compose process:
```
docker-compose -f docker-compose-final.yml up -d
```
Verify that all 3 containers are up and running:
```
docker ps -a                     
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                 NAMES
c44e76fe01c9   dockercisco/acitoolkit   "sleep infinity"         32 seconds ago   Up 31 seconds                         acitoolkit
008a14bc3c98   m_ansible:aci            "sleep infinity"         32 seconds ago   Up 31 seconds                         ansible
dc237249a07a   mysql:latest             "docker-entrypoint.s…"   32 seconds ago   Up 31 seconds   3306/tcp, 33060/tcp   mysql_db
```
Copy in an modified version of the [aci-endpoint-tracker](acitoolkit/applications/endpointtracker/aci-endpoint-tracker-rvbd.py) script into the acitoolkit container.
This is a slightly modified version which fixes a couple of issues and adds a "off-off" option to force the script to execute one scan of ACI, export endpoint data into MySQL and then exit rather than run perpetually updating the database when the ACI system changes.
```
docker cp acitoolkit/applications/endpointtracker/aci-endpoint-tracker-rvbd.py acitoolkit:/opt/acitoolkit/applications/endpointtracker/aci-endpoint-tracker-rvbd.py
```
Connect to the acitoolkit container and install the [mysql-connector](https://pypi.org/project/mysql-connector-python/) package and a compatible version of the protobuf package for the database connection.
Then execute the Python script that gets the endpoint information and writes it in to the MySQL database:
```
docker exec -ti acitoolkit /bin/bash
apt-get update && apt-get install -y python-pip && pip install protobuf==3.18.0 && pip install mysql-connector-python==8.0.21
cd applications/endpointtracker/
python aci-endpoint-tracker-rvbd.py -o
```
Verify that the database exists and is populated:
```
docker exec -ti ansible /bin/bash
mysql -u root -ppassword -h 172.18.0.3 endpointtracker
select * from endpoints limit 10;
exit
exit
```
Modify the [app/create-hostgroups.yml](app/create-hostgroups.yml) file with the NetProfiler details for your environment:
```
  vars:
    host: "NetProfiler ipv4 address"
    access_code: "Oauth access code"
    tenant: "myTenant"
```
Run the ansible-playbook within the ansible container:
```
docker exec -ti ansible /bin/bash
ansible-playbook -vvv create-hostgroups.yml
```
## Production
The ACI script can be run in one-off mode (the default) or in daemon mode. In one-off mode, the script pulls the endpoint data from the APIC and adds the entries matching the specified Tenant to the MySQL database.
If an entry already exists (matching the MAC address) then it is updated to capure any changed details. Without one-off mode (default is now one-off mode) ithe application will keep running, listening for APIC events and updating the database accordingly.
In daemon mode, the application puts itself into the background.

For deployment, one could run the script chain from a cronjob or cronjobs, e.g. once an hour:
1. Run the ACI script to update the MySQL database
2. Run the Ansible script to update the Host Group definitions

## Limitations
1. The current model only handles one Tenant. One might extend the model to support multiple tenants with separate Host Group Types per Tenant, for instance.

## Troubleshooting
1. Make sure the access information and credentials are correct for the APIC
2. Make sure the access information and credentials are correct for the NetProfiler - note that the OAuth tokens expire so will need renewing at some point
3. If there are Python errors make sure that nothing is installed that is not compatible with the old version of Python used by the ACI toolkit (Python version 2.7)

## Reference
The [aci-endpoint-tracker](acitoolkit/applications/endpointtracker/aci-endpoint-tracker-rvbd.py) script provides the following online help:
```
root@c5aa4f455f11:/opt/acitoolkit/applications/endpointtracker# python aci-endpoint-tracker-rvbd.py --help
usage: aci-endpoint-tracker-rvbd.py [-h] [-u URL] [-l LOGIN] [-p PASSWORD]
                                    [--cert-name CERT_NAME] [--key KEY]
                                    [--snapshotfiles SNAPSHOTFILES [SNAPSHOTFILES ...]]
                                    [-i MYSQLIP] [-a MYSQLLOGIN]
                                    [-s MYSQLPASSWORD] [-d] [--kill]
                                    [--restart] [-o]

Application that logs on to the APIC and tracks all of the Endpoints in a
MySQL database.

optional arguments:
  -h, --help            show this help message and exit
  -u URL, --url URL     APIC URL e.g. http://1.2.3.4
  -l LOGIN, --login LOGIN
                        APIC login ID.
  -p PASSWORD, --password PASSWORD
                        APIC login password.
  --cert-name CERT_NAME
                        X.509 certificate name attached to APIC AAA user
  --key KEY             Private key matching given certificate, used to
                        generate authentication signature
  --snapshotfiles SNAPSHOTFILES [SNAPSHOTFILES ...]
                        APIC configuration files
  -i MYSQLIP, --mysqlip MYSQLIP
                        MySQL IP address.
  -a MYSQLLOGIN, --mysqllogin MYSQLLOGIN
                        MySQL login ID.
  -s MYSQLPASSWORD, --mysqlpassword MYSQLPASSWORD
                        MySQL login password.
  -d, --daemon          Run as a Daemon
  --kill                if run as a process, kill it
  --restart             if run as a process, restart it
  -o, --oneoff          Run one pass only and exit
  ```
## Copyright (c) 2023 Riverbed Technology
