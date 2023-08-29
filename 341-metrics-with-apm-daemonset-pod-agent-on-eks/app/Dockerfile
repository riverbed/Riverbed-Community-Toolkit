# Dockerfile 
# version: 23.8.230921
# Riverbed - ALLUVIO Aternity Tech Community Cookbook (https://github.com/Aternity/Tech-Community)
#
# Containerize the Python app of cookbook 341

FROM python
RUN pip3 install urllib3
WORKDIR /app

COPY cookbook-341-generate-cmx-metrics.py app.py

ENV ALLUVIO_ATERNITY_APM_CMX_ENDPOINT=https://localhost:7074
ENV ALLUVIO_ATERNITY_APM_CMX_SOURCE="cookbook-341-source"
ENV COOKBOOK_DIMENSION_CLOUD="local"
ENV COOKBOOK_DIMENSION_REGION="local"
ENV COOKBOOK_TAG_TIER="small"

CMD python3 app.py
