# Dockerfile 
#
# Riverbed-Community-Toolkit
# 109-opentelemetry-export
# version: 24.10.4
#
# Example
#
# - Build
#
#   docker build -t local/service109-go:latest .
#
# - Run
#
#   docker run -it --rm -p 8109:80 -e OTEL_EXPORTER_OTLP_ENDPOINT="otel-collector:4317" -e OTEL_SERVICE_NAME="service109-go" local/service109-go:latest
#
# https://hub.docker.com/_/golang
FROM golang:1.23

WORKDIR /app

# Get OpenTelemetry example main.go
RUN curl -Ol https://raw.githubusercontent.com/open-telemetry/opentelemetry-go-contrib/refs/heads/main/examples/otel-collector/main.go

########################################################################
# Patch example app main.go to use OTEL_EXPORTER_OTLP_ENDPOINT environmnent variable
RUN echo 'package main\nimport ("os")\nvar ( OTEL_EXPORTER_OTLP_ENDPOINT = os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"))\n' > patch.go
RUN sed -i 's/\"localhost:4317\"/OTEL_EXPORTER_OTLP_ENDPOINT/g' main.go
########################################################################

RUN go mod init app/main
RUN go mod tidy 
CMD [ "go" , "run" , "patch.go" , "main.go" ]