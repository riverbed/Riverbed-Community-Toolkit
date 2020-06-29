#!/usr/bin/env python
"""
Riverbed Community Toolkit
NetIM - Synthetic Test

Script: Edge-open-url-generic.py
Application: Edge

Simple generic script that automates the Edge browser on a windows machine to navigate to a page
The URL of the page to naviage must be passed in parameters

Usage:
    python Edge-open-url-generic.py "https://your-fqdn/your-path"
"""
import sys, time

# Configure Selenium
from msedge.selenium_tools import Edge, EdgeOptions, EdgeService
MSEDGEDRIVER_PATH= "C:\\edgedriver_win64\\msedgedriver.exe"

DEFAULT_URL = "https://www.riverbed.com"

if __name__ == "__main__":
    service = EdgeService(MSEDGEDRIVER_PATH)
    options = EdgeOptions()
    options.use_chromium = True
    driver = Edge(executable_path=MSEDGEDRIVER_PATH,options=options)

    # Synthetic test
    url = DEFAULT_URL
    if (len(sys.argv) > 1):
        url=sys.argv[1]
    driver.get(url)
    time.sleep(5)
    driver.close()
    driver.quit()
