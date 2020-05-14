FROM alpine:latest

RUN wget -c -O amazon-corretto-8-jre-8.252.09.1-r0.apk https://d3pxv6yz143wms.cloudfront.net/ea/8.252.09.1/amazon-corretto-8-jre-8.252.09.1-r0.apk && \
    wget -c -O amazon-corretto-8-8.252.09.1-r0.apk https://d3pxv6yz143wms.cloudfront.net/ea/8.252.09.1/amazon-corretto-8-8.252.09.1-r0.apk && \
    wget -c -O /etc/apk/keys/amazoncorretto.rsa.pub https://d3pxv6yz143wms.cloudfront.net/ea/8.252.09.1/amazoncorretto.rsa.pub && \
    apk add amazon-corretto-8-jre-8.252.09.1-r0.apk && \
    apk add amazon-corretto-8-8.252.09.1-r0.apk && \
    rm -rf amazon-corretto-8-jre-8.252.09.1-r0.apk && \
    rm -rf amazon-corretto-8-8.252.09.1-r0.apk

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$PATH:/usr/lib/jvm/default-jvm/bin
    
    