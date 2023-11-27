#!/usr/bin/env python
"""
Riverbed Community Toolkit
Synthetic Test

Script: Edge-browse-yourapp.py
Version: 23.11.231124
Application: Edge, YourAppDemo
Requirement: Python 3.11 or 3.12 with selenium 4, msedgedriver

Browse YourAppDemo with the Edge browser on a windows machine

Usage:
    python Edge-browse-yourapp.py
"""

import time

##################################################################
# Configure Selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.service import Service
from selenium.webdriver.edge.options import Options

MSEDGEDRIVER_PATH= "C:\\edgedriver_win64\\msedgedriver.exe"
DEFAULT_URL = "https://www.riverbed.com"

# Configure the profile path
# For example, "C:\\robot-edge-profile" to create new/use a dedicated profile
# For example, "C:\\Users\\your_username\\AppData\\Local\\Microsoft\\Edge\\User Data" to use the profile of an existing user (your_username)
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
    time.sleep(3)

    try:
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
        
        driver.close()
        driver.quit()
    except:
        driver.close()
        driver.quit()
        print("Caught exception, ending")
        exit(5)

print("Successfully run")
