# Copyright (c) 2021 Riverbed Technology, Inc.
#
# This software is licensed under the terms and conditions of the MIT License
# accompanying the software ("License").  This software is distributed "AS IS"
# as set forth in the License.

"""
Riverbed Community SteelScript

service.py

This module defines the Service class and associated authentication classes.
The Service class is not instantiated directly, but is instead subclassed
to implement handlers for particular REST namespaces.

For example, the NetShark is based on Service using the "netshark" namespace,
and will provide the necessary methods to interface with the REST resources
available within that namespace.

If a device or appliance implements multiple namespaces, each namespace will be
exposed by a separate child class.  The SteelCentral NetExpress product
implements both the "netprofiler" and "netshark" namespaces.  These will be
exposed via NetShark and NetProfiler classes respectively, both based on the
the Service class.  A script that interacts with both namespaces must
instantiate two separate objects.
"""

import base64
import logging
import hashlib
import time

from steelscript.common import connection
from steelscript.common.exceptions import RvbdException, RvbdHTTPException

from steelscript.common.api_helpers import APIVersion

__all__ = ['Service', 'Auth', 'UserAuth', 'OAuth', 'RvbdException']

logger = logging.getLogger(__name__)


class Auth(object):
    NONE = 0
    BASIC = 1
    COOKIE = 2
    OAUTH = 3


class UserAuth(object):
    """This class is used for both Basic and Cookie based authentication
    which rely on username and password."""

    def __init__(self, username, password, method=None):
        """Define an authentication method using `username` and `password`.
        By default this will be used for both Basic as well as Cookie
        based authentication methods (whichever is supported by the target).
        Authentication can be restricted by setting the `method` to
        either `Auth.BASIC` or `Auth.COOKIE`.
        """
        self.username = username
        self.password = password
        if method:
            self.methods = [method]
        else:
            self.methods = [Auth.BASIC, Auth.COOKIE]

    def __repr__(self):
        return '<UserAuth username: %s password: *****>' % self.username


class OAuth(object):
    """This class is used for OAuth based authentication with relies
    on an OAuth access token."""

    def __init__(self, access_code):
        """Define an OAuth based authentication method using `access_code`.
        The method is automatically set to `Auth.OAUTH`."""

        self.access_code = access_code
        self.methods = [Auth.OAUTH]


class Service(object):
    """This class is the main interface to interact with a device via REST
    and provides the following functionality:

    - Connection management
    - Resource requests and responses
    - Authentication
    - "common" resources

    A connection is established as soon as the an instance of this object
    is created.  Requests can be made via the `Service.conn` property.
    """
    def __init__(self, service, host=None, port=None, auth=None,
                 verify_ssl=False, versions=None,
                 enable_auth_detection = True, override_auth_info_api='/api/common/1.0/auth_info',
                 supports_auth_basic=True,
                 supports_auth_cookie=False, override_cookie_login_api = '/api/common/1.0/login',
                 supports_auth_oauth=False, override_oauth_token_api='/api/common/1.0/oauth/token',
                 enable_services_version_detection=True,override_services_api='/api/appliance/1.0/services'
                 ):
        """Establish a connection to the named host.

        `host` is the name or IP address of the device to connect to

        `port` is the TCP port to use for the connection.  This may be either
            a single port or a list of ports.  If left unset, the port will
            automatically be determined.

        `auth` defines the authentication method and credentials to use
            to access the device.  See UserAuth and OAuth.  If set to None,
            connection is not authenticated.

        `verify_ssl` when set to True will only allow verified SSL certificates
            on any connections, False will not verify certs (useful for
            self-signed certs on many test systems)

        `versions` is the API versions that the caller can use.
            if unspecified, this will use the latest version supported
            by both this implementation and service requested.  This does
            not apply to the "common" resource requests.

        `verify_api_version` when set to True it will fails when the api 
            does not support the steelscript api version check feature

        `enable_auth_detection set False to bypass the detection feature

        `override_auth_info_api set properly for the detection feature
            For example: '/api/common/1.0/auth_info' or '/api/common/1.0.0/auth_info'

        `override_oauth_token_api to set the oauth api path
            For example: '/api/common/1.0/oauth/token' or '/api/common/1.0.0/oauth/token'
        
        `override_cookie_login_api to set the cookie login api path
            For example: '/api/common/1.0/login'
        
        `enable_services_version_detection  set False to bypass the detection feature

        `override_services_api the services api or set to None if not supported.
            For example: '/api/appliance/1.0/services' '/api/appliance/1.0.0/services'
        """

        self.service = service
        self.host = host
        self.port = port

        # Connection object.  Use this to make REST requests to the device.
        self.conn = None

        self.verify_ssl = verify_ssl

        logger.info("New service %s for host %s" % (self.service, self.host))

        self.supported_versions = None

        self._auth_detection_enabled = enable_auth_detection
        self._auth_info_api = override_auth_info_api

        self._supports_auth_basic = supports_auth_basic

        self._supports_auth_cookie = supports_auth_cookie
        self._cookie_login_api = override_cookie_login_api

        self._supports_auth_oauth = supports_auth_oauth
        self._oauth_token_api = override_oauth_token_api
        
        self._services_version_detection_enabled = enable_services_version_detection
        self._services_api = override_services_api

        # TODO: Update steelscript-client-accelerator-controller module to remove this patch
        if self.service == "cac":
            self._auth_info_api = '/api/common/1.0.0/auth_info'
            self._oauth_token_api = '/api/common/1.0.0/oauth/token'
            self._services_api = '/api/appliance/1.0.0/services'
        
        self.connect()
        if enable_services_version_detection:
            self.check_api_versions(versions)

        if auth is not None:
            self.authenticate(auth)        

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.logout()

    def connect(self):
        if self.conn is not None and hasattr(self.conn, 'close'):
            self.conn.close()

        self.conn = connection.Connection(
            self.host, port=self.port,
            verify=self.verify_ssl,
            reauthenticate_handler=self.reauthenticate
        )

    def logout(self):
        """End the authenticated session with the device."""
        if self.conn:
            self.conn.del_headers(['Authorization', 'Cookie'])

    def check_api_versions(self, api_versions):
        """Check that the server supports the given API versions."""
        if self.conn is None:
            raise RvbdException("Not connected")

        try:
            self.supported_versions = self._get_supported_versions()
        except RvbdHTTPException as e:
            if e.status != 404:
                raise
            logger.warning("Failed to retrieved supported versions")
            self.supported_versions = None

        if self.supported_versions is None:
            return False

        logger.debug("Server supports the following services: %s" %
                     (",".join([str(v) for v in self.supported_versions])))

        for v in api_versions:
            if v in self.supported_versions:
                self.api_version = v
                logger.debug("Service '%s' supports version '%s'" %
                             (self.service, v))
                return True

        msg = ("API version(s) %s not supported (supported version(s): %s)" %
               (', '.join([str(v) for v in api_versions]),
                ', '.join([str(v) for v in self.supported_versions])))
        raise RvbdException(msg)

    def _get_supported_versions(self):
        """Get the common list of services and versions supported."""
        # uses the GL7 'services' resource.
        path = self._services_api
        services = self.conn.json_request('GET', path)

        for service in services:
            if service['id'] == self.service:
                return [APIVersion(v) for v in service['versions']]

        return None

    def _detect_auth_methods(self):
        """Get the list of authentication methods supported from API auth_info"""
        # uses the GL7 'auth_info' resource
        path = self._auth_info_api
        try:
            auth_info = self.conn.json_request('GET', path)
            supported_methods = auth_info['supported_methods']
            logger.info("Supported authentication methods: %s" %
                        (','.join(supported_methods)))
            self._supports_auth_basic = ("BASIC" in supported_methods)
            self._supports_auth_cookie = ("COOKIE" in supported_methods)
            self._supports_auth_oauth = ("OAUTH_2_0" in supported_methods)
        except RvbdHTTPException as e:
            if e.status != 404:
                raise
            logger.warning("Failed to retrieve auth_info, assuming basic")
            self._supports_auth_basic = True
            self._supports_auth_cookie = False
            self._supports_auth_oauth = False

    def authenticate(self, auth):
        """Authenticate with device using the defined authentication method.
        This sets up the appropriate authentication headers to access
        restricted resources.

        `auth` must be an instance of either UserAuth or OAuth."""

        assert auth is not None

        self.auth = auth

        if self._auth_detection_enabled:
            self._detect_auth_methods()

        if self._supports_auth_oauth and Auth.OAUTH in self.auth.methods:
            path = self._oauth_token_api
            assertion = '.'.join([
                base64.urlsafe_b64encode(b'{"alg":"none"}').decode(),
                self.auth.access_code,
                ''
            ])
            state = hashlib.md5(str(time.time()).encode()).hexdigest()
            data = {'grant_type': 'access_code',
                    'assertion': assertion,
                    'state': state}
            answer = self.conn.urlencoded_request('POST', path,
                                                  body=data)

            if answer.json()['state'] != state:
                msg = "Inconsistent state value in OAuth response"
                raise RvbdException(msg)

            token = answer.json()['access_token']
            st = token.split('.')
            if len(st) == 1:
                auth_header = 'Bearer %s' % token
            elif len(st) == 3:
                auth_header = 'SignedBearer %s' % token
            else:
                msg = 'Unknown OAuth response from server: %s' % st
                raise RvbdException(msg)
            self.conn.add_headers({'Authorization': auth_header})
            logger.info('Authenticated using OAUTH2.0')

            if self.service == "cac":
                return self.conn

        elif self._supports_auth_cookie and Auth.COOKIE in self.auth.methods:
            path = self._cookie_login_api
            data = {
                "username": self.auth.username,
                "password": self.auth.password
            }

            body, http_response = self.conn.json_request('POST', path,
                                                         body=data,
                                                         raw_response=True)

            # we're good, set up our http headers for subsequent
            # requests!
            self.conn.cookies = http_response.cookies

            logger.info("Authenticated using COOKIE")

        elif self._supports_auth_basic and Auth.BASIC in self.auth.methods:

            # Use HTTP Basic authentication
            s = base64.b64encode(bytes(f'{self.auth.username}:{self.auth.password}',encoding='ascii')).decode('ascii')
            self.conn.add_headers({'Authorization': 'Basic %s' % s})

            logger.info("Authenticated using BASIC")

        else:
            raise RvbdException("No supported authentication methods")

    def reauthenticate(self):
        """Retry the authentication method"""
        self.authenticate(self.auth)

    def ping(self):
        """Ping the service.  On failure, this raises an exception"""

        res = self.conn.request('/api/common/1.0/ping', method="GET")

        # drain the response object...
        res.read()

        return True
