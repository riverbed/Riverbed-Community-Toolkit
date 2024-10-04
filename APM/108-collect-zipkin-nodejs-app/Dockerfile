# Riverbed-Community-Toolkit
# 108-collect-zipkin-nodejs-app
# version: 24.10.4
#
# Dockerfile for service108-js
# A nodejs webapp with Zipkin instrumentation exporting telemetry to the APM OpenTelemetry Collector
#
# Refs:
#   * https://github.com/Aternity
#   * https://github.com/openzipkin
#
# Example
#
# - Build
#
#   docker build -t local/service108-js:latest .
#
# - Run
#
#   docker run  -it --rm -p 8108:80 -e OTEL_SERVICE_NAME="service108-js" -e ZIPKIN_ENDPOINT="http://riverbed-apm-opentelemetry-collector:9411/api/v2/spans" local/service108-js:latest   

FROM node:alpine

WORKDIR /app

# Zipkin
RUN npm install zipkin zipkin-context-cls zipkin-transport-http zipkin-instrumentation-express zipkin-instrumentation-axiosjs

# APP
RUN npm install express axios
COPY *.js ./

ENV ZIPKIN_SERVICE_NAME="service108-js"
ENV ZIPKIN_ENDPOINT="http://riverbed-apm-opentelemetry-collector:9411/api/v2/spans"

EXPOSE 80

CMD [ "node" , "app_with_zipkin.js" ]
