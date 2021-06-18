#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: bootstrap
short_description: Configure the initial AppResponse appliance settings.
options:
	hostname:
		description:
			- Hostname of the AppResponse appliance.
		required: True
	username:
		description:
			- Username used to login to the AppResponse appliance.
		required: True
	password:
		description:
			- Password used to login to the AppResponse appliance
		required: True
	terminal_ip:
		description:
			- IP address to reach serial port
		required: False
	terminal_port:
		description:
			- Port to reach serial port
		required: False
	dhcp_ip:
		description:
			- Initial IP address to use SSH session for bootstrap
		required: False
	ip:
		description:
			- IP address of the management interface (primary) of the AppResponse appliance
		required: True
	mask:
		description:
			- Mask of the management interface (primary) of the AppResponse appliance
		required: True
	gateway:
		description:
			- Gateway for the AppResponse management interface (primary)
		required: True
	reset:
		description:
			- True, if performing a factory-reset on the device during bootstrap; false by default
		required: False
	
"""
EXAMPLES = """
#Usage Example 1
	- name: Bootstrap the AppResponse appliance
	  bootstrap:
		host: appresponse01
		username: admin
		password: admin
		terminal_ip: 192.168.1.1
		terminal_port: 8000
		ip: 10.1.1.2
		mask: 255.255.255.0
		gateway: 10.1.1.1

#Usage Example 2
	- name: Bootstrap the AppResponse appliance
	  bootstrap
		host: appresponse02
		username: admin
		password: admin
		dhcp_ip: 192.168.1.1
		ip: 10.1.1.2
		mask: 255.255.255.0
		gateway: 10.1.1.1

"""
RETURN = r'''
output:
	description: Result of bootstrap operation
	returned: success
	type: list
msg:
	description: Status
	returned: success
	type: str
'''

BOOTSTRAP_CONNECTION_TERMINAL = 'TERMINAL'
BOOTSTRAP_CONNECTION_SSH = 'SSH'

BOOTSTRAP_TERMINAL_PASSWORD_PROMPT = 'Password: '
BOOTSTRAP_TERMINAL_PASSWORD_REQUEST = 'Enter Terminal Password: '

BOOTSTRAP_CONSOLE_LOGIN_PROMPT_REGEX = '.* login: '
BOOTSTRAP_CONSOLE_CLI_PROMPT_REGEX = '.* > '
BOOTSTRAP_CONSOLE_ENABLE_PROMPT_REGEX = '.* # '
BOOTSTRAP_CONSOLE_CONFIG_PROMPT_REGEX = '.* \(config\) # '
BOOTSTRAP_CONSOLE_PROMPT_REGEX_LIST = [BOOTSTRAP_CONSOLE_LOGIN_PROMPT_REGEX, BOOTSTRAP_CONSOLE_CLI_PROMPT_REGEX, BOOTSTRAP_CONSOLE_ENABLE_PROMPT_REGEX, BOOTSTRAP_CONSOLE_CONFIG_PROMPT_REGEX]
BOOTSTRAP_CONSOLE_PASSWORD_PROMPT_REGEX = 'Password: '

BOOTSTRAP_SSH_CLI_PROMPT_REGEX = '.* > '
BOOTSTRAP_SSH_ENABLE_PROMPT_REGEX = '.* # '
BOOTSTRAP_SSH_CONFIG_PROMPT_REGEX = '.* \(config\) # '
BOOTSTRAP_SSH_PASSWORD_PROMPT_REGEX = '.* password:'

class BootstrapApp(object):

	def __init__(self, hostname=None, username=None, password=None, terminal_ip=None, terminal_port=None, terminal_password=None, dhcp_ip=None, ip=None, mask=None, gateway=None, reset=False):

		self.hostname = hostname
		self.username = username
		self.password = password
		self.terminal_ip = terminal_ip
		self.terminal_port = terminal_port
		self.terminal_password = terminal_password
		self.dhcp_ip = dhcp_ip
		self.ip = ip
		self.mask = mask
		self.gateway = gateway
		self.reset = reset

		if self.terminal_ip != None:
			self.connection_type = BOOTSTRAP_CONNECTION_TERMINAL
			try:
				self.console = self.appresponse_console_login()
			except:
				raise RuntimeError('ERROR: Unable to complete login through terminal')
			self.child = self.console
		elif self.dhcp_ip != None or self.ip != None:
			self.connection_type = BOOTSTRAP_CONNECTION_SSH
			try:
				self.ssh_to_ip = self.appresponse_ssh_login()
			except TypeError as e:
				raise
			except NameError as e:
				raise
			except:
				raise RuntimeError('ERROR: Unable to SSH to provided IP address')
			self.child = self.ssh_to_ip

		if self.child == None:
			raise RuntimeError('ERROR: Unable to create initial connection to AppResponse appliance')

	def drives(self, ip=None):
		import requests
		import json

		if ip == None:
			ip = self.ip

		session = requests.Session()
		session.verify = False
		session.headers.update({"Content-Type": "application/json"})
		data = {"user_credentials": {"username": self.username, "password": self.password}}

		resp = session.post('https://' + ip + '/api/mgmt.aaa/1.0/token', data=json.dumps(data))
		session.headers.update({"Authorization": "Bearer " + json.loads(resp.content)['access_token']})
		services = {}
		for service in json.loads(session.get('https://' + ip + '/api/common/1.0/services').content):
			versions = [float(version) for version in service['versions']]
			version = sorted(versions).pop()
			services[service['id']] = '/api/' + service['id'] + '/' + str(version)
		chassis = json.loads(session.get('https://' + ip + services['npm.hardware_monitor'] + '/chassis').content)['items']
		return [drive['serial_number'] for drive in chassis if not drive['headunit'] and drive['availability'] != 'available']

	def wait(self, count=0, limit=5):
		if count >= limit:
			return
		self.child.sendline()
		time.sleep(30)
		self.wait(count+1, limit)

	def reconnect(self):
		# No changes should be required if going through a terminal server
		if self.connection_type == BOOTSTRAP_CONNECTION_TERMINAL:
			self.child = self.console
		elif self.dhcp_ip != None:
			self.connection_type = BOOTSTRAP_CONNECTION_SSH
			self.ssh_to_ip = self.appresponse_ssh_login(self.dhcp_ip)
			self.child = self.ssh_to_ip
		else:
			self.connection_type = BOOTSTRAP_CONNECTION_SSH
			self.ssh_to_ip = self.appresponse_ssh_login(self.ip)
			self.child = self.ssh_to_ip

	def ssh_login(self, ip):
		import pexpect

		try:
			command = "/usr/bin/ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' " 
			command = command + f"{self.username}@{ip} -p 22"
			ssh_session = pexpect.spawn(command, timeout=450, encoding='utf-8')
		except NameError as e:
			return None
		except:
			return None

		return ssh_session
	
	def appresponse_ssh_login(self, ip=None, timeout=-1):
		import pexpect

		target_ip = None
		if ip == None:
			if self.dhcp_ip != None:
				target_ip = self.dhcp_ip
			elif self.ip != None:
				target_ip = self.ip
		else:
			target_ip = ip

		try:
			ssh_session = self.ssh_login(target_ip)
		except NameError as e:
			return None
		except:
			return None

		ssh_session.expect(BOOTSTRAP_SSH_PASSWORD_PROMPT_REGEX)
		ssh_session.sendline(self.password)
		ssh_session.expect(BOOTSTRAP_SSH_CLI_PROMPT_REGEX)
		if '> ' in ssh_session.after:
			ssh_session.sendline('enable')
			ssh_session.expect(BOOTSTRAP_SSH_ENABLE_PROMPT_REGEX)
		if '# ' in ssh_session.after and '(config)' not in ssh_session.after:
			ssh_session.sendline('configure terminal')
			ssh_session.expect(BOOTSTRAP_SSH_CONFIG_PROMPT_REGEX)

		return ssh_session

	def terminal_login(self):
		import pexpect

		try:
			terminal = pexpect.spawn(f"ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' "
				f"{self.terminal_ip} -p {self.terminal_port}", timeout=450, encoding='utf-8') 	
		except:
			return None

		terminal.expect(BOOTSTRAP_TERMINAL_PASSWORD_PROMPT)
		if self.terminal_password == None:
			terminal.sendline(getpass(BOOTSTRAP_TERMINAL_PASSWORD_REQUEST))
		else:
			terminal.sendline(self.terminal_password)
		terminal.sendline()

		return terminal

	def appresponse_console_login(self, timeout=-1):
		import pexpect

		console = self.terminal_login()

		console.sendline()
		console.expect(BOOTSTRAP_CONSOLE_PROMPT_REGEX_LIST, timeout=timeout)
		if 'login: ' in console.after:
			console.sendline(self.username)
			console.expect(BOOTSTRAP_CONSOLE_PASSWORD_PROMPT)
			console.sendline(self.password)
			console.expect(BOOTSTRAP_CONSOLE_CLI_PROMPT_REGEX)
		if '> ' in console.after:
			console.sendline('enable')
			console.expect(BOOTSTRAP_CONSOLE_ENABLE_PROMPT_REGEX)
		if '# ' in console.after and '(config)' not in console.after:
			console.sendline('configure terminal')
			console.expect(BOOTSTRAP_CONSOLE_CONFIG_PROMPT_REGEX)

		return console

	def factory_reset(self):
		import pexpect

		self.child.sendline('system reset-factory')
		time.sleep(5) # In testing, expect does not work here so need to sleep and send confirm
		self.child.sendline('confirm')
		self.child.expect(BOOTSTRAP_CONSOLE_PROMPT_REGEX_LIST)

		try:
			if 'Confirmed - the system will now reboot' in self.child.after.decode('utf-8'):
				### Message that the factory reset has started
				self.wait(0, 30)
				return True
		except pexpect.EOF:
			self.reconnect()
			return True
		except:
			return False

	def wizard(self):
		import pexpect

		self.child.sendline('wizard')

		self.child.expect('Hostname.*: ')
		self.child.sendline(self.hostname)
		self.child.expect('Primary interface DHCP.*: ')
		self.child.sendline("no")
		self.child.expect('Primary interface IP address.*: ')
		self.child.sendline(self.ip)
		self.child.expect('Primary interface subnet mask.*: ')
		self.child.sendline(self.mask)
		self.child.expect('Aux interface enabled.*: ')
		self.child.sendline("no")
		self.child.expect('Default gateway.*: ')
		self.child.sendline(self.gateway)
		self.child.expect('DNS servers.*: ')
		self.child.sendline()
		self.child.expect('DNS domain names.*: ')
		self.child.sendline()
		self.child.expect('Timezone.*: ')
		self.child.sendline("UTC")
		self.child.expect("Enter 'quit' to quit without changing.*")

		try:
			self.child.sendline('save')
			self.child.expect(BOOTSTRAP_CONSOLE_CONFIG_PROMPT_REGEX)
		except pexpect.EOF:
			if self.connection_type == BOOTSTRAP_CONNECTION_SSH:
				self.wait(20)
				self.child = appresponse_ssh_login()

	def init_drives(self):
		drives = self.drives()
		for drive in drives:
			self.child.sendline(f'storage data_section {drive} reinitialize mode RAID0')
			self.wait()
			self.child.expect(BOOTSTRAP_CONSOLE_CONFIG_PROMPT_REGEX)

	def logout(self):
		import pexpect
		try:
			self.child.sendline('exit')
			self.child.expect(BOOTSTRAP_CONSOLE_ENABLE_PROMPT_REGEX)
			self.child.sendline('exit')
			self.child.expect([BOOTSTRAP_CONSOLE_LOGIN_PROMPT_REGEX, pexpect.EOF], timeout=None)
			self.child.close()
		except:
			raise

	def run(self):

		# If reset, factory reset
		if self.reset == True:
			try:
				status = self.factory_reset()
				status = True
			except:
				status = False

			if status == False:
				return False, "Factory reset did not complete as expected."
 
		# Run setup wizard
		self.wizard()

		# Initialize drives
		self.init_drives()

		# Logout
		self.logout()

		return True, "Bootstrap complete."

def main():
	# Creating an Ansible module
	from ansible.module_utils.basic import AnsibleModule

	# Initiate the Ansible module class with input argument information and types
	arg_dict = {"hostname": {"required":True, "type":"str"},
		"username": {"required":True, "type":"str"},
		"password": {"required":True, "type":"str", "no_log":True},
		"terminal_ip": {"required":False, "type":"str"},
		"terminal_port": {"required":False, "type":"str"},
		"terminal_password": {"required":False, "type":"str", "no_log":True},
		"dhcp_ip": {"required":False, "type":"str"},
		"ip": {"required":True, "type":"str"},
		"mask": {"required":True, "type":"str"},
		"gateway": {"required":True, "type":"str"},
		"reset": {"required":False, "type":"bool", "default":"False"}}
	module = AnsibleModule(argument_spec=arg_dict, supports_check_mode=False)

	# Check that the dependencies are present to avoid an exception in execution
	try:
		import pexpect
	except ImportError:
		module.fail_json(msg="The pexpect Python module could not be imported during the execution of the AppResponse Bootstrap Ansible module")

	# Check that other dependencies are also present
	try:
		import requests
		import urllib3
		urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

		import json
		import time
		from getpass import getpass
	except ImportError as e:
		module.fail_json(msg="Required Python modules could not be imported.")

	try:
		# Initialize connection to appliance
		bootstrap = BootstrapApp(hostname=module.params['hostname'], 
			username=module.params['username'], password=module.params['password'],
			terminal_ip=module.params['terminal_ip'], terminal_port=module.params['terminal_port'],
			ip=module.params['ip'], mask=module.params['mask'], gateway=module.params['gateway'], 
			reset=module.params['reset'])

		# Run
		success, msg = bootstrap.run() 
	except pexpect.TIMEOUT as e:
		module.fail_json(msg=f"pexpect.TIMEOUT: Unexpected timeout waiting for prompt or command: {e}")
	except pexpect.EOF as e:
		module.fail_json(msg=f"pexpect.EOF: Unexpected program termination: {e}")
	except pexpect.exceptions.ExceptionPexpect as e:
		module.fail_json(msg="pexpect.exceptions.{0}: {1}".format(type(e).__name__, e))
	except RuntimeError as e:
		module.fail_json(msg=f"RuntimeError: {e}")

	module.exit_json(changed=success,output=msg)

if __name__ == '__main__':
	main()

