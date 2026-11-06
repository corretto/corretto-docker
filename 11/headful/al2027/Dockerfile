FROM amazonlinux:2027

ARG version=11.0.33.0.10-1
ARG resource_version=11.0.33.0.10
RUN set -eux \
    && ARCH="$(rpm --query --queryformat='%{ARCH}' rpm)" \
    && rpm --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2027 \
    && echo "localpkg_gpgcheck=1" >> /etc/dnf/dnf.conf \
    && CORRETTO_TEMP=$(mktemp -d) \
    && pushd ${CORRETTO_TEMP} \
    && RPM_LIST=("java-11-amazon-corretto-headless-$version.amzn2027.${ARCH}.rpm" "java-11-amazon-corretto-$version.amzn2027.${ARCH}.rpm") \
    && for rpm in "${RPM_LIST[@]}"; do \
    curl --fail -O https://corretto.aws/downloads/resources/${resource_version}/${rpm} \
    && rpm -K "${CORRETTO_TEMP}/${rpm}" | grep -F "${CORRETTO_TEMP}/${rpm}: digests signatures OK" || exit 1; \
    done \
    && dnf install -y ${CORRETTO_TEMP}/*.rpm \
    && popd \
    && rm -rf /usr/lib/jvm/java-11-amazon-corretto.${ARCH}/lib/src.zip \
    && rm -rf ${CORRETTO_TEMP} \
    && dnf clean all \
    && sed -i '/localpkg_gpgcheck=1/d' /etc/dnf/dnf.conf

ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
