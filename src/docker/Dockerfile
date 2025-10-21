#escape=`

FROM --platform=linux/$TARGETARCH debian:stable-slim AS prepare

ARG TARGETARCH
ARG CODEMETER_VERSION=8.40.7120.501
ADD codemeter-lite_${CODEMETER_VERSION}_${TARGETARCH}.deb /cmlite.deb

RUN set -eux; `
    dpkg-deb -xv /cmlite.deb /codemeter; 

FROM --platform=linux/$TARGETARCH debian:stable-slim
ARG TARGETARCH
ARG CODEMETER_VERSION=8.40.7120.501
ARG CM_IMAGE_VERSION=1.2.1

LABEL `
    org.opencontainers.image.url="https://github.com/wibu-systems/docker-codemeter" `
    org.opencontainers.image.documentation="https://github.com/wibu-systems/docker-codemeter" `
    org.opencontainers.image.source="https://github.com/wibu-systems/docker-codemeter" `    
    org.opencontainers.image.authors="info@wibu.com"`    
    org.opencontainers.image.version=${CODEMETER_VERSION}`
    org.opencontainers.image.vendor="WIBU-SYSTEMS AG"`
    org.opencontainers.image.title="CodeMeter RunTime Base Image"`
    org.opencontainers.image.description="Contains all required components to use CodeMeter RunTime within a Dockerized environment"`
    com.wibu.version=${CODEMETER_VERSION}`
    com.wibu.image.version=${CM_IMAGE_VERSION}`
    com.wibu.opensource.path="/usr/share/doc/CodeMeter/OpenSource_en.pdf"

ENV DEBIAN_FRONTEND=noninteractive `
    LANG='en_US.UTF-8' `
    LANGUAGE='en_US:en' `
    LC_ALL='en_US.UTF-8'

# CodeMeter's default Communication port
EXPOSE 22350

# For CmWAN Communication this port is used
EXPOSE 22351

COPY --from=prepare /codemeter/usr/bin/codemeter-info /usr/bin/codemeter-info
COPY --from=prepare /codemeter/usr/bin/cmu /usr/bin/cmu
COPY --from=prepare /codemeter/usr/sbin/CodeMeterLin /usr/sbin/CodeMeterLin
COPY --from=prepare /codemeter/usr/lib/*-linux-gnu/libwibucm.so /usr/lib/libwibucm.so
COPY --from=prepare /codemeter/usr/share/doc/CodeMeter/OpenSource_en.pdf /usr/share/doc/CodeMeter/OpenSource_en.pdf
COPY --from=prepare /codemeter/usr/lib/*-linux-gnu/libcpsrtcm.so /usr/lib/libcpsrtcm.so

# declare volume first
VOLUME [ "/etc/wibu/CodeMeter" ]

ADD --chmod=755 entrypoint.sh /entrypoint.sh
ADD --chmod=755 healthcheck.sh /healthcheck.sh
ADD Server.ini /etc/wibu/CodeMeter/Server.ini

RUN apt update ; `
    apt install -y locales ; `
    rm -rf /var/lib/apt/lists/* ; `
    # since we don't have the installer this needs to be created manually
    mkdir -p /var/lib/CodeMeter/CmAct; `
    mkdir -p /var/lib/CodeMeter/CmCloud ; `
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8


# Ensure a safe shutdown of the CodeMeter Service
STOPSIGNAL SIGINT

HEALTHCHECK --start-period=8s --interval=1m --start-interval=2s CMD /healthcheck.sh

ENTRYPOINT [ "/entrypoint.sh" ]
