# Dockerfile
#
# Aternity Tech-Community (https://github.com/riverbed/Riverbed-Community-Toolkit)
# 111-opentelemetry-autoinstrumentation-spring-demo-app
# v22.11.221121
# 
# Description:
#
#   Containerize the Spring PetClinic demo app (see https://github.com/spring-projects/spring-petclinic.git)
#   with OpenTelemetry Java agent
#
# Example
#   
#   # 1. Build
#        docker build --tag cookbook-111 .
#   # 2. Run
#        docker run --rm -p 8080:8080 -e OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317" cookbook-111
#
###############################################################################


# Fetch the OpenTelemetry Java Agent 

FROM openjdk as app-builder
RUN curl -OL https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.20.1/opentelemetry-javaagent.jar


# Application image

FROM springcommunity/spring-framework-petclinic as app


# Inject OpenTelemetry automatic instrumentation

COPY --from=app-builder ./opentelemetry-javaagent.jar .

ENV JAVA_TOOL_OPTIONS="-javaagent:./opentelemetry-javaagent.jar"

ENV OTEL_SERVICE_NAME=cookbook111-java
ENV OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="http://localhost:4317"
ENV OTEL_TRACES_EXPORTER=otlp
