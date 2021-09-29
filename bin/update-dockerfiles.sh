#!/bin/bash

usage() {
    echo "usage: update-dockerfiles.sh [--help]"
    echo ""
    echo "Update the dockerfiles to use the version from versions.json"
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
    if [ -d "./${MAJOR_RELEASE}/slim" ]; then
        sed -i "" "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/slim/alpine/Dockerfile
    fi
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
    if [ -d "./${MAJOR_RELEASE}/slim" ]; then
        sed -i "" "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/slim/al2/Dockerfile
        sed -i "" "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/slim/debian/Dockerfile
        sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*-slim,/${jdk_version},/g" .tags
        sed -i "" "s/${MAJOR_RELEASE}\.0\.[0-9]*-slim,/${jdk_version},/g" README.md
    fi

}

while [ "$1" != "" ]; do
    case $1 in
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

CORRETTO_8_GENERIC_LINUX=$(cat versions.json | jq -r '.["8"]' )
CORRETTO_11_GENERIC_LINUX=$(cat versions.json | jq -r '.["11"]' )
CORRETTO_16_GENERIC_LINUX=$(cat versions.json | jq -r '.["16"]' )
CORRETTO_17_GENERIC_LINUX=$(cat versions.json | jq -r '.["17"]' )


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

python3 bin/apply-template.py
