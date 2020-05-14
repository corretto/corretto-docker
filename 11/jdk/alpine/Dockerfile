FROM alpine:latest

RUN wget -c -O amazon-corretto-11-11.0.7.10.1-r0.apk  https://d3pxv6yz143wms.cloudfront.net/ea/11.0.7.10.1/amazon-corretto-11-11.0.7.10.1-r0.apk && \
    wget -c -O /etc/apk/keys/amazoncorretto.rsa.pub https://d3pxv6yz143wms.cloudfront.net/ea/11.0.7.10.1/amazoncorretto.rsa.pub && \
    apk add amazon-corretto-11-11.0.7.10.1-r0.apk && \
    rm -rf amazon-corretto-11-11.0.7.10.1-r0.apk

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$PATH:/usr/lib/jvm/default-jvm/bin