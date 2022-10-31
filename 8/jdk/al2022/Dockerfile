FROM amazonlinux:2022

ARG version=1.8.0_352.b08-1


RUN set -eux \
    && export resouce_version=$(echo $version | tr '-' '.' | tr '_' '.'| tr -d "b" | awk -F. '{print $2"."$3"."$4"."$5"."$6}') \
    && rpm --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2022 \
    && echo "localpkg_gpgcheck=1" >> /etc/dnf/dnf.conf \
    && CORRETO_TEMP=$(mktemp -d) \
    && pushd ${CORRETO_TEMP} \
    && curl -O https://corretto.aws/downloads/resources/${resouce_version}/java-1.8.0-amazon-corretto-$version.amzn2022.$(uname -m).rpm -O https://corretto.aws/downloads/resources/${resouce_version}/java-1.8.0-amazon-corretto-devel-$version.amzn2022.$(uname -m).rpm \
    && VERIFIED_COUNT=$(rpm -K ${CORRETO_TEMP}/*.rpm | grep -c ": digests signatures OK$") \
    && [ 2 -eq ${VERIFIED_COUNT} ] \
    && dnf install -y ${CORRETO_TEMP}/*.rpm \
    && popd \
    && rm -rf /usr/lib/jvm/java-1.8.0-amazon-corretto.$(uname -m)/lib/src.zip \
    && rm -rf ${CORRETO_TEMP} \
    && dnf clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
