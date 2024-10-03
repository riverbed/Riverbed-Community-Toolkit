# Dockerfile
# 23.8.25
# ALLUVIO Aternity Tech Community Cookbook (https://github.com/riverbed/Riverbed-Community-Toolkit)

# Usage:
#
#   1. Build
#      docker build --tag cookbook-248-app .
#
#   2. Run
#      docker run --rm -p 8080:8080 cookbook-248-app

###############################################################################
# App section
###############################################################################

# Start a build stage to copy local sources and build
FROM maven:3-openjdk-11-slim as builder
WORKDIR /app-build
COPY . .
RUN mvn clean package 

# Switch to the app stage
FROM openjdk:11-jre-slim-buster as app
COPY --from=builder /app-build/target/demo-*.jar /app/spring-demo.jar
EXPOSE 8080

# Launch the app
WORKDIR /app
CMD ["java","-jar", "spring-demo.jar"]
