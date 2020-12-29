FROM debian:buster-slim

ARG version=15.0.1.9-1
# In addition to installing the Amazon corretto, we also install
# fontconfig. The folks who manage the docker hub's
# official image library have found that font management
# is a common usecase, and painpoint, and have
# recommended that Java images include font support.
#
# See:
#  https://github.com/docker-library/official-images/blob/master/test/tests/java-uimanager-font/container.java
#
# Slim:
#   JLink is used (retaining all modules) to create a slimmer version of the JDK excluding man-pages, header files and debugging symbols - saving ~113MB.
RUN set -ux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg software-properties-common fontconfig \
    && curl -fL https://apt.corretto.aws/corretto.key | apt-key add - \
    && add-apt-repository 'deb https://apt.corretto.aws stable main' \
    && mkdir -p /usr/share/man/man1 \
    && apt-get update \
    && apt-get install -y java-15-amazon-corretto-jdk=1:$version binutils \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
            curl gnupg software-properties-common \
    && for line in $(java --list-modules); do echo -n "${line}," | sed -e 's/@15.*,/,/' >> modules-comma-separated.txt; done \
    && jlink --add-modules "$(cat modules-comma-separated.txt)" --no-man-pages --no-header-files --strip-debug --output /opt/corretto-slim \
    && rm -rf /usr/lib/jvm/java-15-amazon-corretto \
    && mv /opt/corretto-slim /usr/lib/jvm/java-15-amazon-corretto

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-15-amazon-corretto
