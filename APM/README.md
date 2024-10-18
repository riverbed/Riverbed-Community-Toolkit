# Riverbed-Community-Toolkit - APM

Dedicated to the Riverbed Community, this repo contains technical contributions that help customers, partners and engineers to integrate APM.
For example: custom scripts, custom synthetic test, cookbooks, howtos and more.

Please visit the website of Riverbed for more information about the [Riverbed Platform](https://www.riverbed.com/platform), [Application Performance Monitoring](https://www.riverbed.com/products/application-performance-monitoring) and [Documentation and Support](https://support.riverbed.com).

To use the following contents you will need active licenses of the Riverbed APM product. 

## Contents

### OpenTelemetry

| ID | Description | Tags | Last update |
| --- | --- | --- | --- | 
| [102](102-opentelemetry-spring-demo-app) | Quickstart OpenTelemetry Distributed tracing / Java microservices demo app with [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, ZipKin, Java, WebApp, Microservices, Docker | oct. 2024 |
| [103](103-opentelemetry-otlp-python-app) | A simple Python web app exporting OTLP telemetry to the [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, OTLP, Python, WebApp, Microservices, Docker | oct. 2024 |
| [104](104-opentelemetry-zipkin-nodejs-app) | A Nodejs web app exporting Zipkin telemetry to the [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, Zipkin, Javascript, Nodejs, Docker | oct. 2024 |
| [105](105-opentelemetry-go-app) | A Go 2-tier web app exporting OpenTelemetry/Jaeger/Zipkin telemetry to the [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, Jaeger, Zipkin, Go, Docker, Kubernetes | oct. 2024 |
| [106](106-opentelemetry-autoinstrumentation-java-app) | Running in docker, this simple Java app is launched with OpenTelemetry autoinstrumentation and uses multiple exporters in parallel. The [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) is collecting OTLP-gRPC telemetry. | OpenTelemetry, automatic instrumentation, OTLP, Jaeger, Java, Docker | oct. 2024 |
| [107](107-opentelemetry-autoinstrumentation-nodejs-app) | The [OpenTelemetry](https://opentelemetry.io/) automatic instrumentation is added to a **nodejs** webapp and [APM](https://www.riverbed.com/products/application-performance-monitoring) collects the OTLP telemetry with the [ OpenTelemetry APM Collector container](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, automatic instrumentation, OTLP, Nodejs, Docker | oct. 2024 |
| [108](108-collect-zipkin-nodejs-app) | [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) collecting the telemetry of a nodejs app instrumented with Zipkin | OpenTelemetry, Zipkin lib, Nodejs, Docker | oct. 2024 |
| [109](109-opentelemetry-export) | Chaining the collectors. The [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) receives native OTLP traces exported by the OTel collector | OpenTelemetry, OTel Collector, Go, Docker | oct. 2024 |
| [110](110-opentelemetry-php-app) | Some PHP samples exporting OTLP and Zipkin telemetry to the [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, PHP, Apache, OTLP, Zipkin, Docker | oct. 2024 |
| [111](111-opentelemetry-autoinstrumentation-spring-demo-app) | Containerize a Java Spring Boot app with the OpenTelemetry Java agent. Collect the traces with [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, Java agent, OTLP, Docker | nov. 2022 |
| [301](301-opentelemetry-on-kubernetes-with-apm-collector-daemonset-and-python-app) | Deploy the APM Collector on Kubernetes as a Daemonset and try it with a Python wep app | APM Collector, OpenTelemetry, Kubernetes, AKS, EKS, GCP, auto-instrumentation | oct. 2024 |
| [322](322-opentelemetry-on-kubernetes-with-apm-collector-daemonset-service-and-dotnet-app-on-windows) | A Windows container of a .NET web-app instrumented with OpenTelemetry  and exporting to the APM Collector exposed as a Kubernetes service | APM Collector, OpenTelemetry, .NET, dotnet, Windows Container, Kubernetes | sept. 2023 |
| [001](https://github.com/riverbed/FlyFast) | *maintenance* OpenTelemetry with FlyFast microservices on a Docker Host. Collect the traces with [OpenTelemetry APM Collector](https://hub.docker.com/r/aternity/apm-collector) | OpenTelemetry, Javascript, React, Python, Tornado, Microservices, Docker | jan. 2024 |

### Instrumentation and Custom-Metrics

| ID | Description | Tags | Last update |
| --- | --- | --- | --- |
| [200](200-instrument-dotnet-app-on-windows) | Quickstart to instrument a dotnet app on a windows server with APM | APM agent for Windows, dotnet, WebApp, C#, PowerShell, Windows Server 2019 | nov. 2021 |
| [201](201-instrument-java-microservices-with-apm-agentless) | Quickstart automatic instrumentation using APM Agentless for Java with microservices running in Docker | APM Agentless for Java, Java, automatic instrumentation, Profiler, WebApp, Microservices, Docker | oct. 2024 |
| [202](202-instrument-java-app-with-apm-agentless-in-container) | Run a Java app instrumented with the APM Agentless in a container | APM Agentless for Java, APM Java agent for Linux, Java, APM host-agentless, Web App, Docker, automatic instrumentation | oct. 2024 |
| [203](203-instrument-java-app-with-apm-agent-in-container) | Run a Java app instrumented with the full APM agent in a container | APM agent for Linux, Java, Web App, Docker, automatic instrumentation | oct. 2024 |
| [233](233-instrument-java-app-with-apm-agentless-on-gke) | Deploy a Java app instrumented with APM Agentless in a container to run on Google Kubernetes Engine | APM Agentless for Java, APM Java agent for Linux, Java, APM host-agentless, Web App, Google Cloud, Kubernetes, GKE, auto-instrumentation | jan. 2023 |
| [235](235-instrument-java-app-with-apm-agent-in-container-on-gke) | *in progress* - Deploy a Java app instrumented with the full APM agent in a container to run on Google Kubernetes Engine | APM agent for Linux, Java, Web App, Google Cloud, Kubernetes, GKE, auto-instrumentation | jan. 2023 |
| [238](238-instrument-java-app-with-apm-daemonset-pod-agent-on-gke) | Deploy the full APM agent on GKE as a Daemonset POD agent and instrument all the PODs of a Java web-app | APM agent for Linux, Java, Web App, Google Cloud, Kubernetes, GKE, auto-instrumentation | jan. 2023 |
| [248](248-instrument-java-app-with-apm-daemonset-pod-agent-on-eks) | Deploy the full APM agent on EKS as a Daemonset POD agent and instrument all the PODs of a Java web-app | APM agent for Linux, Java, Web App, AWS, Kubernetes, EKS, auto-instrumentation | aug. 2023 |
| [285](285-auto-instrument-app-with-riverbed-apm-on-openshift) | *draft* Auto-instrument a java app on a Red Hat OpenShift cluster using the Riverbed Operator | Red Hat OpenShift, auto-instrumentation, APM agent for Linux, Java, Web App | july 2024 |
| [401](401-apm-analysis-server-on-aws-ec2) | *in progress* APM Analysis Server on AWS EC2 | APM Analysis Server, AWS | feb. 2024 |
| [341](341-metrics-with-apm-daemonset-pod-agent-on-eks) | A Python app sending metrics to the CMX endpoint of the APM agent in Kubernetes (in AWS EKS) | APM agent, Custom Metrics, CMX, Kubernetes, EKS | aug. 2023 |
| [901](https://github.com/Aternity/custom-metrics-examples) | Getting started with custom Metrics using CMX | CMX, Kubernetes, Gett | feb. 2023
| [902](https://github.com/Aternity/custom-metrics-snow-plugin) | Example with CMX API | CMX, API | nov. 2022


Contributions can be submitted via  [Issues](https://github.com/riverbed/Riverbed-Community-Toolkit/issues) and [Pull Request](https://github.com/riverbed/Riverbed-Community-Toolkit/pulls). The team will usually give feedback in the day.

Thanks in advance!

### License

Copyright (c) 2021-2024 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
