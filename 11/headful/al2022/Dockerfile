FROM amazonlinux:2022

ARG version=11.0.17.8-1
RUN set -eux \
    && yum install -y https://corretto.aws/downloads/resources/$(echo $version | tr '-' '.')/java-11-amazon-corretto-headless-$version.amzn2022.$(uname -m).rpm https://corretto.aws/downloads/resources/$(echo $version | tr '-' '.')/java-11-amazon-corretto-$version.amzn2022.$(uname -m).rpm \
    && rm -rf /usr/lib/jvm/java-11-amazon-corretto.$(uname -m)/lib/src.zip \
    && yum clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
