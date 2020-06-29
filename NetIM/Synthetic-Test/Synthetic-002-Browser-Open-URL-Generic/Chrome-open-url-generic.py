#!/usr/bin/env python
"""
Riverbed Community Toolkit
NetIM - Synthetic Test

Script: Chrome-open-url-generic.py
Application: Chrome

Simple generic script that automates the Chrome browser on a windows machine to navigate to a page
The URL of the page to naviage must be passed in parameters

Usage:
    python Chrome-open-url-generic.py "https://your-fqdn/your-path"
"""
import time, sys

# Configure Selenium
from selenium import webdriver

CHROMEDRIVER_PATH= "C:\\chromedriver_win32\\chromedriver.exe"
DEFAULT_URL = "https://www.riverbed.com"
DEFAULT_ROBOT_PROFILE_PATH = "C:\\robot-chrome-profile"

if __name__ == "__main__":
    chrome_options = webdriver.ChromeOptions()
    driver = webdriver.Chrome(executable_path=CHROMEDRIVER_PATH,chrome_options=chrome_options)

# Synthetic test

    url = DEFAULT_URL
    if (len(sys.argv) > 1):
        url=sys.argv[1]
    driver.get(url)
    time.sleep(5)
    driver.close()
    driver.quit()
