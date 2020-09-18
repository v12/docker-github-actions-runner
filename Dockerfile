FROM ubuntu:20.04

ARG GITHUB_RUNNER_VERSION="2.273.3"

ENV RUNNER_NAME "runner"
ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR "_work"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -yq jq curl git sudo unzip iputils-ping liblttng-ust0 libcurl4 libssl1.1 libkrb5-3 zlib1g libicu66 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m github && \
    usermod -aG sudo github && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER github
WORKDIR /home/github

RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
