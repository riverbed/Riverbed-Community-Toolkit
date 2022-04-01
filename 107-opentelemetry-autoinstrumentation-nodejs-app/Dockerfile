# Aternity Tech-Community
# 107-opentelemetry-autoinstrumentation-nodejs-app
# version: 22.4.1
#
# Dockerfile for service107-js
#
# Example
#
# - Build
#
#   docker build -t local/service107-js:latest .
#
# - Run
#
#   docker run  -it -e OTEL_SERVICE_NAME="service107-js" -e OTEL_EXPORTER_OTLP_ENDPOINT="aternity-opentelemetry-collector:4317" local/service107-js:latest   

FROM node:alpine

WORKDIR /app

# OpenTelemetry
RUN npm install @opentelemetry/api @opentelemetry/sdk-trace-node @opentelemetry/instrumentation-express
RUN npm install @opentelemetry/instrumentation-grpc @opentelemetry/instrumentation-http 
RUN npm install @opentelemetry/sdk-trace-base 
RUN npm install @opentelemetry/exporter-trace-otlp-grpc
RUN npm install @opentelemetry/auto-instrumentations-node

# APP
RUN npm install express axios
COPY *.js ./

# TODO: remove this patch when docker build "subdir not supported yet" issue is fixed
COPY 107-opentelemetry-autoinstrumentation-nodejs-app/*.js ./


ENV OTEL_SERVICE_NAME="service107-js"
ENV OTEL_EXPORTER_OTLP_ENDPOINT="aternity-opentelemetry-collector:4317"

CMD [ "node" , "-r" , "./trace_app_with_opentelemetry_automatic-instrumentation.js" , "app.js" ]
