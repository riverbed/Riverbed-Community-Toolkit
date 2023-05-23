import argparse
import requests
from requests.exceptions import SSLError

# Define the user agents for different browsers
USER_AGENTS = {
    'chrome': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
    'firefox': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:54.0) Gecko/20100101 Firefox/54.0',
    'edge': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3 Edge/16.16299'
}

def validate_ssl_cert(url, user_agent):
    """
    Validates the SSL certificate of the given URL using the specified user agent
    and returns the validation results as a dictionary.
    """
    headers = {'User-Agent': USER_AGENTS[user_agent]}
    try:
        resp = requests.get(url, headers=headers, timeout=10)
        return resp.ok
    except SSLError as e:
        print(f"Failed to validate SSL certificate for {url}: {str(e)}")
        return False

# Parse the command-line arguments
parser = argparse.ArgumentParser(description='Validate the SSL certificate of a website.')
parser.add_argument('url', help='The URL of the website to validate')
parser.add_argument('browser', choices=USER_AGENTS.keys(), help='The name of the browser to emulate')

args = parser.parse_args()

# Validate the SSL certificate
valid = validate_ssl_cert(args.url, args.browser)

# Print the validation results
if valid:
    print(f"SSL certificate for {args.url} is valid.")
    exit(0)
else:
    print(f"SSL certificate for {args.url} is not valid.")
    exit(1)
