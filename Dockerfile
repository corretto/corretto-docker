FROM amazonlinux:2

ARG rpm=java-11-amazon-corretto-devel-11.0.2.9-2.x86_64.rpm
ARG host=https://d2jnoze5tfhthg.cloudfront.net

COPY 7E2223C5.pub .

# In addition to installing the RPM, we also install
# fontconfig. The folks who manage the docker hub's
# official image library have found that font management
# is a common usecase, and painpoint, and have
# recommended that Java images include font support.
#
# See:
#  https://github.com/docker-library/official-images/blob/master/test/tests/java-uimanager-font/container.java
RUN curl -O $host/$rpm \
    && rpm --import 7E2223C5.pub \
    && rpm -K $rpm \
    && rpm -i $rpm \
    && rm 7E2223C5.pub $rpm \
    && yum install -y fontconfig \
    && yum clean all

ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
