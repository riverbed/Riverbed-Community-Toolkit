# Riverbed-Community-Toolkit
# 104-opentelemetry-zipkin-nodejs-app
# version: 24.10.3
#
# Dockerfile for service104-js
#
# Example
#
# - Build
#
#   docker build -t local/service104-js:latest .
#
# - Run
#
#   docker run  -it -e OTEL_SERVICE_NAME="service104-js" -e OTEL_EXPORTER_ZIPKIN_ENDPOINT="http://riverbed-apm-opentelemetry-collector:9411/api/v2/spans" local/service104-js:latest   

FROM node:alpine

WORKDIR /app

# OpenTelemetry
RUN npm install @opentelemetry/api @opentelemetry/sdk-trace-node @opentelemetry/instrumentation-express
RUN npm install @opentelemetry/instrumentation-grpc @opentelemetry/instrumentation-http 
RUN npm install @opentelemetry/sdk-trace-base 
RUN npm install @opentelemetry/exporter-zipkin

# APP
RUN npm install express axios
COPY *.js ./

ENV OTEL_SERVICE_NAME="service104-js"
ENV OTEL_EXPORTER_ZIPKIN_ENDPOINT="http://riverbed-apm-opentelemetry-collector:9411/api/v2/spans"

CMD [ "node" , "-r" , "./trace_app_with_opentelemetry.js" , "app.js" ]
