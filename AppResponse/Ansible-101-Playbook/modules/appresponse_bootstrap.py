#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2021 Riverbed Technology Inc.
# The MIT License (MIT) (see https://opensource.org/licenses/MIT)

DOCUMENTATION = """
---
module: appresponse_bootstrap
short_description: Configure the initial AppResponse appliance settings.
options:
	hostname:
		description:
			- Hostname of the AppResponse appliance.
		required: True
	username:
		description:
			- Username used to login to the AppResponse appliance
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
	terminal_username:
		description:
			- Username used to login through terminal server connected to serial/console port
		required: False
	terminal_password:
		description:
			- Password to reach serial port
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
	- name: Bootstrap the AppResponse appliance using terminal server connected to console port
	  appresponse_bootstrap:
		host: appresponse01
		username: admin
		password: admin
		terminal_ip: 192.168.1.1
		terminal_port: 8000
		terminal_username: admin
		terminal_password: admin
		ip: 10.1.1.2
		mask: 255.255.255.0
		gateway: 10.1.1.1

#Usage Example 2
	- name: Bootstrap the AppResponse appliance using SSH to DHCP IP address
	  appresponse_bootstrap
		host: appresponse02
		username: admin
		password: admin
		dhcp_ip: 192.168.1.1
		ip: 10.1.1.2
		mask: 255.255.255.0
		gateway: 10.1.1.1
		reset: True

"""
RETURN = r'''
output:
	description: Result of bootstrap operation
	returned: always
	type: str
	sample: Bootstrap complete.
'''

BOOTSTRAP_CONNECTION_TERMINAL = 'TERMINAL'
BOOTSTRAP_CONNECTION_SSH = 'SSH'

BOOTSTRAP_TERMINAL_PASSWORD_PROMPT = u'Password: '
BOOTSTRAP_TERMINAL_PASSWORD_REQUEST = u'Enter Terminal Password: '

BOOTSTRAP_LOGIN_PROMPT_REGEX = u'.* login: '
BOOTSTRAP_CLI_PROMPT_REGEX = u'.* > '
BOOTSTRAP_ENABLE_PROMPT_REGEX = u'.* # '
BOOTSTRAP_CONFIG_PROMPT_REGEX = u'.* \(config\) # '
BOOTSTRAP_PASSWORD_PROMPT_REGEX = u'[pP]assword: '
BOOTSTRAP_PROMPT_REGEX_LIST = [BOOTSTRAP_LOGIN_PROMPT_REGEX, BOOTSTRAP_CLI_PROMPT_REGEX, BOOTSTRAP_ENABLE_PROMPT_REGEX, BOOTSTRAP_CONFIG_PROMPT_REGEX]

BOOTSTRAP_SSH_COMMAND = "/usr/bin/ssh"
BOOTSTRAP_SSH_ARGS = ["-o StrictHostKeyChecking no", "-o UserKnownHostsFile /dev/null"]
BOOTSTRAP_CONSOLE_COMMAND = "/usr/bin/ssh"
BOOTSTRAP_CONSOLE_ARGS = ["-o StrictHostKeyChecking no", "-o UserKnownHostsFile /dev/null"]

BOOTSTRAP_ENABLE = u'enable'
BOOTSTRAP_CONFIG = u'configure terminal'

BOOTSTRAP_RESET = u'system reset-factory'
BOOTSTRAP_CONFIRM = u'confirm'
BOOTSTRAP_DEFAULT_PASSWORD = u'admin'
BOOTSTRAP_RESET_WAIT = 20 # increments of 30 seconds; 10 = 5 minutes, 20 = 10 minutes, etc.

BOOTSTRAP_WIZARD = u'wizard'
BOOTSTRAP_WIZARD_HOSTNAME_REGEX = u'Hostname.*: '
BOOTSTRAP_WIZARD_DHCP_REGEX = u'Primary interface DHCP.*: '
BOOTSTRAP_WIZARD_IPADDRESS_REGEX = u'Primary interface IP address.*: '
BOOTSTRAP_WIZARD_SUBNETMASK_REGEX = u'Primary interface subnet mask.*: '
BOOTSTRAP_WIZARD_AUX_REGEX = u'Aux interface enabled.*: '
BOOTSTRAP_WIZARD_DEFAULTGATEWAY_REGEX = u'Default gateway.*: '
BOOTSTRAP_WIZARD_DNSSERVERS_REGEX = u'DNS servers.*: '
BOOTSTRAP_WIZARD_DNSDOMAINNAMES_REGEX = u'DNS domain names.*: '
BOOTSTRAP_WIZARD_TIMEZONE_REGEX = u'Timezone.*: '
BOOTSTRAP_WIZARD_CONFIGURE_STORAGE_UNITS_REGEX = u'Configure Storage Units.* .*: '
BOOTSTRAP_WIZARD_QUIT_REGEX = u"Enter 'quit' to quit without changing.*"

BOOTSTRAP_EXIT = u'exit'


class BootstrapApp(object):

	def __init__(self, hostname=None, username=None, password=None, terminal_ip=None, terminal_port=None, terminal_username=None, terminal_password=None, dhcp_ip=None, ip=None, mask=None, gateway=None, reset=False):

		import pexpect
		import sys

		self.hostname = hostname
		self.username = username
		self.password = password
		self.terminal_ip = terminal_ip
		self.terminal_port = terminal_port
		self.terminal_username = terminal_username
		self.terminal_password = terminal_password
		self.dhcp_ip = dhcp_ip
		self.ip = ip
		self.mask = mask
		self.gateway = gateway
		self.reset = reset

		self.pexpect_version = {}
		version_split = pexpect.__version__.split('.')
		version_split_len = len(version_split)
		if version_split_len == 1:
			self.pexpect_version['major'] = int(version_split[0])
		if version_split_len >= 2:
			self.pexpect_version['major'] = int(version_split[0])
			self.pexpect_version['minor'] = int(version_split[1])

		# If there is a terminal IP address set, prefer that as the connection
		if self.terminal_ip != None:
			self.connection_type = BOOTSTRAP_CONNECTION_TERMINAL
			try:
				self.console = self.appresponse_console_login()
			except:
				raise
			self.child = self.console
		# Otherwise, prefer DHCP and then static IP
		elif self.dhcp_ip != None or self.ip != None:
			self.connection_type = BOOTSTRAP_CONNECTION_SSH
			try:
				target_ip = None
				if self.dhcp_ip != None:
					target_ip = self.dhcp_ip
				elif self.ip != None:
					target_ip = self.ip
				if target_ip != None:
					self.ssh_to_ip = self.appresponse_ssh_login(ip=target_ip, password=self.password, timeout=600)
			except TypeError as e:
				raise
			except NameError as e:
				raise
			except pexpect.EOF:
				raise RuntimeError("ERROR: Failure when attempting to login to {} with username {}".format(target_ip, self.username))
			except:
				raise RuntimeError("ERROR: Unable to SSH to provided IP address due to exception '{}'".format(sys.exc_info()))
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

		resp = session.post('https://' + ip + '/api/mgmt.aaa/2.0/token', data=json.dumps(data))
		session.headers.update({"Authorization": "Bearer " + json.loads(resp.content)['access_token']})
		services = {}
		for service in json.loads(session.get('https://' + ip + '/api/common/1.0/services').content):
			versions = [float(version) for version in service['versions']]
			version = sorted(versions).pop()
			services[service['id']] = '/api/' + service['id'] + '/' + str(version)
		chassis = json.loads(session.get('https://' + ip + services['npm.hardware_monitor'] + '/chassis').content)['items']
		return [drive['serial_number'] for drive in chassis if not drive['headunit'] and drive['availability'] != 'available']

	def wait(self, count=0, limit=5):
		import time

		if count >= limit:
			return
		self.child.sendline()
		time.sleep(30)
		self.wait(count+1, limit)

	def reconnect(self, ip=None, password=None):
		# No changes should be required if going through a terminal server
		if self.connection_type == BOOTSTRAP_CONNECTION_TERMINAL:
			self.console = self.appresponse_console_login(ssh_to_terminal_still_active=True)
			self.child = self.console
		elif self.connection_type == BOOTSTRAP_CONNECTION_SSH:
			self.ssh_to_ip = self.appresponse_ssh_login(ip=ip, password=password, timeout=600)
			self.child = self.ssh_to_ip

	def ssh_login(self, ip, timeout=450):
		import pexpect
		import sys

		ssh_session = None
		try:
			command = BOOTSTRAP_SSH_COMMAND
			args = BOOTSTRAP_SSH_ARGS + ["{}@{}".format(self.username, ip), "-p 22"]
			if self.pexpect_version['major'] <= 3:
				ssh_session = pexpect.spawn(command, args=args, timeout=timeout)
			else:
				ssh_session = pexpect.spawn(command, args=args, timeout=timeout, encoding='utf-8')
		except NameError as e:
			raise Exception("Failed SSH login using args '{}' with message '{}'".format(args, sys.exc_info()))
		except:
			raise Exception("Failed SSH login using args '{}' with message '{}'".format(args, sys.exc_info()))

		return ssh_session
	
	def appresponse_ssh_login(self, ip=None, password=None, timeout=-1):
		import pexpect

		ssh_session = None
		try:
			if ip != None:
				ssh_session = self.ssh_login(ip)
		except pexpect.EOF:
			raise RuntimeError("Receiving unexpected pexpect.EOF")
		except NameError as e:
			raise
		except:
			raise

		if ssh_session == None:
			raise RuntimeError("SSH login failed to '{}'".format(ip))

		ssh_session.expect(BOOTSTRAP_PASSWORD_PROMPT_REGEX, timeout=timeout)
		if password != None:
			ssh_session.sendline(password)
		else:
			ssh_session.sendline(self.password)
		ssh_session.expect(BOOTSTRAP_CLI_PROMPT_REGEX)
		if u'> ' in ssh_session.after:
			ssh_session.sendline(BOOTSTRAP_ENABLE)
			ssh_session.expect(BOOTSTRAP_ENABLE_PROMPT_REGEX) # Leaving default timeout of 30 seconds
		if u'# ' in ssh_session.after and u'(config)' not in ssh_session.after:
			ssh_session.sendline(BOOTSTRAP_CONFIG)
			ssh_session.expect(BOOTSTRAP_CONFIG_PROMPT_REGEX)

		return ssh_session

	def terminal_login(self):
		import pexpect
		import sys

		try:
			command = BOOTSTRAP_CONSOLE_COMMAND
			args = BOOTSTRAP_CONSOLE_ARGS + ["{}@{}".format(self.terminal_username, self.terminal_ip), "-p {}".format(self.terminal_port)]
			if self.pexpect_version['major'] <= 3:
				terminal = pexpect.spawn(command, args=args, timeout=450)
			else:
				terminal = pexpect.spawn(command, args=args, timeout=450, encoding='utf-8') 	
		except NameError as e:
			raise Exception("Failed SSH login using args '{}' with message '{}'".format(args, sys.exc_info()))
		except:
			raise Exception("Failed SSH login using args '{}' with message '{}'".format(args, sys.exc_info()))

		terminal.expect(BOOTSTRAP_TERMINAL_PASSWORD_PROMPT)
		if self.terminal_password == None:
			terminal.sendline(getpass(BOOTSTRAP_TERMINAL_PASSWORD_REQUEST))
		else:
			terminal.sendline(self.terminal_password)
		terminal.sendline()

		return terminal

	def appresponse_console_login(self, timeout=-1, ssh_to_terminal_still_active=False):
		
		import pexpect

		try:
			if ssh_to_terminal_still_active == False:
				console = self.terminal_login()
			else:
				console = self.console
		except:
			raise

		console.sendline()
		console.expect(BOOTSTRAP_PROMPT_REGEX_LIST, timeout=timeout)
		if u'login: ' in console.after:
			console.sendline(self.username)
			console.expect(BOOTSTRAP_PASSWORD_PROMPT_REGEX)
			console.sendline(self.password)
			console.expect(BOOTSTRAP_CLI_PROMPT_REGEX)
			if u'Password: ' in console.after:
				raise Exception("Failed AppResponse login through terminal server for '{}'".format(self.username))
		if u'> ' in console.after:
			console.sendline(BOOTSTRAP_ENABLE)
			console.expect(BOOTSTRAP_ENABLE_PROMPT_REGEX)
		if u'# ' in console.after and u'(config)' not in console.after:
			console.sendline(BOOTSTRAP_CONFIG)
			console.expect(BOOTSTRAP_CONFIG_PROMPT_REGEX)

		return console

	def factory_reset(self):
		import pexpect
		import sys
		import time

		self.child.sendline(BOOTSTRAP_RESET)
		time.sleep(5) # In testing, expect does not work here so need to sleep and send confirm
		self.child.sendline(BOOTSTRAP_CONFIRM)
		self.child.expect(BOOTSTRAP_PROMPT_REGEX_LIST)

		try:
			if u'Confirmed - the system will now reboot' in self.child.after.decode('utf-8'):
				# Assume that reboot is occurring
				self.wait(0, BOOTSTRAP_RESET_WAIT)

				# When done waiting, if there was an SSH connection open, it has closed, so reconnect with default password after reset
				if self.connection_type == BOOTSTRAP_CONNECTION_SSH:
					self.child.close()
					# Factory reset will choose DHCP; assume connection to DHCP IP or that expected static IP is also DHCP IP
					if self.dhcp_ip != None:
						self.reconnect(ip=self.dhcp_ip, password=BOOTSTRAP_DEFAULT_PASSWORD)
					else:
						self.reconnect(ip=self.ip, password=BOOTSTRAP_DEFAULT_PASSWORD)
				return True
			else:
				return False
		except pexpect.EOF:
			self.child.close()
			self.reconnect(BOOTSTRAP_DEFAULT_PASSWORD)
			return True
		except:
			raise RuntimeError(sys.exc_info())

		return True

	def wizard(self):
		import pexpect
		import sys

		self.child.sendline(BOOTSTRAP_WIZARD)

		self.child.expect(BOOTSTRAP_WIZARD_HOSTNAME_REGEX)
		self.child.sendline(self.hostname)
		self.child.expect(BOOTSTRAP_WIZARD_DHCP_REGEX)
		self.child.sendline(u"no")
		self.child.expect(BOOTSTRAP_WIZARD_IPADDRESS_REGEX)
		self.child.sendline(self.ip)
		self.child.expect(BOOTSTRAP_WIZARD_SUBNETMASK_REGEX)
		self.child.sendline(self.mask)
		self.child.expect(BOOTSTRAP_WIZARD_AUX_REGEX)
		self.child.sendline(u"no")
		self.child.expect(BOOTSTRAP_WIZARD_DEFAULTGATEWAY_REGEX)
		self.child.sendline(self.gateway)
		self.child.expect(BOOTSTRAP_WIZARD_DNSSERVERS_REGEX)
		self.child.sendline()
		self.child.expect(BOOTSTRAP_WIZARD_DNSDOMAINNAMES_REGEX)
		self.child.sendline()
		self.child.expect(BOOTSTRAP_WIZARD_TIMEZONE_REGEX)
		self.child.sendline(u"UTC")
		self.child.expect(BOOTSTRAP_WIZARD_CONFIGURE_STORAGE_UNITS_REGEX)
		self.child.sendline(u"no")
		self.child.expect(BOOTSTRAP_WIZARD_QUIT_REGEX)

		try:
			self.child.sendline(u"save")

			if self.connection_type == BOOTSTRAP_CONNECTION_TERMINAL:
				self.child.expect(BOOTSTRAP_CONFIG_PROMPT_REGEX)
			elif self.connection_type == BOOTSTRAP_CONNECTION_SSH:
				# SSH session would lose connection if IP address has changed; close and re-connect
				self.child.expect(u"Applying settings")
				self.wait(0, 1)
				self.child.close()
				self.reconnect(ip=self.ip, password=self.password)

		except pexpect.EOF:
			if self.connection_type == BOOTSTRAP_CONNECTION_SSH:
				self.wait(0, 1)
				self.child.close()
				self.reconnect(ip=self.ip, password=self.password)
		except pexpect.TIMEOUT:
			if self.connection_type == BOOTSTRAP_CONNECTION_SSH:
				self.wait(0, 1)
				self.child.close()
				self.reconnect(ip=self.ip, password=self.password)
		except:
			raise RuntimeError(sys.exc_info())

	def init_drives(self):
		drives = self.drives()
		for drive in drives:
			self.child.sendline(u'storage data_section {} reinitialize mode RAID0'.format(drive))
			self.wait()
			self.child.expect(BOOTSTRAP_CONFIG_PROMPT_REGEX)

	def logout(self):
		import pexpect
		try:
			self.child.sendline(BOOTSTRAP_EXIT)
			self.child.expect(BOOTSTRAP_ENABLE_PROMPT_REGEX)
			self.child.sendline(BOOTSTRAP_EXIT)
			self.child.expect([BOOTSTRAP_LOGIN_PROMPT_REGEX, pexpect.EOF], timeout=None)
			self.child.close()
		except:
			raise

	def run(self):

		# If reset, factory reset
		if self.reset == True:
			try:
				status = self.factory_reset()
			except:
				raise

			if status == False:
				return False, "Factory reset did not complete as expected."

		# Run setup wizard
		self.wizard()

		# Initialize drives
		try:
			self.init_drives()
		except:
			raise RuntimeError("Failed to initialize drives. It is likely that script cannot reach newly assigned IP address. Please check connectivity.")

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
		"terminal_username": {"required":False, "type":str},
		"terminal_ip": {"required":False, "type":"str"},
		"terminal_port": {"required":False, "type":"str"},
		"terminal_password": {"required":False, "type":"str", "no_log":True},
		"dhcp_ip": {"required":False, "type":"str"},
		"ip": {"required":True, "type":"str"},
		"mask": {"required":True, "type":"str"},
		"gateway": {"required":True, "type":"str"},
		"reset": {"required":False, "type":"bool", "default":"False"}}
	required_together = [["terminal_ip", "terminal_port", "terminal_password"]]
	required_one_of = [["dhcp_ip", "terminal_ip"]]
	module = AnsibleModule(argument_spec=arg_dict, required_together=required_together, required_one_of=required_one_of, supports_check_mode=False)

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
		import sys
		import time
		from getpass import getpass
	except ImportError as e:
		module.fail_json(msg="Required Python modules could not be imported.")

	try:
		# Initialize connection to appliance
		bootstrap = BootstrapApp(hostname=module.params['hostname'], 
			username=module.params['username'], 
			password=module.params['password'],
			terminal_username=module.params['terminal_username'],
			terminal_ip=module.params['terminal_ip'], 
			terminal_port=module.params['terminal_port'],
			terminal_password=module.params['terminal_password'],
			dhcp_ip=module.params['dhcp_ip'],
			ip=module.params['ip'], 
			mask=module.params['mask'], 
			gateway=module.params['gateway'], 
			reset=module.params['reset'])

		# Run
		success, msg = bootstrap.run() 
	except pexpect.TIMEOUT as e:
		module.fail_json(msg="pexpect.TIMEOUT: Unexpected timeout waiting for prompt or command: {}".format(e))
	except pexpect.EOF as e:
		module.fail_json(msg="pexpect.EOF: Unexpected program termination: {}".format(e))
	# Does not seem to be supported in earlier versions of pexpect
	#except pexpect.exceptions.ExceptionPexpect as e:
	#	module.fail_json(msg="pexpect.exceptions.{0}: {1}".format(type(e).__name__, e))
	except RuntimeError as e:
		module.fail_json(msg="RuntimeError: {}".format(e))
	except:
		module.fail_json(msg="Unexpected error: {}".format(sys.exc_info()[0]))

	module.exit_json(changed=success,output=msg)

BOOTSTRAP_TEST_HOSTNAME = 'appresponse'
BOOTSTRAP_TEST_USERNAME = 'admin'
BOOTSTRAP_TEST_DHCPIP = '10.1.150.115'
BOOTSTRAP_TEST_TERMINALUSERNAME = 'admin'
BOOTSTRAP_TEST_TERMINALIP = '192.168.1.1'
BOOTSTRAP_TEST_TERMINALPORT = '2020'
BOOTSTRAP_TEST_IP = '10.1.150.210'
BOOTSTRAP_TEST_MASK = '255.255.255.0'
BOOTSTRAP_TEST_GATEWAY = '10.1.150.1'
BOOTSTRAP_TEST_RESET = False

def test(terminal=True):
	# Check that the dependencies are present to avoid an exception in execution
	try:
		import pexpect
	except ImportError:
		print("The pexpect Python module could not be imported during the execution of the AppResponse Bootstrap Ansible module")

	# Check that other dependencies are also present
	try:
		import requests
		import urllib3
		urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

		import json
		import sys
		import time
		from getpass import getpass
	except ImportError as e:
		print("Required Python modules could not be imported.")

	try:
		if terminal == True:
			print("Enter password for terminal '{}' for username '{}'".format(BOOTSTRAP_TEST_TERMINALIP, BOOTSTRAP_TEST_TERMINALUSERNAME))
			terminal_password = getpass()
		print("Enter password for AppResponse appliance '{}'".format(BOOTSTRAP_TEST_HOSTNAME))
		password = getpass()
		
		if terminal == True:
			# Initialize connection to appliance
			bootstrap = BootstrapApp(hostname=BOOTSTRAP_TEST_HOSTNAME,
				username=BOOTSTRAP_TEST_USERNAME, 
				password=password,
				terminal_ip=BOOTSTRAP_TEST_TERMINALIP,
				terminal_port=BOOTSTRAP_TEST_TERMINALPORT,
				terminal_username=BOOTSTRAP_TEST_TERMINALUSERNAME,
				terminal_password=terminal_password,
				ip=BOOTSTRAP_TEST_IP, 
				mask=BOOTSTRAP_TEST_MASK,
				gateway=BOOTSTRAP_TEST_GATEWAY,
				reset=BOOTSTRAP_TEST_RESET)
		else:
			# Initialize connection to appliance
			bootstrap = BootstrapApp(hostname=BOOTSTRAP_TEST_HOSTNAME,
				username=BOOTSTRAP_TEST_USERNAME, 
				password=password,
				dhcp_ip=BOOTSTRAP_TEST_DHCPIP,
				ip=BOOTSTRAP_TEST_IP, 
				mask=BOOTSTRAP_TEST_MASK,
				gateway=BOOTSTRAP_TEST_GATEWAY,
				reset=BOOTSTRAP_TEST_RESET)
			
		# Run
		success, msg = bootstrap.run() 
	except pexpect.TIMEOUT as e:
		print("pexpect.TIMEOUT: Unexpected timeout waiting for prompt or command: {}".format(e))
		print("Failure")
		return
	except pexpect.EOF as e:
		print("pexpect.EOF: Unexpected program termination: {}".format(e))
		print("Failure")
		return
	# Does not seem to be supported in earlier versions of pexpect
	#except pexpect.exceptions.ExceptionPexpect as e:
	#	print("pexpect.exceptions.{0}: {1}".format(type(e).__name__, e))
	#	print("Failure")
	#	return
	except RuntimeError as e:
		print("RuntimeError: {}".format(e))
		print("Failure")
		return
	except:
		print("Unexpected error: {}".format(sys.exc_info()))
		print("Failure")
		return

	print("Success")

	return


if __name__ == '__main__':
	main()

	# Comment out main() and remove comments from test() to be able to execute Python code directly using <python bootstrap.py>.
	# This allows the code to be executed separately without being executed as an Ansible module.
	# Edit the global BOOTSTRAP_TEST* parameters that are specified above the test () function to specify the parameters to use in the test.
	# The passwords will be requested at the command line upon execution.
	# Specifying terminal=True connects to the bootstrapped system using a terminal server, while specifying terminal=False connects directly to the DHCP IP over SSH.
	# test(terminal=True)
	# test(terminal=False)
