#!/usr/bin/env python
"""
Riverbed Community Toolkit
Synthetic Test

Script: Chrome-browse-flyfast.py
Version: 23.1.230218
Requirements: 
    - Python 3.11 with selenium 4
    - ChromeDriver binary in folder C:\chromedriver_win32
    - FlyFast v1.0.0

Browse the web app FlyFast inside Chrome on a Windows machine

Usage:
    python Chrome-browse-flyfast.py

Notes:
    - FlyFast https://github.com/Aternity/FlyFast
    - Python https://www.python.org
    - Selenium reference https://www.selenium.dev
        pip install selenium
    - ChromeDriver https://chromedriver.chromium.org
"""

import time
from datetime import datetime
import random

##################################################################
# Configure Selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options

CHROMEDRIVER_PATH= "C:\\chromedriver_win32\\chromedriver.exe"
DEFAULT_ROBOT_PROFILE_PATH = "C:\\robot-chrome-profile"

if __name__ == "__main__":
    chrome_options = Options()
    chrome_options.add_argument('user-data-dir='+DEFAULT_ROBOT_PROFILE_PATH)
    service_args=['--verbose']
    service = ChromeService(executable_path=CHROMEDRIVER_PATH,service_args=service_args)
    driver = webdriver.Chrome(service=service, options=chrome_options)

##################################################################
# Synthetic test

    # TODO: set your url
    BASE_URL = "https://flyfast.yourcorp.net"

    print(datetime.now())
    print("Initial Page Load test")
    driver.get("about:blank")
    time.sleep(3)
    driver.get(BASE_URL)
    time.sleep(10)
    print("Initial Page Load test done.")

    print("Running test on: "+ BASE_URL)
    departure_airport_codes = ["CHP","GTB","YMD","VLM","FJW"]
    destination_airport_codes = ["SIL","OCE","PHX","ANZ","UOQ"]
    try:
        print("Step 1 Home")
        element = driver.find_element(By.LINK_TEXT,"FlyFast")
        element.click()
        time.sleep(5)

        for i in range(1,random.randint(2, 5)):
            print("Step 2.1 From?")
            departure = random.choice(departure_airport_codes)
            print(departure)
            element = driver.find_element(By.XPATH,"//form//input[@placeholder='From?']")
            element.click()
            time.sleep(1)
            element.send_keys(Keys.CONTROL + 'a', Keys.BACKSPACE)
            element.send_keys(departure + Keys.ENTER)
            time.sleep(1)

            print("Step 2.2 To?")
            destination = random.choice(destination_airport_codes)
            print(destination)
            element = driver.find_element(By.XPATH,"//form//input[@placeholder='To?']")
            element.click()
            time.sleep(1)
            element.send_keys(Keys.CONTROL + 'a', Keys.BACKSPACE)
            element.send_keys(destination + Keys.ENTER)
            time.sleep(1)

            print("Step 2.3 Date")
            element = driver.find_element(By.XPATH,"//form//input[@placeholder='Pick Trip Range']")
            element.click()
            # TODO: select date
            element.send_keys(Keys.ENTER)
            time.sleep(1)

            print("Step 2.4 Submit Search")
            element = driver.find_element(By.XPATH,"//form//button[@type='submit']")
            element.click()
            time.sleep(15)

        print("Step 3 Add few tickets to cart")
        element = driver.find_element(By.XPATH,"//main/div/div[2]/div/div/div//button[2]")
        for ticket in range(random.randint(2, 5)):
            element.click()
            print("+1")
            time.sleep(1)

        print("Step 4 Checkout")
        element = driver.find_element(By.XPATH,"//a[@href='/checkout']")
        element.click()
        time.sleep(3)        

        print("Step 5 Proceed payment")
        element = driver.find_element(By.XPATH,"//span[text()='Proceed']")
        element.click()
        time.sleep(3)   

        print("Ending...")
        time.sleep(10)
        driver.close()
        driver.quit()
    except:
        driver.close()
        driver.quit()
        print("Caught exception, ending")
        exit(5)

print("Test run successful")
