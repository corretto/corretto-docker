FROM amazonlinux:2022

ARG version=17.0.5.8-1
ARG packag_version=1

RUN set -eux \
    && yum install -y https://corretto.aws/downloads/resources/$(echo $version | tr '-' '.')/java-17-amazon-corretto-headless-$version.amzn2022.${packag_version}.$(uname -m).rpm https://corretto.aws/downloads/resources/$(echo $version | tr '-' '.')/java-17-amazon-corretto-$version.amzn2022.${packag_version}.$(uname -m).rpm https://corretto.aws/downloads/resources/$(echo $version | tr '-' '.')/java-17-amazon-corretto-devel-$version.amzn2022.${packag_version}.$(uname -m).rpm\
    && rm -rf /usr/lib/jvm/java-17-amazon-corretto.$(uname -m)/lib/src.zip \
    && yum clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
