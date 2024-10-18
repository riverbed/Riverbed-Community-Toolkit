#! /bin/python3
# cookbook-341-generate-cmx-metrics.py
# version: 23.8.230821
# Riverbed - Riverbed-Community-Toolkit (https://github.com/riverbed/Riverbed-Community-Toolkit)
#
# Prerequisites
# - python3
# - urllib3 (pip install urllib3)

######################################################################################

import os
import json
import urllib3
import datetime
import random

### Parameters

ALLUVIO_ATERNITY_APM_CMX_SOURCE = os.getenv('ALLUVIO_ATERNITY_APM_CMX_SOURCE', default="cookbook-341-source")
ALLUVIO_ATERNITY_APM_CMX_ENDPOINT = os.getenv('ALLUVIO_ATERNITY_APM_CMX_ENDPOINT', default="https://localhost:7074")
ALLUVIO_ATERNITY_APM_CMX_METRIC_ENDPOINT = ALLUVIO_ATERNITY_APM_CMX_ENDPOINT + "/Aternity/CustomMetrics/1.0.0/metric"
ALLUVIO_ATERNITY_APM_CMX_SAMPLES_ENDPOINT = ALLUVIO_ATERNITY_APM_CMX_ENDPOINT + "/Aternity/CustomMetrics/1.0.0/samples"

COOKBOOK_DIMENSION_CLOUD = os.getenv('COOKBOOK_DIMENSION_CLOUD', default="aws")
COOKBOOK_DIMENSION_REGION = os.getenv('COOKBOOK_DIMENSION_REGION', default="eu-west-3")
COOKBOOK_TAG_TIER = os.getenv('COOKBOOK_TAG_TIER', default="Medium")

### Config urllib3

http_cert_verification_disabled = urllib3.PoolManager(
    cert_reqs = 'CERT_NONE'
)
urllib3.disable_warnings()

######################################################################################

def main():

    print("APM CMX endpoint: " + ALLUVIO_ATERNITY_APM_CMX_ENDPOINT)

    # 1. Post the metric definitions to the CMX endpoint

    metric_definitions_json = { "metric-definitions": [
        { 
            "metric-id": "cookbook-341-metric-id1",
            "version": 1,
            "display-name": "Cookbook 341 count",
            "description": "Count",
            "units": "count"  # "percent", "percent_100", "count" or "seconds"
        },
        { 
            "metric-id": "cookbook-341-metric-id2",
            "version": 1,
            "display-name": "Cookbook 341 %",
            "description": "Percentage",
            "units": "percent_100"  # "percent", "percent_100", "count" or "seconds"
        }
    ]}
    metric_definitions_encoded = json.dumps(metric_definitions_json).encode('utf-8')
    metric_definitions_response = http_cert_verification_disabled.request(
        method='POST', headers={ "Content-Type": "application/json" },
        url=ALLUVIO_ATERNITY_APM_CMX_METRIC_ENDPOINT,
        body=metric_definitions_encoded
    )

    # 2. Generate samples with random values and put the samples to the CMX endpoint

    date = datetime.datetime.now()

    metric_samples_json = { "metric-samples": [

        # Metric 1

        { 
            "source" : ALLUVIO_ATERNITY_APM_CMX_SOURCE,
            "metric-id": "cookbook-341-metric-id1",
            "dimensions": { "cloud" : COOKBOOK_DIMENSION_CLOUD , "region" : COOKBOOK_DIMENSION_REGION , "service" : "service1" },
            "tags": { "cookbook" : "341" , "tier" : COOKBOOK_TAG_TIER },
            "timestamp": [ int(date.timestamp()) ],
            "value": [ random.randint(1, 10) ]
        },
        { 
            "source" : ALLUVIO_ATERNITY_APM_CMX_SOURCE,
            "metric-id": "cookbook-341-metric-id1",
            "dimensions": { "cloud" : COOKBOOK_DIMENSION_CLOUD , "region" : COOKBOOK_DIMENSION_REGION , "service" : "service2" },
            "tags": { "cookbook" : "341" , "tier" : COOKBOOK_TAG_TIER },
            "timestamp": [ int(date.timestamp()) ],
            "value": [ random.randint(20, 30) ]
        },
        { 
            "source" : ALLUVIO_ATERNITY_APM_CMX_SOURCE,
            "metric-id": "cookbook-341-metric-id1",
            "dimensions": { "cloud" : COOKBOOK_DIMENSION_CLOUD , "region" : COOKBOOK_DIMENSION_REGION , "service" : "service5" },
            "tags": { "cookbook" : "341" , "tier" : COOKBOOK_TAG_TIER },
            "timestamp": [ int(date.timestamp()) ],
            "value": [ random.randint(50, 100) ]
        },

        # Metric 2

        { 
            "source" : ALLUVIO_ATERNITY_APM_CMX_SOURCE,
            "metric-id": "cookbook-341-metric-id2",
            "dimensions": { "cloud" : COOKBOOK_DIMENSION_CLOUD , "region" : COOKBOOK_DIMENSION_REGION , "service" : "service1" },
            "tags": { "cookbook" : "341" , "tier" : COOKBOOK_TAG_TIER },
            "timestamp": [ int(date.timestamp()) ],
            "value": [ random.randint(80, 100) ]
        },
        { 
            "source" : ALLUVIO_ATERNITY_APM_CMX_SOURCE,
            "metric-id": "cookbook-341-metric-id2",
            "dimensions": { "cloud" : COOKBOOK_DIMENSION_CLOUD , "region" : COOKBOOK_DIMENSION_REGION , "service" : "service2" },
            "tags": { "cookbook" : "341" , "tier" : COOKBOOK_TAG_TIER },
            "timestamp": [ int(date.timestamp()) ],
            "value": [ random.randint(25, 75) ]
        },
        { 
            "source" : ALLUVIO_ATERNITY_APM_CMX_SOURCE,
            "metric-id": "cookbook-341-metric-id2",
            "dimensions": { "cloud" : COOKBOOK_DIMENSION_CLOUD , "region" : COOKBOOK_DIMENSION_REGION , "service" : "service5" },
            "tags": { "cookbook" : "341" , "tier" : COOKBOOK_TAG_TIER },
            "timestamp": [ int(date.timestamp()) ],
            "value": [ random.randint(1, 100) ]
        }
    ]}
    metric_samples_encoded = json.dumps(metric_samples_json).encode('utf-8')
    metric_samples_response = http_cert_verification_disabled.request(
        method='PUT', headers={"Content-Type": "application/json"},
        url=ALLUVIO_ATERNITY_APM_CMX_SAMPLES_ENDPOINT,
        body=metric_samples_encoded,
    )

    # Logs

    print(date)
    print("Metric definition HTTP Status: " + str(metric_definitions_response.status))
    print(metric_definitions_json)
    print("Metric sample HTTP Status: " + str(metric_samples_response.status))
    print(metric_samples_json)
    
if __name__ == '__main__':
    main()
