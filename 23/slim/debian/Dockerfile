FROM debian:bookworm-slim

ARG version=23.0.1.8-1
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
        curl ca-certificates fontconfig \
    && curl -fLo /etc/apt/keyrings/corretto.asc https://apt.corretto.aws/corretto.key \
    && echo "deb [signed-by=/etc/apt/keyrings/corretto.asc] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
    && apt-get update \
    && apt-get install -y java-23-amazon-corretto-jdk=1:$version binutils \
    && jlink --add-modules "$(java --list-modules | sed -e 's/@[0-9].*$/,/' | tr -d \\n)" --no-man-pages --no-header-files --strip-debug --output /opt/corretto-slim \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
            curl binutils java-23-amazon-corretto-jdk=1:$version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/lib/jvm \
    && mv /opt/corretto-slim /usr/lib/jvm/java-23-amazon-corretto \
    && jdk_tools="java keytool rmid rmiregistry javac jaotc jlink jmod jhsdb jar jarsigner javadoc javap jcmd jconsole jdb jdeps jdeprscan jimage jinfo jmap jps jrunscript jshell jstack jstat jstatd serialver" \
    && priority=$(echo "1${version}" | sed "s/\(\.\|-\)//g") \
    && for i in ${jdk_tools}; do \
          update-alternatives --install /usr/bin/$i $i /usr/lib/jvm/java-23-amazon-corretto/bin/$i ${priority}; \
       done


ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-23-amazon-corretto
