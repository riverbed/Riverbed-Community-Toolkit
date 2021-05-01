# Client Accelerator

Here are some cookbooks for [Client Accelerator](https://www.riverbed.com/products/steelhead/client-accelerator.html)

## Deploy a Client Accelerator Controller in Azure with Terraform

The [terraform template](Azure/Terraform) automate a Client Accelerator Controller instance deployment in Azure.

## Interact with the Controller REST API

With [SteelScript](https://github.com/riverbed/steelscript) this [cacontroller-rest_api example](https://github.com/riverbed/steelscript-client-accelerator-controller/blob/main/examples/cacontroller-rest_api.py) is easy to use and extend:

```bash
python examples/cacontroller-examples/cacontroller-rest_api.py {client accelerator controller fqdn or ip address} --access_code {access_code}
```

Without [SteelScript](https://github.com/riverbed/steelscript), this [Python script example](REST/Client_Accelerator_Controller_restapi.py) shows how to connect to the Client Accelerator Controller API.

For more details, refer to

- [SteelScript Python Library](https://github.com/riverbed/steelscript)
- [API reference](https://support.riverbed.com/apis/_products/SteelCentral_Controller_for_SteelHead_Mobile/index.html)
- an [excellent blog](https://gestaltit.com/tech-talks/riverbed/riverbed-2020/nwkautomaniac/getting-started-with-the-steelhead-client-accelerator-controller-api-part-1/) that explains everything

## Ansible playbook examples interacting with the Client Accelerator Controller

This [ansible playbook](Ansible-101-Playbook/) shows how to connect to the Client Accelerator Controller. It uses [SteelScript Python Library](https://github.com/riverbed/steelscript) to interact with the appliance API.

## Copyright (c) 2021 Riverbed Technology
