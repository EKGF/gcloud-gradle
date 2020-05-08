FROM gcr.io/cloud-builders/javac:8

ARG GRADLE_VERSION=6.4
ARG USER_HOME_DIR="/app"
ARG BASE_URL=https://services.gradle.org/distributions

ENV GRADLE_HOME "/usr/share/gradle-${GRADLE_VERSION}"
ENV GRADLE_USER_HOME "${USER_HOME_DIR}/.gradle/"

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

ENTRYPOINT ["/usr/bin/gradle"]

