# Riverbed Community Toolkit - NetIM Synthetic Test

- [Overview](#overview)
- [Robots Cookbooks](#robots-cookbookx)
- [Synthetic Test Library](#synthetic-test-library)
- [How to contribute](#how-to-contribute)

## Overview

This area of the Riverbed Community Toolkit contains Howtos, samples and technical tricks shared by Riverbed and the Community to leverage Synthetic Testing in [Riverbed NetIM](https://www.riverbed.com/products/steelcentral/infrastructure-management.html).

Synthetic Testing often requires dedicated hosts with some special configuration and software preprequisites installed. We like to call them **Robots**. The [robots cookbooks](#robots-cookbooks) section is where you will find how to build some robots.

The section [Synthetic Test Library](#synthetic-test-library) inventories all the scripts samples and usecases provided in the subfolders.

Any contributions are welcome. More details in the [How to contribute](#how-to-contribute)

## ROBOTS cookbooks

| Robot                         | SubFolder                                                            | Capabilities                                                    |
| ----------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------- |
| Robot Template                | [Robot-000-Template](Robot-000-Template)                             | Template to design new Robot                                    |
| Web Selenium Robot            | [Robot-001-WebSelenium](Robot-001-WebSelenium)                       | <li>Edge and Chrome</li><li>Selenium with Python</li>           |
| Metrics Collector Linux Robot | [Robot-002-MetricsCollector-Linux](Robot-002-MetricsCollector-Linux) | <li>Linux</li><li>Python</li><li>SSH within Python scripts</li> |

## Synthetic Test Library

| Usecase                                  | SubFolder                                                                                | Recommended Robots |
| ---------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------ |
| Synthetic Test Template                  | [Synthetic-000-Template](Synthetic-000-Template)                                         | -                  |
| URL availability, Edge                   | [Synthetic-001-Browser-Open-URL](Synthetic-001-Browser-Open-URL)                         | Web Selenium Robot |
| Generic URL availability, Edge or Chrome | [Synthetic-002-Browser-Open-URL-Generic](Synthetic-002-Browser-Open-URL-Generic)         | Web Selenium Robot |
| YourApp Demo                             | [Synthetic-003-Browser-Browse-YourAppDemo](Synthetic-003-Browser-Browse-YourAppDemo)     | Web Selenium Robot |
| FlyFast Selenium Script                  | [Synthetic-004-Browse-FlyFast](Synthetic-004-Browse-FlyFast)                             | Web Selenium Robot |
| Monitor BGP State                        | [Synthetic-005-Monitor-BGP-Peer-State](Synthetic-005-Monitor-BGP-Peer-State)             | -                  |
| Bandwidth Monitor                        | [Synthetic-006-Bandwidth-Monitor](Synthetic-006-Bandwidth-Monitor)                       | -                  |
| SSL/TLS Certificate Verification         | [Synthetic-007-TLS-Certificate-Verification](Synthetic-007-TLS-Certificate-Verification) | -                  |
| IP Route Monitoring                      | [Synthetic-008-IP-Route-Monitoring](Synthetic-008-IP-Route-Monitoring)                   | -                  |

## How to contribute

Any contributions are welcome via standard Pull Request (PR) in this GitHub repo.

To share your own Robots and Synthetic Test, simply get a fork of the repo, use the Robot or Synthetic Test template folder to prepare the artifacts and submit a pull request.

## License

The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.

# Copyright (c) 2020 Riverbed Technology, Inc.
