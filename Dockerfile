FROM python:3.7-slim

LABEL description.short="DACCS image updater"
LABEL description.long="DACCS image updater"
LABEL maintainer="Mathieu Provencher <mathieu.provencher@crim.ca>"
LABEL vendor="CRIM"
LABEL version="0.1"

# setup paths
ENV APP_DIR=/opt/local/src/daccs-image-updater
ENV TEST_DIR=${APP_DIR}/tests/integration
WORKDIR ${APP_DIR}

# install package dependencies
# RUN apt-get update && apt-get install -y jq
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    jq \
    git

# install 
COPY ./ ${APP_DIR}
WORKDIR ${TEST_DIR}
RUN pip install -r requirements.txt
WORKDIR ${APP_DIR}

CMD ["bash"]