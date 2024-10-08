# Dockerfile
# Coookbook 202 - Riverbed-Community-Toolkit (https://github.com/riverbed/Riverbed-Community-Toolkit)
# 24.10.4
# 
# Description:
#
#   Containerize the Spring PetClinic demo app (see https://github.com/spring-projects/spring-petclinic.git)
#   with APM Java agent for Linux
#
# Example
#   
#   # 1. Get a local copy of the APM Java agent for Linux package
#        # aternity-apm-jida-linux.zip 
#   # 2. Build
#        docker build --tag cookbook-202 .
#   # 3. Run
#        docker run --rm -p 8080:8080 -e RVBD_ANALYSIS_SERVER="psockets.apm.my_environment.aternity.com" -e RVBD_CUSTOMER_ID="1234-12341243" cookbook-202
#
###############################################################################

# Start from the application image
FROM springcommunity/spring-framework-petclinic as app

###############################################################################
# Add APM Java agent for Linux library
###############################################################################

# 1. Fetch the package and expand the APM Java agent for Linux package
FROM busybox as aternity-apm-java-agent
COPY aternity-apm-jida-linux.zip /aternity-apm.zip
RUN unzip /aternity-apm.zip -d /aternity-apm

# 2. Copy the APM Java agent for Linux library folder to the app container
FROM app 
COPY --from=aternity-apm-java-agent /aternity-apm /aternity-apm/.

# 3. Configure the APM Java agent for Linux
#    with customer id, psockets host and instance name as it will appear in the APM web console)
ENV RVBD_CUSTOMER_ID="my_customerid"
ENV RVBD_ANALYSIS_SERVER="psockets.apm.my_environment.aternity.com"
ENV RVBD_APP_INSTANCE="cookbook-202" 

# 4. Keep this setting to enable APM Java agent for Linux
ENV RVBD_AGENT_FILES=1

# 5. Configure java options environment variable to inject the APM agent 
ENV JAVA_TOOL_OPTIONS=-agentpath:/aternity-apm/agent/lib/libAwProfile64.so

###############################################################################
###############################################################################
