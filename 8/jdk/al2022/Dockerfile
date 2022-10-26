FROM amazonlinux:2022

ARG version=1.8.0_352.b08-1

RUN set -eux \
    && export resouce_version=$(echo $version | tr '-' '.' | tr '_' '.'| tr -d "b" | awk -F. '{print $2"."$3"."$4"."$5"."$6}') \
    && yum install -y https://corretto.aws/downloads/resources/${resouce_version}/java-1.8.0-amazon-corretto-$version.amzn2022.$(uname -m).rpm https://corretto.aws/downloads/resources/${resouce_version}/java-1.8.0-amazon-corretto-devel-$version.amzn2022.$(uname -m).rpm \
    && rm -rf /usr/lib/jvm/java-1.8.0-amazon-corretto.$(uname -m)/lib/src.zip \
    && yum clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
