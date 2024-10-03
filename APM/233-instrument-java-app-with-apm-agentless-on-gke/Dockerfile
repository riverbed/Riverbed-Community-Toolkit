# Dockerfile
# Coookbook 233 - Aternity Tech Community Cookbook (https://github.com/Aternity/Tech-Community)
# v22.11.221108
# 
# Description:
#
#   Containerize the Spring PetClinic demo app (https://github.com/spring-projects/spring-petclinic.git)
#   with Aternity APM Java agent for Linux (https://www.riverbed.com/products/application-performance-monitoring)
#
# Usage
#   
#   1. Get a local copy of the Aternity APM Java agent for Linux package
#      # aternity-apm-jida-linux.zip 
#   2. Build
#      docker build --tag cookbook-233 .
#   3. Run
#      docker run --rm -p 8080:8080 -e RVBD_ANALYSIS_SERVER="psockets.apm.my_environment.aternity.com" -e RVBD_CUSTOMER_ID="1234-12341243" cookbook-233
#
###############################################################################

# Build the application from source
FROM maven:3-openjdk-11-slim as build
RUN apt-get update && apt-get install git -y && rm -rf /var/lib/apt/lists/*
WORKDIR /sources
RUN git clone https://github.com/spring-projects/spring-petclinic.git .
RUN mvn clean package 

FROM openjdk:11 as app
COPY --from=build /sources/target/spring-petclinic-*.jar /spring-petclinic.jar
EXPOSE 8080
CMD ["java","-jar", "spring-petclinic.jar"]

###############################################################################
# Add Aternity APM Java agent library for Linux
###############################################################################

# 1. Fetch the package and expand the Aternity APM Java agent for Linux package
FROM busybox as aternity-apm-java-agent
COPY aternity-apm-jida-linux.zip /aternity-apm.zip
RUN unzip /aternity-apm.zip -d /aternity-apm

# 2. Copy the Aternity APM Java agent for Linux library folder to the app container
FROM app 
COPY --from=aternity-apm-java-agent /aternity-apm /aternity-apm/.

# 3. Configure the Aternity APM Java agent for Linux
#    with customer id, psockets host and instance name as it will appear in the Aternity APM webconsole)
ENV RVBD_CUSTOMER_ID="my_customerid"
ENV RVBD_ANALYSIS_SERVER="psockets.apm.my_environment.aternity.com"
ENV RVBD_APP_INSTANCE="" 

# 4. Keep this setting to enable Aternity APM Java agent for Linux
ENV RVBD_AGENT_FILES=1

# 5. Configure java options environment variable to inject the Aternity APM agent 
ENV JAVA_TOOL_OPTIONS=-agentpath:/aternity-apm/agent/lib/libAwProfile64.so

###############################################################################
###############################################################################