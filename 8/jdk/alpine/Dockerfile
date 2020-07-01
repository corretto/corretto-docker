FROM alpine:latest

ARG version=8.252.09.1

RUN wget -c -O amazon-corretto-8-jre-$version-r0.apk https://d3pxv6yz143wms.cloudfront.net/ea/$version/amazon-corretto-8-jre-$version-r0.apk && \
    wget -c -O amazon-corretto-8-$version-r0.apk https://d3pxv6yz143wms.cloudfront.net/ea/$version/amazon-corretto-8-$version-r0.apk && \
    wget -c -O /etc/apk/keys/amazoncorretto.rsa.pub https://d3pxv6yz143wms.cloudfront.net/ea/$version/amazoncorretto.rsa.pub && \
    apk add amazon-corretto-8-jre-$version-r0.apk && \
    apk add amazon-corretto-8-$version-r0.apk && \
    rm -rf amazon-corretto-8-jre-$version-r0.apk && \
    rm -rf amazon-corretto-8-$version-r0.apk

ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$PATH:/usr/lib/jvm/default-jvm/bin
    
    