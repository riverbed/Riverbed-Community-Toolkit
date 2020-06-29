#!/usr/bin/env python
"""
Riverbed Community Toolkit
NetIM - Synthetic Test

Script: Edge-open-url-template.py
Application: Edge

Simple template showing how to automate the Edge browser on a windows machine to navigate to a page
In the following replace {{ your web site url }} with your owne URL to test

Usage:
    python Edge-open-url-template.py
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

    url="{{ your web site url }}"
    driver.get(url)
    time.sleep(5)
    driver.close()
    driver.quit()
