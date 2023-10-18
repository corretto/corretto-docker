FROM amazonlinux:2

ARG version=1.8.0_392.b08-1


RUN set -eux \
    && export resouce_version=$(echo $version | tr '-' '.' | tr '_' '.'| tr -d "b" | awk -F. '{print $2"."$4"."$5"."$6}') \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-amazon-linux-2 \
    && echo "localpkg_gpgcheck=1" >> /etc/yum.conf \
    && CORRETO_TEMP=$(mktemp -d) \
    && pushd ${CORRETO_TEMP} \
    && RPM_LIST=("java-1.8.0-amazon-corretto-$version.amzn2.$(uname -m).rpm" "java-1.8.0-amazon-corretto-devel-$version.amzn2.$(uname -m).rpm") \
    && for rpm in ${RPM_LIST[@]}; do \
    curl --fail -O https://corretto.aws/downloads/resources/${resouce_version}/${rpm} \
    && rpm -K "${CORRETO_TEMP}/${rpm}" | grep -F "${CORRETO_TEMP}/${rpm}: rsa sha1 (md5) pgp md5 OK" || exit 1 \
    && yum install -y $(yum deplist "${CORRETO_TEMP}/${rpm}" |grep provider | grep -v log4j-cve | tr -s ' ' |cut -d ' ' -f 3 ); \
    done \
    && rpm -i --nodeps ${CORRETO_TEMP}/*.rpm \
    && popd \
    && (find /usr/lib/jvm/java-1.8.0-amazon-corretto.$(uname -m) -name "*src.zip" -delete || true) \
    && rm -rf ${CORRETO_TEMP} \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && sed -i '/localpkg_gpgcheck=1/d' /etc/yum.conf

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
