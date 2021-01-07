import json
import requests
import base64

#replace xxxx with fqdn of the SCCM
controller="xxxxx"
#replace xxxx with access_code generated on the SCCM page
#https://host/mgmt/gui?p=setupRESTInterface
access_code='xxxxx'


def get_token(access_code):

    api_url='/api/common/1.0.0/oauth/token'

    #https://supportkb.riverbed.com/support/index?page=content&id=S24393&actp=search&viewlocale=en_US&searchid=1609955176980
    a=base64.b64encode(b'{"alg":"none"}\n')
    b=access_code
    c=''

    total_access_code=a.decode("ascii")+"."+b+"."+c

    payload = {'grant_type': 'access_code','assertion': total_access_code, 'state': 'state_string'}
    r = requests.post(controller+api_url, verify=False, data=payload)

    content_dict = json.loads(r.text)

    return content_dict['access_token']


def get_services(token):
    api_url = '/api/appliance/1.0.0/services'
    headers = {"Authorization": "Bearer "+token}
    r = requests.get(controller+api_url, verify=False, headers=headers)
    return json.loads(r.text)


def get_license(token):
    api_url = '/api/appliance/1.0.0/status/license'
    headers = {"Authorization": "Bearer " + token}
    r = requests.get(controller + api_url, verify=False, headers=headers)
    return json.loads(r.text)


def main():
    my_token = get_token(access_code)
    print(get_services(my_token))
    print(get_license(my_token))


if __name__ == '__main__':
    main()











