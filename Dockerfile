# Copyright 2023 EPAM Systems.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

# See the License for the specific language governing permissions and
# limitations under the License.
FROM node:18.17.0-alpine3.18 as node
FROM 093899590031.dkr.ecr.eu-central-1.amazonaws.com/edp-delivery/edp-jenkins-base-agent:1.0.37

USER root

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

ENV AWSCLI_VERSION=1.29.27 \
    CRANE_VERSION=v0.14.0 \
    GOPATH="/tmp/go" \
    GOROOT="/usr/local/go" \
    GO_VERSION=1.19.12 \
    GPLUSPLUS_VERSION=10.3.1_git20210424-r2 \
    HELM_VERSION=v3.12.1 \
    NPM_UPDATE_VERSION=9.6.7 \
    NPM_VERSION=7.17.0-r \
    PYTHON_VERSION=3.9.17-r0 \
    PIP_VERSION=20.3.4-r1 \
    BINUTILS=2.35.2-r2 \
    LIBSTDC=10.3.1_git20210424-r2

ENV PATH="$GOPATH/bin:$GOROOT/bin:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/bin/:$PATH"

RUN apk --no-cache add \
        python3=$PYTHON_VERSION \
        py3-pip=$PIP_VERSION \
        g++=$GPLUSPLUS_VERSION \
        npm=$NPM_VERSION \
        binutils=$BINUTILS \
        libstdc++=$LIBSTDC \
    && pip3 install --no-cache-dir --upgrade pip==23.1.2

# Copy nodejs from alpine node image
COPY --from=node /usr/local/bin/node /usr/bin/

# Install NPM
RUN npm install -g npm@$NPM_UPDATE_VERSION && \
# Install Go lang
    curl -fsSLo /tmp/go$GO_VERSION.linux-amd64.tar.gz https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz && \
    tar -xvf /tmp/go$GO_VERSION.linux-amd64.tar.gz && rm -rf /tmp/go$GO_VERSION.linux-amd64.tar.gz && \
    mv go /usr/local && \
    mkdir -p /home/jenkins/go/src && \
# Install Helm
    curl -Lo /tmp/helm.tar.gz "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf /tmp/helm.tar.gz -C /tmp/ && \
    mv /tmp/linux-amd64/helm /usr/local/bin/ && rm -rf /tmp/helm.tar.gz /tmp/linux-amd64/ && \
# Install AWSCLI
    python3 -m pip install --no-cache-dir awscli==$AWSCLI_VERSION && \
# Install Crane tool
    curl -LO https://github.com/google/go-containerregistry/releases/download/$CRANE_VERSION/go-containerregistry_Linux_x86_64.tar.gz && \
    tar -xvf go-containerregistry_Linux_x86_64.tar.gz && \
    mv crane gcrane  /usr/local/bin/ && \
    rm go-containerregistry_Linux_x86_64.tar.gz

RUN chown -R "1001:0" "$HOME" && \
    chmod -R "g+rw" "$HOME"

USER 1001
