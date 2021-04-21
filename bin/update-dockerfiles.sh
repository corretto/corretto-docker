#!/bin/bash

usage() {
    echo "usage: update-dockerfiles.sh [--help] [--corretto-8-generic-linux <version>] [--corretto-8-musl-linux <version>]"
    echo "                             [--corretto-11-generic-linux <version>] [--corretto-11-musl-linux <version>]"
    echo "                             [--corretto-16-generic-linux <version>] [--corretto-16-musl-linux <version>]"
    echo "                             [--corretto-16-alpine-linux <version>] [--corretto-11-alpine-linux <version>]"
    echo "                             [--corretto-8-alpine-linux <version>]"
    echo ""
    echo "Update the dockerfiles to use the version specified above."
}

update_musl_linux() {
    CORRETTO_VERSION=$1
    MAJOR_RELEASE=$2

    sed -i "" "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/jdk/alpine/Dockerfile
    if [ -f ./${MAJOR_RELEASE}/jre/alpine/Dockerfile ]; then
        sed -i "" "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/jre/alpine/Dockerfile
    fi
    jdk_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f1-3)
    sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*-alpine/${jdk_version}-alpine/g" .tags

    sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*-alpine/${jdk_version}-alpine/g" README.md
}

update_generic_linux() {
    CORRETTO_VERSION=$1
    MAJOR_RELEASE=$2

    jdk_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f1-3)
    jdk_build=$(echo ${CORRETTO_VERSION} | cut -d'.' -f4)
    corretto_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f5)
    sed -i "" "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/al2/Dockerfile
    sed -i "" "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/debian/Dockerfile
    sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*,/${jdk_version},/g" .tags
    sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*-al2/${jdk_version}-al2/g" .tags

    sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*,/${jdk_version},/g" README.md
    sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*-al2/${jdk_version}-al2/g" README.md

}

update_alpine_linux() {
    ALPINE_VERSION=$1
    MAJOR_RELEASE=$2

    sed -i "" "s/FROM alpine:.*/FROM alpine:${ALPINE_VERSION}/g" ./${MAJOR_RELEASE}/jdk/alpine/Dockerfile
    if [ -f ./${MAJOR_RELEASE}/jre/alpine/Dockerfile ]; then
        sed -i "" "s/FROM alpine:.*/FROM alpine:${ALPINE_VERSION}/g" ./${MAJOR_RELEASE}/jre/alpine/Dockerfile
    fi
}

while [ "$1" != "" ]; do
    case $1 in
        --corretto-8-generic-linux )
            shift
            CORRETTO_8_GENERIC_LINUX=$1
            ;;
        --corretto-11-generic-linux )
            shift
            CORRETTO_11_GENERIC_LINUX=$1
            ;;
        --corretto-8-musl-linux )
            shift
            CORRETTO_8_MUSL_LINUX=$1
            ;;
        --corretto-11-musl-linux )
            shift
            CORRETTO_11_MUSL_LINUX=$1
            ;;
        --corretto-16-musl-linux )
            shift
            CORRETTO_16_MUSL_LINUX=$1
            ;;
        --corretto-16-generic-linux )
            shift
            CORRETTO_16_GENERIC_LINUX=$1
            ;;
        --corretto-8-alpine-linux )
            shift
            CORRETTO_8_ALPINE_LINUX=$1
            ;;
        --corretto-11-alpine-linux )
            shift
            CORRETTO_11_ALPINE_LINUX=$1
            ;;
        --corretto-16-alpine-linux )
            shift
            CORRETTO_16_ALPINE_LINUX=$1
            ;;
        --help )
            usage
            exit
            ;;
        * )
            usage
            exit 1

    esac
    shift
done

if [ ! -z "${CORRETTO_8_ALPINE_LINUX}" ]; then
    update_alpine_linux ${CORRETTO_8_ALPINE_LINUX} 8
fi

if [ ! -z "${CORRETTO_11_ALPINE_LINUX}" ]; then
    update_alpine_linux ${CORRETTO_11_ALPINE_LINUX} 11
fi

if [ ! -z "${CORRETTO_16_ALPINE_LINUX}" ]; then
    update_alpine_linux ${CORRETTO_16_ALPINE_LINUX} 16
fi

if [ ! -z "${CORRETTO_11_MUSL_LINUX}" ]; then
    update_musl_linux ${CORRETTO_11_MUSL_LINUX} 11
fi

if [ ! -z "${CORRETTO_16_MUSL_LINUX}" ]; then
    update_musl_linux ${CORRETTO_16_MUSL_LINUX} 16
fi

if [ ! -z "${CORRETTO_8_MUSL_LINUX}" ]; then
    sed -i "" "s/^ARG version=.*/ARG version=${CORRETTO_8_MUSL_LINUX}/g" ./8/jdk/alpine/Dockerfile
    sed -i "" "s/^ARG version=.*/ARG version=${CORRETTO_8_MUSL_LINUX}/g" ./8/jre/alpine/Dockerfile
    jdk_version=$(echo ${CORRETTO_8_MUSL_LINUX} | cut -d'.' -f2)
    sed -i "" "s/8u[0-9]*-alpine/8u${jdk_version}-alpine/g" .tags

    sed -i "" "s/8u[0-9]*-alpine/8u${jdk_version}-alpine/g" README.md
fi


if [ ! -z "${CORRETTO_11_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_11_GENERIC_LINUX} 11
fi

if [ ! -z "${CORRETTO_16_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_16_GENERIC_LINUX} 16
fi

if [ ! -z "${CORRETTO_8_GENERIC_LINUX}" ]; then
    jdk_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f2)
    jdk_build=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f3)
    corretto_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f4)
    sed -i "" "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2/Dockerfile
    sed -i "" "s/ARG version=.*/ARG version=8.${jdk_version}.${jdk_build}-${corretto_version}/g" ./8/jdk/debian/Dockerfile
    sed -i "" "s/8u[0-9]*,/8u${jdk_version},/g" .tags
    sed -i "" "s/8u[0-9]*-al2/8u${jdk_version}-al2/g" .tags

    sed -i "" "s/8u[0-9]*,/8u${jdk_version},/g" README.md
    sed -i "" "s/8u[0-9]*-al2/8u${jdk_version}-al2/g" README.md
fi
