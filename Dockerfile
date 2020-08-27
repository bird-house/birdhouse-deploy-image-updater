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
RUN apt-get update && apt-get install -y jq

# install runtime/package dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
# 		ca-certificates \
# 		netbase \
# 		gcc \
# 		python3-dev \
# 	&& rm -rf /var/lib/apt/lists/* \
#     && pip install --no-cache-dir --upgrade pip setuptools \
#     && pip install --no-cache-dir -e ${APP_DIR}

# install 
COPY ./ ${APP_DIR}
WORKDIR ${TEST_DIR}
RUN pip install -r requirements.txt
WORKDIR ${APP_DIR}

CMD ["bash"]