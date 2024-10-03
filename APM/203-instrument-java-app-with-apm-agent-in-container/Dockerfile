# Dockerfile
# 23.1.21
# Cookbook 203 - Aternity Tech Community Cookbook (https://github.com/Aternity/Tech-Community)
#
# Usage:
#
#   Preparation : customize the configuration files inside the folder apm-customization
#       1. Download the latest APM agent package for linux in the apm-customization folder, appinternals_agent_latest_linux.gz.
#       2. Generate a specific configuration for your app (in the APM webconsole > CONFIGURE > AGENTS > Configurations). 
#           Download the file in the config subfolder. By default name it configuration.json.
#       3. *optional* If the filename of the custom configuration file gernerated in step 2 is not configuration.json, 
#           Edit the initial-mapping file to map the process name to other specific configuration file
#       3. *optional* Add custom static tags in the tags.xml (in the config subfolder)
#       4. *optional* Customize the installation properties in the install.properties file
#
#   build: docker build -t spring-demo .
#   run: docker run -e ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST="agents.apm.myaccount.aternity.com" -e ALLUVIO_ATERNITY_APM_CUSTOMER_ID="12341234-12341234-13241234" -e RVBD_APP_INSTANCE="cookbook-203" -p 8080:8080 spring-demo

###############################################################################
# App section
###############################################################################

# Start a build stage to copy local sources and build
FROM maven:3-openjdk-11-slim as builder
WORKDIR /app-build
COPY ./app/. .
RUN mvn clean package 

# Switch to the app stage
FROM openjdk:11-jre-slim-buster as app
COPY --from=builder /app-build/target/demo-*.jar /app/spring-demo.jar
EXPOSE 8080

###############################################################################
# Add ALLUVIO Aternity APM agent instrumentation
###############################################################################

# Prepare the apm stage
FROM app as apm
ARG APM_CUSTOMIZATION_PATH="./apm-customization"
ARG APM_PACKAGE_FILENAME="appinternals_agent_latest_linux"
RUN apt-get update && apt-get install --no-install-recommends -y jq cpio procps && rm -rf /var/lib/apt/lists/*
USER root
WORKDIR /var/apm-customization

# Get the package and install.properties, silently install and cleanup
COPY $APM_CUSTOMIZATION_PATH/$APM_PACKAGE_FILENAME.gz .
COPY $APM_CUSTOMIZATION_PATH/install.properties .
RUN gunzip $APM_PACKAGE_FILENAME.gz && chmod +x $APM_PACKAGE_FILENAME && ./$APM_PACKAGE_FILENAME -silentinstall install.properties && [ -f "/opt/Panorama/hedzup/mn/lib/librpilj64.so" ]
RUN rm -rf $APM_PACKAGE_FILENAME install.properties

# Add customization files if any: instrumentation configurations (.json), initial-mapping and tags.yaml
COPY $APM_CUSTOMIZATION_PATH/config/initial-mapping  /opt/Panorama/hedzup/mn/userdata/config/.
COPY $APM_CUSTOMIZATION_PATH/config/* /opt/Panorama/hedzup/mn/userdata/config/.
COPY $APM_CUSTOMIZATION_PATH/bootstrap-agent.sh .
RUN chmod +x bootstrap-agent.sh

# Define APM common settings
ENV logging.level.root="INFO"
ENV PANORAMA_LOG_PURGE_HOURS="1h"
ENV RVBD_AGENT_PORT="7073"
ENV RVBD_AGENT_FILES=1
ENV AIX_INSTRUMENT_ALL=1
ENV RVBD_DSAHOST=127.0.0.1
ENV container_metrics=true

# Environment variables that need to be set at runtime for (re)configuration
ENV ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST=""
ENV ALLUVIO_ATERNITY_APM_CUSTOMER_ID=""
ENV RVBD_APP_INSTANCE=""

###############################################################################
# Configure the container command with a bootstrap to start the APM agent
###############################################################################

# Configure the command to run the bootstrap launcher with java options to instrument and expose JMX metrics.
# The bootstrap will start the APM agent and then the app. The initial command for the app is: CMD ["java","-jar", "spring-demo.jar"]

# Launch the app
WORKDIR /app
CMD ["/var/apm-customization/bootstrap-agent.sh","java","-Dcom.sun.management.jmxremote.port=0","-Dcom.sun.management.jmxremote.ssl=false","-Dcom.sun.management.jmxremote.authenticate=false","-agentpath:/opt/Panorama/hedzup/mn/lib/librpilj64.so","-Driverbed.moniker=spring-demo","-jar", "spring-demo.jar"]
