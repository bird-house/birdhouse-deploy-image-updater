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
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    jq \
    git \
    curl \
    lsof

# install GitHub's hub CLI tool
RUN wget -O hub.tgz --progress=dot:mega https://github.com/github/hub/releases/download/v2.14.2/hub-linux-amd64-2.14.2.tgz
RUN mkdir /hub
RUN tar -xvf hub.tgz -C /hub --strip-components 1
RUN bash /hub/install

# configure github account. Defaults, overridden by GITHUB_USER
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

# install 
COPY ./ ${APP_DIR}
WORKDIR ${TEST_DIR}
RUN pip install -r requirements.txt
WORKDIR ${APP_DIR}

CMD ["bash"]