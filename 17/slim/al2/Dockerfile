FROM amazonlinux:2

ARG version=17.0.3.6-1
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
    && echo "priority=9" >> /etc/yum.repos.d/corretto.repo \
    && yum install -y java-17-amazon-corretto-devel-$version \
    && (find /usr/lib/jvm/java-17-amazon-corretto -name src.zip -delete || true) \
    && yum install -y fontconfig \
    && yum install -y binutils \
    && jlink --add-modules "$(java --list-modules | sed -e 's/@[0-9].*$/,/' | tr -d \\n)" --no-man-pages --no-header-files --strip-debug --output /opt/corretto-slim \
    && yum remove -y binutils java-17-amazon-corretto-devel-$version \
    && mkdir -p /usr/lib/jvm/ \
    && mv /opt/corretto-slim /usr/lib/jvm/java-17-amazon-corretto \
    && alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-amazon-corretto/bin/java $(echo "1${version}" | sed "s/\(\.\|-\)//g") \
                  --slave /usr/bin/keytool keytool /usr/lib/jvm/java-17-amazon-corretto/bin/keytool \
                  --slave /usr/bin/rmid rmid /usr/lib/jvm/java-17-amazon-corretto/bin/rmid \
                  --slave /usr/bin/rmiregistry rmiregistry /usr/lib/jvm/java-17-amazon-corretto/bin/rmiregistry \
    && alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-amazon-corretto/bin/javac $(echo "1${version}" | sed "s/\(\.\|-\)//g") \
                 --slave /usr/bin/jaotc jaotc /usr/lib/jvm/java-17-amazon-corretto/bin/jaotc \
                 --slave /usr/bin/jlink jlink /usr/lib/jvm/java-17-amazon-corretto/bin/jlink \
                 --slave /usr/bin/jmod jmod /usr/lib/jvm/java-17-amazon-corretto/bin/jmod \
                 --slave /usr/bin/jhsdb jhsdb /usr/lib/jvm/java-17-amazon-corretto/bin/jhsdb \
                 --slave /usr/bin/jar jar /usr/lib/jvm/java-17-amazon-corretto/bin/jar \
                 --slave /usr/bin/jarsigner jarsigner /usr/lib/jvm/java-17-amazon-corretto/bin/jarsigner \
                 --slave /usr/bin/javadoc javadoc /usr/lib/jvm/java-17-amazon-corretto/bin/javadoc \
                 --slave /usr/bin/javap javap /usr/lib/jvm/java-17-amazon-corretto/bin/javap \
                 --slave /usr/bin/jcmd jcmd /usr/lib/jvm/java-17-amazon-corretto/bin/jcmd \
                 --slave /usr/bin/jconsole jconsole /usr/lib/jvm/java-17-amazon-corretto/bin/jconsole \
                 --slave /usr/bin/jdb jdb /usr/lib/jvm/java-17-amazon-corretto/bin/jdb \
                 --slave /usr/bin/jdeps jdeps /usr/lib/jvm/java-17-amazon-corretto/bin/jdeps \
                 --slave /usr/bin/jdeprscan jdeprscan /usr/lib/jvm/java-17-amazon-corretto/bin/jdeprscan \
                 --slave /usr/bin/jimage jimage /usr/lib/jvm/java-17-amazon-corretto/bin/jimage \
                 --slave /usr/bin/jinfo jinfo /usr/lib/jvm/java-17-amazon-corretto/bin/jinfo \
                 --slave /usr/bin/jmap jmap /usr/lib/jvm/java-17-amazon-corretto/bin/jmap \
                 --slave /usr/bin/jps jps /usr/lib/jvm/java-17-amazon-corretto/bin/jps \
                 --slave /usr/bin/jrunscript jrunscript /usr/lib/jvm/java-17-amazon-corretto/bin/jrunscript \
                 --slave /usr/bin/jshell jshell /usr/lib/jvm/java-17-amazon-corretto/bin/jshell \
                 --slave /usr/bin/jstack jstack /usr/lib/jvm/java-17-amazon-corretto/bin/jstack \
                 --slave /usr/bin/jstat jstat /usr/lib/jvm/java-17-amazon-corretto/bin/jstat \
                 --slave /usr/bin/jstatd jstatd /usr/lib/jvm/java-17-amazon-corretto/bin/jstatd \
    && yum clean all

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
