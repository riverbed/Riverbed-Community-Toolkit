import argparse
from pysnmp.hlapi import *
import sys




def get_bgp_peer_state(ip_address, snmp_version, community_string, peer_ip):
    if snmp_version == 'v2':
        errorIndication, errorStatus, errorIndex, varBinds = next(
            getCmd(SnmpEngine(),
                   CommunityData(community_string),
                   UdpTransportTarget((ip_address, 161)),
                   ContextData(),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.2.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.3.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.9.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.14.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.16.' + peer_ip)))
        )
    elif snmp_version == 'v3':
        errorIndication, errorStatus, errorIndex, varBinds = next(
            getCmd(SnmpEngine(),
                   UsmUserData(community_string),
                   UdpTransportTarget((ip_address, 161)),
                   ContextData(),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.2.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.3.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.9.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.14.' + peer_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.16.' + peer_ip)))
        )

    if errorIndication:
        print(f"Error: {errorIndication}")
        sys.exit(1)

    if errorStatus:
        print(f"Error: {errorStatus.prettyPrint()} {errorIndex and varBinds[int(errorIndex) - 1][0] or ''}")
        sys.exit(1)

    for varBind in varBinds:
        oid = varBind[0]
        value = varBind[1]
        print(f"{oid}: {value}")
    
def get_bgp_peer_state_description(state):
    if state == 6:
        return "UP"
    else:
        return "DOWN"
        
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Retrieve BGP peer state using SNMP')
    parser.add_argument('ip_address', type=str, help='IP address of the device')
    parser.add_argument('snmp_version', type=str, choices=['v2', 'v3'], help='SNMP version (v2 or v3)')
    parser.add_argument('community_string', type=str, help='Community string (for v2) or security name (for v3)')
    parser.add_argument('peer_ips', type=str, help='Comma-separated list of peer IP addresses')
    
    args = parser.parse_args()
peer_ips = args.peer_ips.split(",")

for peer_ip in peer_ips:
    print(f"Retrieving BGP Peer state for {peer_ip}...")
    state_oid = '1.3.6.1.2.1.15.3.1.2.' + peer_ip
    errorIndication, errorStatus, errorIndex, varBinds = next(
        getCmd(SnmpEngine(),
               CommunityData(args.community_string) if args.snmp_version == 'v2' else UsmUserData(args.community_string),
               UdpTransportTarget((args.ip_address, 161)),
               ContextData(),
               ObjectType(ObjectIdentity(state_oid)),
               ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.3.' + peer_ip)),
               ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.9.' + peer_ip)),
               ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.14.' + peer_ip)),
               ObjectType(ObjectIdentity('1.3.6.1.2.1.15.3.1.16.' + peer_ip)))
    )

    if errorIndication:
        print(f"Error: {errorIndication}")
        sys.exit(1)
    elif errorStatus:
        print(f"Error: {errorStatus.prettyPrint()} {errorIndex and varBinds[int(errorIndex) - 1][0] or ''}")
        sys.exit(1)
    else:
        state = int(varBinds[0][1])
        print(f"BGP Peer state for {peer_ip} is {get_bgp_peer_state_description(state)} ({state})")

sys.exit(0)

