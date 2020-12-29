FROM amazonlinux:2

ARG version=15.0.1.9-1
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
#
# Slim:
#   JLink is used (retaining all modules) to create a slimmer version of the JDK excluding man-pages, header files and debugging symbols - saving ~113MB.
RUN set -eux \
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fL -o corretto.key https://yum.corretto.aws/corretto.key \
    && gpg --batch --import corretto.key \
    && gpg --batch --export --armor '6DC3636DAE534049C8B94623A122542AB04F24E3' > corretto.key \
    && rpm --import corretto.key \
    && rm -r "$GNUPGHOME" corretto.key \
    && curl -fL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo \
    && grep -q '^gpgcheck=1' /etc/yum.repos.d/corretto.repo \
    && yum install -y java-15-amazon-corretto-devel-$version \
    && (find /usr/lib/jvm/java-15-amazon-corretto -name src.zip -delete || true) \
    && yum install -y fontconfig \
    && yum install -y binutils \
    && for line in $(java --list-modules); do echo -n "${line/@15/,}" >> modules-comma-separated.txt; done \
    && jlink --add-modules "$(< modules-comma-separated.txt)" --no-man-pages --no-header-files --strip-debug --output /opt/corretto-slim \
    && rm -rf /usr/lib/jvm/java-15-amazon-corretto \
    && mv /opt/corretto-slim /usr/lib/jvm/java-15-amazon-corretto \
    && yum clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-15-amazon-corretto
