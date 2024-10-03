# Dockerfile 
# version: 23.1.230113
# ALLUVIO Aternity Tech Community Cookbook (https://github.com/riverbed/Riverbed-Community-Toolkit)
#
# Containerize the APM agent for Daemonset POD deployment in Kubernetes
#
# Note: For the deployment the APM install basedir path (/opt) must be mounted on a writeable volume (i.e a writeable node path)
# For example on a GKE Standard Linux Ubuntu cluster the node path can be /var/lib/toolbox/alluvio-apm

###############################################################################
# Aternity APM Daemonset POD agent
###############################################################################

# Prepare the apm stage
FROM ubuntu as apm
ARG APM_CUSTOMIZATION_PATH="./apm-customization"
RUN apt-get update && apt-get install --no-install-recommends -y jq gzip tar cpio && rm -rf /var/lib/apt/lists/*
USER root
WORKDIR /var/apm-customization

# Add the package, install.properties and customization files (.json, initial-mapping and tags.yaml)
COPY $APM_CUSTOMIZATION_PATH/appinternals_agent_latest_linux.gz .
COPY $APM_CUSTOMIZATION_PATH/install.properties .
COPY $APM_CUSTOMIZATION_PATH/config/. ./config/.
COPY $APM_CUSTOMIZATION_PATH/install-and-run-ds-pod-agent.sh .
RUN chmod +x install-and-run-ds-pod-agent.sh

# Define Aternity APM common settings
ENV logging.level.root="INFO"
ENV PANORAMA_LOG_PURGE_HOURS="1h"
ENV RVBD_AGENT_PORT="7073"
ENV RVBD_AGENT_FILES=1
ENV AIX_INSTRUMENT_ALL=1
ENV RVBD_DSAHOST=127.0.0.1
ENV container_metrics=true

# Optional CUSTOM APM tags decoration
ENV APM_CT_KUBERNETES_CLUSTER_NAME=""
ENV APM_CT_KUBERNETES_CLOUD=""
ENV APM_CT_KUBERNETES_REGION=""

###############################################################################

# Define environment variables that must be configured at runtime for (re)configuration
ENV ALLUVIO_ATERNITY_APM_CUSTOMER_ID=""
ENV ALLUVIO_ATERNITY_APM_SAAS_SERVER_HOST=""

# Launch the app
WORKDIR /app
CMD /bin/sh /var/apm-customization/install-and-run-ds-pod-agent.sh
