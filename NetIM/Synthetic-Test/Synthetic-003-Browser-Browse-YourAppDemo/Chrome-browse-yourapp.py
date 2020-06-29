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

CHROMEDRIVER_PATH= "C:\\chromedriver_win32\\chromedriver.exe"
DEFAULT_URL = "https://www.riverbed.com"
DEFAULT_ROBOT_PROFILE_PATH = "C:\\robot-chrome-profile"

if __name__ == "__main__":
    chrome_options = webdriver.ChromeOptions()
    # chrome_options.add_argument("--headless")
    chrome_options.add_argument('user-data-dir='+DEFAULT_ROBOT_PROFILE_PATH)
    driver = webdriver.Chrome(executable_path=CHROMEDRIVER_PATH,chrome_options=chrome_options)

# Synthetic test

    BASE_URL = "http://www.yourapp.com"
    driver.get(BASE_URL+"/ims.html")
    time.sleep(3)

    try:
        element = driver.find_element_by_id("Home")
        element.click()
        time.sleep(3)

        element = driver.find_element_by_id("Orders")
        element.click()
        time.sleep(3)

        element = driver.find_element_by_id("Portfolio")
        element.click()
        time.sleep(3)

        element = driver.find_element_by_id("Securities")
        element.click()
        time.sleep(3)
        
        element = driver.find_element_by_id("Analysis")
        element.click()
        time.sleep(3)

        element = driver.find_element_by_id("Logout")
        element.click()
        time.sleep(3)
        driver.close()
        driver.quit()
    except:
        driver.close()
        driver.quit()
        exit(5)
