FROM amazonlinux:2022

ARG version=17.0.5.8-1
ARG package_version=1

RUN set -eux \
    && rpm --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2022 \
    && echo "localpkg_gpgcheck=1" >> /etc/dnf/dnf.conf \
    && CORRETO_TEMP=$(mktemp -d) \
    && pushd ${CORRETO_TEMP} \
    && curl -O https://corretto.aws/downloads/resources/$(echo $version | tr '-' '.')/java-17-amazon-corretto-headless-$version.amzn2022.${package_version}.$(uname -m).rpm \
    && VERIFIED_COUNT=$(rpm -K ${CORRETO_TEMP}/*.rpm | grep -c ": digests signatures OK$") \
    && [ 1 -eq ${VERIFIED_COUNT} ] \
    && dnf install -y ${CORRETO_TEMP}/*.rpm \
    && popd \
    && rm -rf /usr/lib/jvm/java-17-amazon-corretto.$(uname -m)/lib/src.zip \
    && rm -rf ${CORRETO_TEMP} \
    && dnf clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
