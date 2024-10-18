# Riverbed-Community-Toolkit
# 107-opentelemetry-autoinstrumentation-nodejs-app
# version: 24.10.4
#
# Dockerfile for service107-js
# Based on node 18, latest version supported with OpenTelemetry
#
# Example
#
# - Build
#
#   docker build -t local/service107-js:latest .
#
# - Run
#
#   docker run --rm -it -p 8107:80 -e OTEL_SERVICE_NAME="service107-js" -e OTEL_EXPORTER_OTLP_ENDPOINT="http://riverbed-apm-opentelemetry-collector:4317" local/service107-js:latest

FROM node:18-alpine

WORKDIR /app

# APP
RUN npm install express axios
COPY *.js ./

# OpenTelemetry
RUN npm install @opentelemetry/api @opentelemetry/sdk-trace-node
RUN npm install @opentelemetry/sdk-trace-base 
RUN npm install @opentelemetry/auto-instrumentations-node
RUN npm install @opentelemetry/exporter-trace-otlp-grpc

ENV OTEL_SERVICE_NAME="service107-js"
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://riverbed-apm-opentelemetry-collector:4317"

# CMD [ "node" , "app.js" ]
CMD [ "node" , "-r" , "./trace_app_with_opentelemetry_automatic-instrumentation.js" , "app.js" ]
