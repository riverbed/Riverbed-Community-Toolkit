# Dockerfile 
#
# Aternity Tech-Community
# 109-opentelemetry-export
# version: 22.11.221128
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
FROM golang:1.18

WORKDIR /usr/src/example

# Get OpenTelemetry example main.go
RUN curl -Ol https://raw.githubusercontent.com/open-telemetry/opentelemetry-go/main/example/otel-collector/main.go

########################################################################
# Patch example app main.go to use OTEL_EXPORTER_OTLP_ENDPOINT environmnent variable
RUN echo 'package main\nimport ("os")\nvar ( OTEL_EXPORTER_OTLP_ENDPOINT = os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"))\n' > patch.go
RUN sed -i 's/\"localhost:30080\"/OTEL_EXPORTER_OTLP_ENDPOINT/g' main.go
########################################################################

RUN go mod init example/main
RUN go mod tidy 

# RUN go install ./main.go

CMD [ "go" , "run" , "patch.go" , "main.go" ]