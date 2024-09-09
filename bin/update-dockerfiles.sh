#!/bin/bash
set -xe
SED="sed -i"

sed --version 2>/dev/null || SED="sed -i.bkp"

usage() {
    echo "usage: update-dockerfiles.sh [--help]"
    echo ""
    echo "Update the dockerfiles to use the version from versions.json"
}

update_musl_linux() {
    CORRETTO_VERSION=$1
    MAJOR_RELEASE=$2

    ${SED} "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/jdk/alpine/Dockerfile
    if [ -f ./${MAJOR_RELEASE}/jre/alpine/Dockerfile ]; then
        ${SED} "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/jre/alpine/Dockerfile
    fi
    jdk_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f1-3)

    ${SED} "s/${MAJOR_RELEASE}\.0\.[0-9]*-alpine/${jdk_version}-alpine/g" README.md
    if [ -d "./${MAJOR_RELEASE}/slim" ]; then
        ${SED} "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/slim/alpine/Dockerfile
    fi
}

verify_update() {
    MAJOR_RELEASE=$1
    VERSION_STRING=$2
    pushd ${MAJOR_RELEASE}
    DOCKERFILE_COUNT=$(find ./ -name Dockerfile |wc -l)
    UPDATED_DOCKERFILE_COUNT=$(grep -rl "${VERSION_STRING}" --include Dockerfile |wc -l)

    echo "Updated ${UPDATED_DOCKERFILE_COUNT} files for Corretto-${MAJOR_RELEASE}"
    if [[ ${DOCKERFILE_COUNT} == ${UPDATED_DOCKERFILE_COUNT} ]]; then
        echo "All files updated"
    else
        echo "Error: ${DOCKERFILE_COUNT} updated were expected!"
        exit 1
    fi
    popd
}

update_generic_linux() {
    CORRETTO_VERSION=$1
    MAJOR_RELEASE=$2

    jdk_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f1-3)
    jdk_build=$(echo ${CORRETTO_VERSION} | cut -d'.' -f4)
    corretto_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f5)
    if [[ -f ./${MAJOR_RELEASE}/jdk/al2-generic/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/al2-generic/Dockerfile
    fi
    if [[ -f ./${MAJOR_RELEASE}/jdk/al2023/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/al2023/Dockerfile
    fi
    if [[ -f ./${MAJOR_RELEASE}/headful/al2023/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/headful/al2023/Dockerfile
    fi
    if [[ -f ./${MAJOR_RELEASE}/headless/al2023/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/headless/al2023/Dockerfile
    fi


    ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/debian/Dockerfile

    ADDITIONAL_IMAGES="jdk jre headful headless"
    for IMAGE_TYPE in ${ADDITIONAL_IMAGES}; do
        echo "Checking $IMAGE_TYPE"
        if [ -d ./${MAJOR_RELEASE}/${IMAGE_TYPE}/al2 ]; then
            echo "Updating"

            ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/${IMAGE_TYPE}/al2/Dockerfile
        fi
    done

    ${SED} "s/${MAJOR_RELEASE}\.0\.[0-9]*,/${jdk_version},/g" README.md
    ${SED} "s/${MAJOR_RELEASE}\.0\.[0-9]*-al2/${jdk_version}-al2/g" README.md
    if [[ -f ./${MAJOR_RELEASE}/slim/al2/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/slim/al2/Dockerfile
    fi
    if [ -d "./${MAJOR_RELEASE}/slim" ]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/slim/debian/Dockerfile
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}.${corretto_version}/g" ./${MAJOR_RELEASE}/slim/alpine/Dockerfile
        ${SED} "s/${MAJOR_RELEASE}\.0\.[0-9]*-slim,/${jdk_version},/g" README.md
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
CORRETTO_17_GENERIC_LINUX=$(cat versions.json | jq -r '.["17"]' )
CORRETTO_21_GENERIC_LINUX=$(cat versions.json | jq -r '.["21"]' )
CORRETTO_22_GENERIC_LINUX=$(cat versions.json | jq -r '.["22"]' )
CORRETTO_23_GENERIC_LINUX=$(cat versions.json | jq -r '.["23"]' )

if [ ! -z "${CORRETTO_11_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_11_GENERIC_LINUX} 11
fi

if [ ! -z "${CORRETTO_17_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_17_GENERIC_LINUX} 17
fi

if [ ! -z "${CORRETTO_21_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_21_GENERIC_LINUX} 21
fi

if [ ! -z "${CORRETTO_22_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_22_GENERIC_LINUX} 22
fi

if [ ! -z "${CORRETTO_23_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_23_GENERIC_LINUX} 23
fi

if [ ! -z "${CORRETTO_8_GENERIC_LINUX}" ]; then
    jdk_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f2)
    jdk_build=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f3)
    corretto_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f4)
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2-generic/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jre/al2/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jre/al2023/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2023/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=8.${jdk_version}.${jdk_build}-${corretto_version}/g" ./8/jdk/debian/Dockerfile


    ${SED} "s/8u[0-9]*,/8u${jdk_version},/g" README.md
    ${SED} "s/8u[0-9]*-al2/8u${jdk_version}-al2/g" README.md
fi

find . -name "*.bkp" | xargs rm -rf

python3 bin/apply-template.py

# 8 is special and doesn't have a consistent version string, so we just use the update version.
verify_update 8 ${jdk_version}
verify_update 11 ${CORRETTO_11_GENERIC_LINUX}
verify_update 17 ${CORRETTO_17_GENERIC_LINUX}
verify_update 21 ${CORRETTO_21_GENERIC_LINUX}
verify_update 22 ${CORRETTO_22_GENERIC_LINUX}
verify_update 23 ${CORRETTO_23_GENERIC_LINUX}
