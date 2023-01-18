#!/usr/bin/env python
"""
Riverbed Community Toolkit
NetIM - Synthetic Test

Script: Chrome-browse-yourapp.py
Application: Chrome, YourAppDemo

Browse YourAppDemo with the Chrome browser on a windows machine

Usage:
    python Chrome-browse-yourapp.py
"""

import time

# Configure Selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.service import Service
from selenium.webdriver.edge.options import Options

MSEDGEDRIVER_PATH= "C:\\edgedriver_win64\\msedgedriver.exe"
DEFAULT_URL = "https://www.riverbed.com"
DEFAULT_ROBOT_PROFILE_PATH = "C:\\robot-edge-profile"

if __name__ == "__main__":
    edge_options = Options()
    edge_options.add_argument('user-data-dir='+DEFAULT_ROBOT_PROFILE_PATH)
    service_args=['--verbose']
    service = Service(executable_path=MSEDGEDRIVER_PATH, service_args=service_args)
    driver = webdriver.Edge(service=service, options=edge_options)

##################################################################
# Synthetic test

    BASE_URL = "https://yourapp.yourcorp.net"
    driver.get(BASE_URL+"/ims.html")
    driver.get(BASE_URL)
    time.sleep(10)

    try:
        element = driver.find_element(By.LINK_TEXT,"Orders")
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

print("End.")