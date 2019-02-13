FROM openjdk:8-jdk

MAINTAINER SpiritNguyen

RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

# Tao Folder va phan quyen
RUN mkdir -p /var/jenkins_home \
	&& chown  ${uid}:${gid} /var/jenkins_home

# Tao Group & User
RUN groupadd -g ${gid} ${group} \
	&& useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Cap quyen 
VOLUME /var/jenkins_home

# Tao Folder : Folder chua agent
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d


# Cai Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --batch --verify /tini.asc /tini

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# Cai Jenkins
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.164}

# Checksum 
ARG JENKINS_SHA=8a5c34fce5ba91e9b9a72f550525ff28659171ee45f44dae2cc84aba47115e22

ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -
