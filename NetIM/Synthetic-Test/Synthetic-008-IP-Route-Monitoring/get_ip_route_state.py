import argparse
import sys
from pysnmp.hlapi.auth import HMAC_MD5_AUTH_PROTOCOL, HMAC_SHA_AUTH_PROTOCOL
from pysnmp.hlapi.priv import DES_PRIV_PROTOCOL, _3DES_EDE_PRIV_PROTOCOL, AES_PRIV_PROTOCOL, AES192_PRIV_PROTOCOL, AES256_PRIV_PROTOCOL
from pysnmp.hlapi import *


def get_ip_route_state(ip_address, snmp_version, community_string, dest_ip, security_level=None, auth_protocol=None, auth_password=None, priv_protocol=None, priv_password=None):
    if snmp_version == 'v2':
        errorIndication, errorStatus, errorIndex, varBinds = next(
            getCmd(SnmpEngine(),
                   CommunityData(community_string),
                   UdpTransportTarget((ip_address, 161)),
                   ContextData(),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.4.21.1.8.' + dest_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.4.21.1.11.' + dest_ip)))
        )
    elif snmp_version == 'v3':
        user_data = UsmUserData(userName=community_string, authProtocol=auth_protocol, authKey=auth_password, privProtocol=priv_protocol, privKey=priv_password)
        if security_level == 'authPriv':
            user_data.securityModel = 3
        elif security_level == 'authNoPriv':
            user_data.securityModel = 2
        elif security_level == 'noAuthNoPriv':
            user_data.securityModel = 1

        errorIndication, errorStatus, errorIndex, varBinds = next(
            getCmd(SnmpEngine(),
                   user_data,
                   UdpTransportTarget((ip_address, 161)),
                   ContextData(),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.4.21.1.8.' + dest_ip)),
                   ObjectType(ObjectIdentity('1.3.6.1.2.1.4.21.1.11.' + dest_ip)))
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


def get_ip_route_state_description(state):
    if state == 1:
        return "Other"
    elif state == 2:
        return "Invalid"
    elif state == 3:
        return "Local"
    elif state == 4:
        return "Remote"
    elif state == 5:
        return "Prohibited"
    else:
        return "Unknown"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Retrieve IP route state using SNMP')
    parser.add_argument('ip_address', type=str, help='IP address of the device')
    parser.add_argument('snmp_version', type=str, choices=['v2', 'v3'], help='SNMP version (v2 or v3)')
    parser.add_argument('community_string', type=str, help='Community string (for v2) or security name (for v3)')
    parser.add_argument('dest_ip', type=str, help='Destination IP address')

    # Add arguments for SNMPv3
    parser.add_argument('--security_level', type=str, choices=['noAuthNoPriv', 'authNoPriv', 'authPriv'], help='Security level for SNMPv3')
    parser.add_argument('--auth_protocol', type=str, choices=['MD5', 'SHA'], help='Authentication protocol for SNMPv3', dest='auth_protocol')
    parser.add_argument('--auth_password', type=str, help='Authentication password for SNMPv3')
    parser.add_argument('--priv_protocol', type=str, choices=['DES', '3DES', 'AES'], help='Privacy protocol for SNMPv3', dest='priv_protocol')
    parser.add_argument('--priv_password', type=str, help='Privacy password for SNMPv3')

    args = parser.parse_args()

    if args.auth_protocol == 'MD5':
        args.auth_protocol = usmHMACMD5AuthProtocol
    elif args.auth_protocol == 'SHA':
        args.auth_protocol = usmHMACSHAAuthProtocol

    if args.priv_protocol == 'DES':
        args.priv_protocol = usmDESPrivProtocol
    elif args.priv_protocol == '3DES':
        args.priv_protocol = usm3DESEDEPrivProtocol
    elif args.priv_protocol == 'AES':
        args.priv_protocol = usmAesCfb128Protocol

    print(f"Retrieving IP route state for {args.dest_ip}...")
    state_oid = '1.3.6.1.2.1.4.21.1.8.' + args.dest_ip

    # Pass the new arguments to the function
    get_ip_route_state(args.ip_address, args.snmp_version, args.community_string, args.dest_ip, args.security_level, args.auth_protocol, args.auth_password, args.priv_protocol, args.priv_password)

