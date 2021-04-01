FROM openjdk:15-jdk-buster

ARG GRADLE_VERSION=6.6.1
ARG USER_HOME_DIR="/app"
ARG BASE_URL=https://services.gradle.org/distributions

ENV GRADLE_HOME "/usr/share/gradle-${GRADLE_VERSION}"

#
#   This image runs on kubernetes in Google Cloud and on OpenShift. Ideally we have one
#   strict setup with a non-root user in its own group but since OpenShift assigns the uid
#   for you we cannot assume that our top level process runs with our assigned uid.
#   What we do know however is that the Openshift assigned user id always has group 0 (the root group)
#   so we're using the user ekggroup in group root for all non-openshift deployments.
#
#   See also https://www.openshift.com/blog/jupyter-on-openshift-part-6-running-as-an-assigned-user-id
#   
ARG UID=2000
ENV HOME=/home/ekgprocess
RUN useradd --system --no-user-group --home-dir /home/ekgprocess --create-home --shell /bin/bash --uid ${UID} --gid 0 ekgprocess && \
    chgrp -Rf root /home/ekgprocess && chmod -Rf g+w /home/ekgprocess

USER root

ENV GRADLE_USER_HOME "${HOME}/.gradle/"

RUN apt-get update -qqy && \
    apt-get install -qqy curl && \
    mkdir -p /usr/share "${GRADLE_USER_HOME}" && \
    curl -fsSL -o "gradle-${GRADLE_VERSION}-bin.zip" "${BASE_URL}/gradle-${GRADLE_VERSION}-bin.zip" && \
    unzip -qq "gradle-${GRADLE_VERSION}-bin.zip" && \
    rm -f "gradle-${GRADLE_VERSION}-bin.zip" && \
    mv "gradle-${GRADLE_VERSION}" /usr/share && \
    ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle && \
    apt-get remove -qqy --purge curl && \
    rm /var/lib/apt/lists/*_*

ADD gradle.properties "${GRADLE_USER_HOME}"

#
#   just to be sure, everything we added to the home directory is owned by user ekgprocess
#   and group root (see openshift comments at the top of this dockerfile)
#
RUN cd /home/ekgprocess && chown -vR ekgprocess:root .

#
# 	now we leave the image to run as user ekgprocess from its home directory
#
USER ekgprocess
WORKDIR /home/ekgprocess

ENTRYPOINT ["/usr/bin/gradle"]

