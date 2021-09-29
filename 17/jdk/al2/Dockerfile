ARG BASE_IMAGE=public.ecr.aws/amazonlinux/amazonlinux:2
FROM $BASE_IMAGE as amazoncorretto

ARG version=17.0.0.35-1
# In addition to installing the Amazon corretto, we also install
# fontconfig. The folks who manage the docker hub's
# official image library have found that font management
# is a common usecase, and painpoint, and have
# recommended that Java images include font support.
#
# See:
#  https://github.com/docker-library/official-images/blob/master/test/tests/java-uimanager-font/container.java

# The logic and code related to Fingerprint is contributed by @tianon in a Github PR's Conversation
# Comment = https://github.com/docker-library/official-images/pull/7459#issuecomment-592242757
# PR = https://github.com/docker-library/official-images/pull/7459
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem /etc/ssl/certs/
RUN set -eux \
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fL -o corretto.key https://yum.corretto.aws/corretto.key \
    && gpg --batch --import corretto.key \
    && gpg --batch --export --armor '6DC3636DAE534049C8B94623A122542AB04F24E3' > corretto.key \
    && rpm --import corretto.key \
    && rm -r "$GNUPGHOME" corretto.key \
    && curl -fL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo \
    && grep -q '^gpgcheck=1' /etc/yum.repos.d/corretto.repo \
    && yum install -y java-17-amazon-corretto-devel-$version \
    && (find /usr/lib/jvm/java-17-amazon-corretto -name src.zip -delete || true) \
    && yum install -y fontconfig \
    && yum clean all \
    && keytool  -importcert -file /etc/ssl/certs/rds-combined-ca-bundle.pem \
       	        -keystore cacerts -storepass changeit -trustcacerts -noprompt || echo "FAILED to add RDS CA"

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
