# Dockerfile 
# 23.9.230915
# ALLUVIO Aternity Tech Community Cookbook (https://github.com/riverbed/Riverbed-Community-Toolkit)
# 
# Containerize a .NET webapp for Windows, instrumented with OpenTelemetry
#
# Usage:
#   
#   1. Build
#
#       docker build --tag dotnet_webapp:23.9.15 .
#   
#   2.  Run
#
#       docker run --tty --rm --env OTEL_EXPORTER_OTLP_ENDPOINT="http://apm-collector-service_on_my_k8s_cluster:4317" --publish 8080:80 dotnet_webapp:23.9.15
#           or
#       docker run --tty --rm --env OTEL_EXPORTER_OTLP_ENDPOINT="http://10.0.0.80:4317" --publish 8080:80 dotnet_webapp:23.9.15
#           or
#       docker run --tty --rm --env OTEL_EXPORTER_OTLP_ENDPOINT="http://10.0.0.80:4317" --env URL_WEBSERVICE="https://mywebservice.mycorp.net" --publish 8080:80 dotnet_webapp:23.9.15
#
#   3. Browse the app http://127.0.0.1:8080
#

# Stage to build the .NET project

FROM mcr.microsoft.com/dotnet/sdk:7.0 as builder
WORKDIR /build
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish --configuration Release --output out

# Stage to build the image of the app

FROM mcr.microsoft.com/dotnet/aspnet:7.0 as app
WORKDIR /app
COPY --from=builder /build/out .
CMD ["dotnet", "dotnet_webapp.dll"]

# app external webservice configuration (demo)
ENV URL_WEBSERVICE="http://www.riverbed.com"

###########################################################
# Add OpenTelemetry instrumentation configuration
###########################################################

ENV OTEL_SERVICE_NAME="cookbook-dotnet_webapp-windows"
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://apm-collector-service:4317"
