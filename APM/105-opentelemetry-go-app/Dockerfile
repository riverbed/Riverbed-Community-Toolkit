# Riverbed-Community-Toolkit
# 105-opentelemetry-go-app
# version: 22.06.03

# Build container
FROM golang:latest AS gobuild

WORKDIR /gobuild
COPY . .
RUN make

# Run container
FROM alpine:latest

WORKDIR /
COPY --from=gobuild /gobuild/bin/opentelemetry-go-example /
COPY --from=gobuild /gobuild/configs/opentelemetry-go-example.yml configs/
RUN apk add --no-cache libc6-compat

ENV ATERNITY_COLLECTOR_SERVICE_HOST localhost

ENV OTEL_SERVICE_NAME service105

ENV OTEL_TRACES_EXPORTER otlp

# Set on or off to display traces on the console
ENV ADD_CONSOLE_EXPORTER off

ENV FRONTEND_SERVICE_HOST localhost
ENV FRONTEND_SERVICE_PORT 8081
ENV BACKEND_SERVICE_HOST localhost 
ENV BACKEND_SERVICE_PORT 9000

ENTRYPOINT ["/opentelemetry-go-example"]
