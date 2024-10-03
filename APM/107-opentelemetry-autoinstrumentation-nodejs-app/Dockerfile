# Aternity Tech-Community
# 107-opentelemetry-autoinstrumentation-nodejs-app
# version: 22.11.221128
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
#   docker run --rm -it -p 8107:80 -e OTEL_SERVICE_NAME="service107-js" -e OTEL_EXPORTER_OTLP_ENDPOINT="http://aternity-opentelemetry-collector:4317" local/service107-js:latest

FROM node:18-alpine

WORKDIR /app

# APP
RUN npm install express axios
COPY *.js ./
# TODO: remove this patch, when docker-compose "subdir not supported yet" issue is fixed
COPY 107-opentelemetry-autoinstrumentation-nodejs-app/*.js ./

# OpenTelemetry
RUN npm install @opentelemetry/api @opentelemetry/sdk-trace-node
RUN npm install @opentelemetry/sdk-trace-base 
RUN npm install @opentelemetry/auto-instrumentations-node
RUN npm install @opentelemetry/exporter-trace-otlp-grpc

ENV OTEL_SERVICE_NAME="service107-js"
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://aternity-opentelemetry-collector:4317"

# CMD [ "node" , "app.js" ]
CMD [ "node" , "-r" , "./trace_app_with_opentelemetry_automatic-instrumentation.js" , "app.js" ]
