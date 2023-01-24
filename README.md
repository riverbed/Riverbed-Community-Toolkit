# Alluvio Aternity Tech-Community repository

Dedicated to the Alluvio Aternity Community, this repo contains technical contributions that help customers, partners and engineers to customize and leverage Alluvio Aternity products for Digital Experience Management (DEM).
For example: custom scripts, custom synthetic test, cookbooks, howtos and more.

Please visit the website of [Alluvio by Riverbed](https://www.riverbed.com/products/unified-observability) for Solutions resources, [Free Trials](https://www.riverbed.com/trial-downloads) and [Trials for Alluvio Aternity](https://www.riverbed.com/trial-download/alluvio-aternity), Trainings, [Documentation and Support](https://support.riverbed.com/).

To use the following contents you will need active licenses of the Alluvio Aternity DEM products. 

## Contents

| ID | Description | DEM | Tags | Last update |
| --- | --- | --- | --- | --- | 
| [102](102-opentelemetry-spring-demo-app) | Quickstart OpenTelemetry Distributed tracing / Java microservices demo app with [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, ZipKin, Java, WebApp, Microservices, Docker | mar. 2022 |
| [103](103-opentelemetry-otlp-python-app) | A simple Python web app exporting OTLP telemetry to the [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, OTLP, Python, WebApp, Microservices, Docker | july 2022 |
| [104](104-opentelemetry-zipkin-nodejs-app) | A Nodejs web app exporting Zipkin telemetry to the [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, Zipkin, Javascript, Nodejs, Docker | mar. 2022 |
| [105](105-opentelemetry-go-app) | A Go 2-tier web app exporting OpenTelemetry/Jaeger/Zipkin telemetry to the [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, Jaeger, Zipkin, Go, Docker, Kubernetes | jun. 2022 |
| [106](106-opentelemetry-autoinstrumentation-java-app) | Running in docker, this simple Java app is launched with OpenTelemetry autoinstrumentation and uses multiple exporters in parallel. The [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) is collecting OTLP-gRPC telemetry. | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, automatic instrumentation, OTLP, Jaeger, Java, Docker | mar. 2022 |
| [107](107-opentelemetry-autoinstrumentation-nodejs-app) | The [OpenTelemetry](https://opentelemetry.io/) automatic instrumentation is added to a **nodejs** webapp and [Aternity APM](https://www.aternity.com/apm) collects the OTLP telemetry with the [Aternity OpenTelemetry Collector container](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, automatic instrumentation, OTLP, Nodejs, Docker | apr. 2022 |
| [108](108-collect-zipkin-nodejs-app) | [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) collecting the telemetry of a nodejs app instrumented with Zipkin | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, Zipkin lib, Nodejs, Docker | mar. 2022 |
| [109](109-opentelemetry-export) | Chaining the collectors. The [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) receives native OTLP traces exported by the OTel collector | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, OTel Collector, Go, Docker | mar. 2022 |
| [110](110-opentelemetry-php-app) | Some PHP samples exporting OTLP and Zipkin telemetry to the [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, PHP, Apache, OTLP, Zipkin, Docker | july 2022 |
| [111](111-opentelemetry-autoinstrumentation-spring-demo-app) | Containerize a Java Spring Boot app with the OpenTelemetry Java agent. Collect the traces with [Aternity OpenTelemetry Collector](https://hub.docker.com/r/aternity/apm-collector) | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | OpenTelemetry, Java agent, OTLP, Docker | nov. 2022 |
| [200](200-instrument-dotnet-app-on-windows) | Quickstart to instrument a dotnet app on a windows server with Aternity APM | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | APM agent for Windows, dotnet, WebApp, C#, PowerShell, Windows Server 2019 | nov. 2021 |
| [201](201-instrument-java-spring-demo-app) | Quickstart automatic instrumentation using APM Agentless for Java with microservices | [Aternity APM](https://www.aternity.com/application-performance-monitoring/) | APM Agentless for Java, Java, automatic instrumentation, Profiler, WebApp, Microservices, Docker | apr. 2022 |
| [202](202-instrument-java-app-with-apm-java-agent-in-container) | Containerize an applicaion with the APM Agentless for Java | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | APM Agentless for Java, APM Java agent for Linux, Java, APM host-agentless, Web App, Docker, automatic instrumentation | oct. 2022 |
| [203](203-instrument-java-app-with-apm-agent-in-container) | Containerizing the full APM agent along with the Java app | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | APM agent for Linux, Java, Web App, Docker, automatic instrumentation | jan. 2023 |
| [233](233-instrument-java-app-with-apm-java-agent-on-gke) | Containerize an applicaion with the APM Agentless for Java and deploy it Google Kubernetes Engine | [Alluvio Aternity APM](https://www.riverbed.com/products/application-performance-monitoring) | APM Agentless for Java, APM Java agent for Linux, Java, APM host-agentless, Web App, Google Cloud, Kubernetes, GKE, auto-instrumentation | nov. 2022 |

Contributions can be submitted via  [Issues](https://github.com/Aternity/Tech-Community/issues) and [Pull Request](https://github.com/Aternity/Tech-Community/pulls). The team will usually give feedback in the day.

Thanks in advance!

### License

Copyright (c) 2022 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
