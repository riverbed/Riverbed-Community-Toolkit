# Riverbed Community Toolkit
# NetIM GMC - Azure Bandwidth Cost
#
# Usage
# python azureBandwidthCost.py <NetIMdeviceName> <NetIMmetricClass> <NetIMGMCPath> <AzureSubscriptionId> <AzureTenantId> <AzureClient_id> <AzureClient_secret> 
#
# where
# <NetIMdeviceName> is the device name created in NetIM (with Access Adress: 127.0.0.200 (it is a fake adress and can be any loopback)
# <NetIMmetricClass> is the metric id provided by NetIM when importing the .mib file, ex. CM_191125133755 
# <NetIMGMCPath>
# <AzureSubscriptionId>
# <AzureTenantId>
# <AzureClient_id> 
# <AzureClient_secret>
#
# OUTPUT sapmle:
# [SampleDataHeader][name=azureBandwidthCost]
# [metricClass=metric]timestamp,pretaxcost,billingmonth,servicename,currency
# [TargetInfoHeader]HEADERNAME,SYSNAME
# [TI]azureBandwidthCost,12341234-1234-1234-1234-123412341234[SI][SD]1574679221,34.86519916688411,2019-11-01T00:00:00,bandwidth,USD

import json
import sys
import time
import requests
import adal
from pprint import pprint

print(sys.argv)

if len(sys.argv) == 1:
    print("Arguments Not Given")
    sys.exit(2)
elif (len(sys.argv)) > 1 and (len(sys.argv)) < 6:
    print("Wrong number of arguments")
    sys.exit(2)

arg = sys.argv

TENANT = arg[5]
CLIENT_ID = arg[6]
CLIENT_SECRET = arg[7]

def authenticate_client_key():
    """
    Authenticate using service principal w/ key.
    """
    authority_host_uri = 'https://login.microsoftonline.com'
    tenant = TENANT
    authority_uri = authority_host_uri + '/' + tenant
    resource_uri = 'https://management.core.windows.net/'
    client_id = CLIENT_ID
    client_secret = CLIENT_SECRET

    context = adal.AuthenticationContext(authority_uri, api_version=None)
    mgmt_token = context.acquire_token_with_client_credentials(resource_uri, client_id, client_secret)

    return mgmt_token['accessToken']

if __name__== "__main__":

    # print ('Number of arguments:', len(sys.argv))
    # print ('Argument List:', arg)

    deviceName = arg[1]
    metricClass = arg[2]
    gmcPath = arg[3]
    subscriptionId = arg[4]

    endpoint = "https://management.azure.com/%2Fsubscriptions%2F" + subscriptionId + "/providers/Microsoft.CostManagement/query"
    api_version = '?api-version=2019-10-01'
    url = endpoint + api_version
    auth_token = authenticate_client_key()
    headers = {'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + auth_token }

    data = {
        "type": "Usage",
        "timeframe": "MonthToDate",
        "dataset": {
            "granularity": "Monthly",
            "aggregation": {
                "totalCost": {
                    "name": "PreTaxCost",
                    "function": "Sum"
                }
            },
            "grouping": [
                {
                    "type": "Dimension",
                    "name": "ServiceName"
                }
            ],
            "filter": {
                "dimensions": {
                    "name": "ServiceName",
                    "operator": "In",
                    "values": [
                        "bandwidth"
                    ]
                }
            }
        }
    }

    resp = requests.post(url, data = json.dumps(data), headers=headers)
    if resp.status_code != 200:
        print ("Error while requesting POST")
        print(resp.status_code, resp.reason)
        sys.exit(2)

    #print(resp.status_code, json.loads(resp.text))

    result = json.loads(resp.text)

    basename = "azureBandwidthCost"
    print(gmcPath)
    filename = gmcPath + basename + time.strftime('%Y%m%d%H%M%S') + '.mtr'
    timestamp = int(time.time()*1000)
    pretaxcost = int(result['properties']['rows'][0][0])
    with open(filename, 'a') as f:
        f.write('[SampleDataHeader][name={}]'.format(basename))
        f.write('[metricClass={}]timestamp,pretaxcost,billingmonth,servicename,currency\n'.format(metricClass))
        f.write('[TargetInfoHeader]HEADERNAME,SYSNAME\n')
        f.write('[TI]{},{}[SI][SD]{},{},{},{},{}\n'.format(basename, deviceName,timestamp, pretaxcost , result['properties']['rows'][0][1], result['properties']['rows'][0][2], result['properties']['rows'][0][3]))
        f.close()
