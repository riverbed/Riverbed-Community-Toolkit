#!/usr/bin/env python
"""
Riverbed Community Toolkit
NetIM - Synthetic Test

Script: Edge-browse-yourapp.py
Application: Edge, YourAppDemo

Browse YourAppDemo with the Edge browser on a windows machine

Usage:
    python Edge-browse-yourapp.py
"""

import time

# Configure Selenium
from msedge.selenium_tools import Edge, EdgeOptions, EdgeService
MSEDGEDRIVER_PATH= "C:\\edgedriver_win64\\msedgedriver.exe"

if __name__ == "__main__":
    service = EdgeService(MSEDGEDRIVER_PATH)
    options = EdgeOptions()
    options.use_chromium = True
    driver = Edge(executable_path=MSEDGEDRIVER_PATH,options=options)

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