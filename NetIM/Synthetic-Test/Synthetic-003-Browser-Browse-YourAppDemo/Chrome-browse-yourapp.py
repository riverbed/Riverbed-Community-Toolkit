#!/usr/bin/env python
"""
Riverbed Community Toolkit
Synthetic Test

Script: Chrome-browse-yourapp.py
Version: 23.11.231124
Application: Chrome, YourAppDemo
Requirements: Python 3.11 or 3.12 with selenium 4 + chromedriver

Browse YourAppDemo with the Chrome browser on a windows machine

Usage:
    python Chrome-browse-yourapp.py
"""

import time

##################################################################
# Configure Selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options

CHROMEDRIVER_PATH= "C:\\chromedriver-win64\\chromedriver.exe"
DEFAULT_URL = "https://www.riverbed.com"
DEFAULT_ROBOT_PROFILE_PATH = "C:\\robot-chrome-profile"

if __name__ == "__main__":
    chrome_options = Options()
    chrome_options.add_argument('user-data-dir='+DEFAULT_ROBOT_PROFILE_PATH)
    service_args=['--verbose']
    service = ChromeService(executable_path=CHROMEDRIVER_PATH,service_args=service_args)
    driver = webdriver.Chrome(service=service, options=chrome_options)

##################################################################
# Synthetic test

    BASE_URL = "https://yourapp.yourcorp.net"
    driver.get(BASE_URL+"/ims.html")
    driver.get(BASE_URL)
    time.sleep(10)

    try:
        element = driver.find_element(By.LINK_TEXT,"Home")
        element.click()
        time.sleep(10)

        element = driver.find_element(By.LINK_TEXT,"Orders")
        element.click()
        time.sleep(10)

        element = driver.find_element(By.LINK_TEXT,"Portfolio")
        element.click()
        time.sleep(10)

        element = driver.find_element(By.LINK_TEXT,"Securities")
        element.click()
        time.sleep(10)
        
        element = driver.find_element(By.LINK_TEXT,"Analysis")
        element.click()
        time.sleep(10)

        element = driver.find_element(By.LINK_TEXT,"Logout")
        element.click()
        time.sleep(10)
        
        driver.close()
        driver.quit()
    except:
        driver.close()
        driver.quit()
        print("Caught exception, ending")
        exit(5)

print("Successfully run")
