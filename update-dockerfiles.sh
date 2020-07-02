#!/bin/bash

usage() {
    echo "usage: update-dockerfiles.sh [--help] [--corretto-8-generic-linux <version>] [--corretto-11-generic-linux <version>]"
    echo "                             [--corretto-8-musl-linux <version>] [--corretto-11-musl-linux <version>]"
    echo ""
    echo "Update the dockerfiles to use the version specified above."
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

if [ ! -z "${CORRETTO_11_MUSL_LINUX}" ]; then
    sed -i "" "s/ARG version=.*/ARG version=${CORRETTO_11_MUSL_LINUX}/g" ./11/jdk/alpine/Dockerfile
    sed -i "" "s/ARG version=.*/ARG version=${CORRETTO_11_MUSL_LINUX}/g" ./11/jre/alpine/Dockerfile
    jdk_version=$(echo ${CORRETTO_11_MUSL_LINUX} | cut -d'.' -f1-3)
    sed -i "" "s/11\.0\.[0-9]*-alpine/${jdk_version}-alpine/g" .tags
fi

if [ ! -z "${CORRETTO_8_MUSL_LINUX}" ]; then
    sed -i "" "s/^ARG version=.*/ARG version=${CORRETTO_8_MUSL_LINUX}/g" ./8/jdk/alpine/Dockerfile
    sed -i "" "s/^ARG version=.*/ARG version=${CORRETTO_8_MUSL_LINUX}/g" ./8/jre/alpine/Dockerfile
    jdk_version=$(echo ${CORRETTO_8_MUSL_LINUX} | cut -d'.' -f2)
    sed -i "" "s/8u[0-9]*-alpine/8u${jdk_version}-alpine/g" .tags
fi


if [ ! -z "${CORRETTO_11_GENERIC_LINUX}" ]; then
    sed -i "" "s/ARG version=.*/ARG version=${CORRETTO_11_GENERIC_LINUX}/g" ./11/jdk/al2/Dockerfile
    jdk_version=$(echo ${CORRETTO_11_GENERIC_LINUX} | cut -d'.' -f1-3)
    sed -i "" "s/11\.0\.[0-9]*,/${jdk_version},/g" .tags
    sed -i "" "s/11\.0\.[0-9]*-al2/${jdk_version}-al2/g" .tags
fi

if [ ! -z "${CORRETTO_8_GENERIC_LINUX}" ]; then
    jdk_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f2)
    jdk_build=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f3)
    corretto_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f4)
    sed -i "" "s/ARG version=.*/ARG version=1.8.0_${jdk_version}-b${jdk_build}-${corretto_version}/g" ./8/jdk/al2/Dockerfile
    sed -i "" "s/8u[0-9]*,/8u${jdk_version},/g" .tags
    sed -i "" "s/8u[0-9]*-al2/8u${jdk_version}-al2/g" .tags
fi