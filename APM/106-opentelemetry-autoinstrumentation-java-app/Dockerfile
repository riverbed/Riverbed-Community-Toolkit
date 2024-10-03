# Dockerfile
#
# Riverbed-Community-Toolkit (https://github.com/riverbed/Riverbed-Community-Toolkit)
# 106-opentelemetry-autoinstrumentation-java-app
# version: 22.11.221121
#
# Usage:
#
#   docker build .
#
#   docker run local/cookbook106

########################################################################

FROM maven:3.8.4-openjdk-17-slim as cookbook106-builder

WORKDIR /src

COPY pom.xml ./
RUN mvn dependency:go-offline

COPY src ./src

RUN mvn package

########################################################################

FROM openjdk:17

WORKDIR /app

COPY --from=cookbook106-builder /src/target/cookbook106*.jar myapp.jar

# OPENTELEMETRY, https://opentelemetry.io/

## Configure OpenTelemetry instrumentation (OTEL_TRACES_EXPORTER default is "OTLP")
ENV OTEL_SERVICE_NAME=cookbook106-java
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

## Inject OpenTelemetry automatic instrumentation
RUN curl -OL https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.20.1/opentelemetry-javaagent.jar
ENV JAVA_TOOL_OPTIONS="-javaagent:./opentelemetry-javaagent.jar"
CMD [ "java","-jar","myapp.jar" ]
