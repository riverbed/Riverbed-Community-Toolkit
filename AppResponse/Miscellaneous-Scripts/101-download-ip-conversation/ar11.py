import time
import requests
import urllib3

urllib3.disable_warnings()


class AR11Connection(object):
    """ Class for connecting to an AR11 appliance. Handles OAuth token renewels """

    _token_expires = time.time() - 10
    _header = {"Authorization": None}
    _refresh_token = None

    def __init__(self, host, username, password, verify_ssl=False):
        """ Initialize Class

            Parameters
            ----------
            host : str
                hostname or IP address of the AR11 appliance
            username : str
                username of user with appropriate rights
            client_secret : str
                Value of the key when creating the application
        """
        self.host = host
        self._username = username
        self._password = password

        self.base_url = "https://{}/api/".format(host)
        self._session = requests.session()
        self._session.verify = verify_ssl
        self._token_request_url = self.base_url + "mgmt.aaa/1.0/token"

        # get a new token when the class initializes
        # self._renew_token()

    @property
    def is_token_expired(self):
        """Checks to see if the OAuth token has expired"""
        if time.time() > self._token_expires:
            return True
        else:
            return False

    def _renew_token(self):
        """Renew the OAuth token"""
        if self._refresh_token is None:
            # first time we are requesting a token
            post_data = dict(user_credentials=dict(username=self._username,
                                                   password=self._password),
                             generate_refresh_token=True)

        else:
            # this is a token refresh
            post_data = dict(refresh_token=self._refresh_token)

        try:
            response = self._post(url=self._token_request_url, post_data=post_data, timeout=30)
        except requests.HTTPError:
            post_data = dict(user_credentials=dict(username=self._username,
                                                   password=self._password),
                             generate_refresh_token=True)
            response = self._post(url=self._token_request_url, post_data=post_data, timeout=30)

        response = self._handle_response(response, to_json=True)
        # update our token expires time and subtract 5 seconds
        # for some wiggle room
        self._token_expires = response["expires_at"] - 5
        self._header["Authorization"] = "Bearer {}".format(response["access_token"])

        if self._refresh_token is None:
            self._refresh_token = response["refresh_token"]

        # update the session header with our authorization/token header
        self._session.headers.update(self._header)

    def json_request(self, method, url, post_data=None,
                     json=None, params=None, timeout=None):
        """Sends a get/post request and returns

            Parameters
            ----------
            method : str
                must be either get, post, delete or put
            url : str
                The URL for the get/post
            data : dict, optional
                Dictionary for any POST data
            json : dict, optional
                Dictionary of any JSON data to get/post
            params : dict, optional
                Dictionary for any URL parameters/variables

            Returns
            -------
            Object
                if to_json is true then returns an object from the
                json data
        """
        # before we do anything, check to see if the
        # auth token is expired; if so, renew
        if self.is_token_expired:
            self._renew_token()

        # quick little check to see if the url starts with the
        # base url; if not, prepend the url with the base_url
        if not(url.startswith(self.base_url)):
            if url[0] == "/":
                url = self.base_url + url[1:]
            else:
                url = self.base_url + url

        if method.lower() == "post":
            response = self._post(url=url, post_data=post_data, timeout=timeout)
        elif method.lower() == "get":
            response = self._get(url=url, params=params, timeout=timeout)
        elif method.lower() == "delete":
            response = self._delete(url=url, timeout=timeout)
        elif method.lower() == "put":
            response = self._put(url=url, post_data=post_data, timeout=timeout)
        else:
            raise ValueError("method must be get, delete, put or post")

        return self._handle_response(response, to_json=True)

    def request(self, method, url, data=None, params=None, timeout=None):
        """Sends a get/post request and returns

            Parameters
            ----------
            method : str
                must be either get or post
            url : str
                The URL for the get/post
            data : dict, optional
                Dictionary for any POST data
            json : dict, optional
                Dictionary of any JSON data to get/post
            params : dict, optional
                Dictionary for any URL parameters/variables

            Returns
            -------
            Object
                if to_json is true then returns an object from the
                json data
        """
        # before we do anything, check to see if the
        # auth token is expired; if so, renew
        if self.is_token_expired:
            self._renew_token()

        # quick little check to see if the url starts with the
        # base url; if not, prepend the url with the base_url
        if not(url.startswith(self.base_url)):
            if url[0] == "/":
                url = self.base_url + url[1:]
            else:
                url = self.base_url + url

        if method.lower() == "post":
            response = self._post(url=url, data=data, timeout=timeout)
        elif method.lower() == "get":
            response = self._get(url=url, params=params, timeout=timeout)
        elif method.lower() == "delete":
            response = self._delete(url=url, timeout=timeout)
        else:
            raise ValueError("method must be get, delete or post")

        return self._handle_response(response, to_json=False)

    def _get(self, url, params, timeout):
        response = self._session.get(url, params=params, timeout=timeout)
        return response

    def _post(self, url, post_data, timeout):
        response = self._session.post(url, json=post_data, timeout=timeout)
        return response

    def _delete(self, url, timeout):
        response = self._session.delete(url, timeout=timeout)
        return response

    def _put(self, url, post_data, timeout):
        response = self._session.put(url, json=post_data, timeout=timeout)
        return response

    def _handle_response(self, response, to_json):
        if response.status_code in (200, 201, 204):
            if to_json:
                return response.json()
            else:
                return response.content
        else:
            # received some kind of response other than 200 OK.
            # for now raise an error
            print(response.content)
            response.raise_for_status()


class AR11Rest(AR11Connection):
    def __init__(self, host, username, password, verify_ssl=False,):
        super(AR11Rest, self).__init__(host, username, password, verify_ssl=verify_ssl)

    def is_up(self):
        url = f'https://{self.host}/api/common/1.0/ping'
        try:
            _ = self._get(url, params=None, timeout=2)
            return (self.host, True)
        except Exception:
            self.up = False
            return (self.host, False)

    def is_user_authorized(self, username, mfa):

        post_data = dict(user_credentials=dict(username=username,
                                               password=mfa),
                         generate_refresh_token=False)

        resp = self._post(url=self._token_request_url,
                          post_data=post_data,
                          timeout=10)
        if resp.ok:
            return True

        return False

    def get_job_config_by_name(self, job_name):
        url = '/npm.packet_capture/3.0/jobs'
        try:
            jobs = self.json_request('GET', url, timeout=20)

            for job in jobs['items']:
                config = job['config']
                if config['name'] == job_name:
                    return job
        except (requests.exceptions.HTTPError, requests.exceptions.ReadTimeout):
            None

    def packet_job_earliest_time(self, job_name):
        job_config = self.get_job_config_by_name(job_name)
        packet_earliest_time = None

        if job_config is not None:
            status = job_config['state']['status']
            packet_earliest_time = float(status['packet_start_time'])

        return (self, packet_earliest_time)

    def get_packet_summaries(self, start_time, end_time, filters):
        post_data = dict(source=dict(name='flow_ip'),
                         columns=["cli_tcp.ip",
                                  "srv_tcp.ip",
                                  "sum_traffic.total_bytes",
                                  "sum_traffic.packets"],
                         time=dict(granularity="60",
                                   start=str(start_time),
                                   end=str(end_time)),
                         filters=[],
                         reference_id=f'{self.host}_packetSummaries',
                         group_by=["cli_tcp.ip",
                                   "srv_tcp.ip"],
                         limit=5000)
        for k, val in filters.items():
            _k = k
            if k == 'ip.addr':
                _k = 'tcp.ip'
            __tmp = "{}=='{}'".format(_k, val)
            post_data['filters'].append(dict(value=__tmp,
                                             type='STEELFILTER'))

        resp = self.json_request('POST', url='/npm.reports/1.0/instances',
                                 post_data=dict(data_defs=[post_data]),
                                 timeout=120)
        report_id = resp['id']
        data_def_ids_done = {dd['id']: False for dd in resp['data_defs']}
        all_done = False
        while not all_done:
            time.sleep(1)
            for data_def_id in data_def_ids_done.keys():
                url = f'/npm.reports/1.0/instances/items/{report_id}/data_defs/items/{data_def_id}'
                resp = self.json_request('GET', url=url)
                dd_status = resp['status']
                if dd_status['state'] in ('completed', 'error'):
                    data_def_ids_done[data_def_id] = True

            if False not in data_def_ids_done.values():
                all_done = True

        url = f'/npm.reports/1.0/instances/items/{report_id}/data'
        all_report_data = self.json_request('GET', url=url)

        total_packets = 0
        total_bytes = 0
        if 'data' in all_report_data['data_defs'][0]:
            packet_summary_data = all_report_data['data_defs'][0]['data']
            columns = all_report_data['data_defs'][0]['columns']

            bytes_index = columns.index('sum_traffic.total_bytes')
            packets_index = columns.index('sum_traffic.packets')
            total_bytes = sum([int(r[bytes_index]) for r in packet_summary_data])
            total_packets = sum([int(r[packets_index]) for r in packet_summary_data])

        results = dict(name=self.host,
                       total_bytes=total_bytes,
                       total_packets=total_packets)

        url = f'/npm.reports/1.0/instances/items/{report_id}'
        _ = self.request('DELETE', url=url)
        return results
