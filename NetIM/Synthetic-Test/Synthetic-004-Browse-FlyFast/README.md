# Synthetic Test - Browse FlyFast

Usecase: App monitoring
Recommended Robot: Web Selenium

This synthetic test is for FlyFast, a flight booking demo app shared on GitHub by the [Riverbed-Community-Toolkit](https://github.com/riverbed/Riverbed-Community-Toolkit).
It runs on a simple [Web Selenium robot setup](../Robot-001-WebSelenium) (based on Windows, Chrome, Python, Selenium,...).

## Preparation

### Step 1. Get the URL of FlyFast

The URL can be the IP address, for example if deployed locally http://192.168.0.23, or a FQDN for example http://flyfast.yourcorp.net.

If you want to install your own instance of FlyFast, please refer to the Cookbook 001 in [Riverbed-Community-Toolkit](https://github.com/riverbed/Riverbed-Community-Toolkit).

### Step 2. Fetch the script on the machine to run the test

Hit this [ZIP archive](https://github.com/riverbed/Riverbed-Community-Toolkit/archive/refs/heads/master.zip) to download the ZIP archive, and the expand it, for example in C:\Riverbed-Community-Toolkit)

The steps to prepare a Web Selenium robot setup are described [here](../Robot-001-WebSelenium).

### Step 3. Configure the script

Edit the the Python script Chrome-browse-flyfast.py, and set the FlyFast URL in the variable BASE_URL (line 52) 

```python
##################################################################
# Synthetic test

    # TODO: set your url
    BASE_URL = "https://flyfast.yourcorp.net"
```

### Step 4. Run the Synthetic Test

In PowerShell

```PowerShell
python.exe "C:\Riverbed-Community-Toolkit\NetIM\Synthetic-Test\Synthetic-004-Browse-FlyFast\Chrome-browse-flyfast.py"
```

### *optional* Configure a monitor in NetIM

In NetIM web console, create a new Synthetic Test

- Type: External Script
- Command: 

```shell
"C:\Program Files\Python311\python.exe" "C:\Riverbed-Community-Toolkit\NetIM\Synthetic-Test\Synthetic-004-Browse-FlyFast\Chrome-browse-flyfast.py"
```

## License

The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.

## Copyright (c) 2023 Riverbed Technology, Inc.
