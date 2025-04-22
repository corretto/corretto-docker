#!/bin/bash
set -xe
SED="sed -i"

sed --version 2>/dev/null || SED="sed -i.bkp"

usage() {
    echo "usage: update-dockerfiles.sh [--help]"
    echo ""
    echo "Update the dockerfiles to use the version from versions.json"
}

verify_update() {
    MAJOR_RELEASE=$1
    VERSION_STRING=$2
    pushd ${MAJOR_RELEASE}
    DOCKERFILE_COUNT=$(find ./ -name Dockerfile |wc -l)
    UPDATED_DOCKERFILE_COUNT=$(grep -rlE "${VERSION_STRING}" --include Dockerfile |wc -l)

    echo "Updated ${UPDATED_DOCKERFILE_COUNT} files for Corretto-${MAJOR_RELEASE}"
    if [[ ${DOCKERFILE_COUNT} == ${UPDATED_DOCKERFILE_COUNT} ]]; then
        echo "All files updated"
    else
        echo "Error: ${DOCKERFILE_COUNT} updated were expected!"
        exit 1
    fi
    popd
}

update_musl_linux() {
    CORRETTO_VERSION=$1
    MAJOR_RELEASE=$2

    if [ -d "./${MAJOR_RELEASE}/slim" ]; then
        ${SED} "s/ARG version=.*/ARG version=${CORRETTO_VERSION}/g" ./${MAJOR_RELEASE}/slim/alpine/Dockerfile
    fi
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

    ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/debian/Dockerfile

    if [ -d "./${MAJOR_RELEASE}/slim" ]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/slim/debian/Dockerfile
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}.${corretto_version}/g" ./${MAJOR_RELEASE}/slim/alpine/Dockerfile
    fi
}

update_amazon_linux() {
    CORRETTO_VERSION=$1
    MAJOR_RELEASE=$2

    jdk_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f1-3)
    jdk_build=$(echo ${CORRETTO_VERSION} | cut -d'.' -f4)
    corretto_version=$(echo ${CORRETTO_VERSION} | cut -d'.' -f5)
    if [[ -f ./${MAJOR_RELEASE}/jdk/al2023/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/jdk/al2023/Dockerfile
    fi
    if [[ -f ./${MAJOR_RELEASE}/headful/al2023/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/headful/al2023/Dockerfile
    fi
    if [[ -f ./${MAJOR_RELEASE}/headless/al2023/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/headless/al2023/Dockerfile
    fi

    ADDITIONAL_IMAGES="jdk jre headful headless"
    for IMAGE_TYPE in ${ADDITIONAL_IMAGES}; do
        echo "Checking $IMAGE_TYPE"
        if [ -d ./${MAJOR_RELEASE}/${IMAGE_TYPE}/al2 ]; then
            echo "Updating"

            ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/${IMAGE_TYPE}/al2/Dockerfile
        fi
    done

    if [[ -f ./${MAJOR_RELEASE}/slim/al2/Dockerfile ]]; then
        ${SED} "s/ARG version=.*/ARG version=${jdk_version}.${jdk_build}-${corretto_version}/g" ./${MAJOR_RELEASE}/slim/al2/Dockerfile
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

VERSIONS=$(jq -r 'keys |@sh' versions.json|tr -d \')
PLATFORMS=("GENERIC_LINUX" "ALPINE" "AMAZON_LINUX")
for version in ${VERSIONS}; do
    # If the version entry is just a string then populate all of the PLATFORMS with that value
    if [[ "$(cat versions.json |jq -r ".[\"${version}\"]|type")" == "string" ]]; then
        for platform in "${PLATFORMS[@]}"; do
            eval CORRETTO_${version}_${platform}="$(cat versions.json |jq -r ".[\"${version}\"]")"
        done
    else
        # If the version entry is not a string then it must be and map containing all of the PLATFORMS
        for platform in "${PLATFORMS[@]}"; do
            eval CORRETTO_${version}_${platform}="$(cat versions.json |jq -r ".[\"${version}\"][\"${platform}\"]")"
        done
    fi
done


if [ ! -z "${CORRETTO_11_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_11_GENERIC_LINUX} 11
    update_amazon_linux ${CORRETTO_11_AMAZON_LINUX} 11
    update_musl_linux ${CORRETTO_11_ALPINE} 11
fi

if [ ! -z "${CORRETTO_17_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_17_GENERIC_LINUX} 17
    update_amazon_linux ${CORRETTO_17_AMAZON_LINUX} 17
    update_musl_linux ${CORRETTO_17_ALPINE} 17
fi

if [ ! -z "${CORRETTO_21_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_21_GENERIC_LINUX} 21
    update_amazon_linux ${CORRETTO_21_AMAZON_LINUX} 21
    update_musl_linux ${CORRETTO_21_ALPINE} 21
fi

if [ ! -z "${CORRETTO_24_GENERIC_LINUX}" ]; then
    update_generic_linux ${CORRETTO_24_GENERIC_LINUX} 24
    update_amazon_linux ${CORRETTO_24_AMAZON_LINUX} 24
    update_musl_linux ${CORRETTO_24_ALPINE} 24
fi

if [ ! -z "${CORRETTO_8_GENERIC_LINUX}" ]; then
    jdk_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f2)
    jdk_build=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f3)
    corretto_version=$(echo ${CORRETTO_8_GENERIC_LINUX} | cut -d'.' -f4)
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2-generic/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=8.${jdk_version}.${jdk_build}-${corretto_version}/g" ./8/jdk/debian/Dockerfile
fi

if [ ! -z "${CORRETTO_8_AMAZON_LINUX}" ]; then
    jdk_version=$(echo ${CORRETTO_8_AMAZON_LINUX} | cut -d'.' -f2)
    jdk_build=$(echo ${CORRETTO_8_AMAZON_LINUX} | cut -d'.' -f3)
    corretto_version=$(echo ${CORRETTO_8_AMAZON_LINUX} | cut -d'.' -f4)

    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jre/al2/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jre/al2023/Dockerfile
    ${SED} "s/ARG version=.*/ARG version=1.8.0_${jdk_version}.b${jdk_build}-${corretto_version}/g" ./8/jdk/al2023/Dockerfile
fi

find . -name "*.bkp" | xargs rm -rf

python3 bin/apply-template.py

# 8 is special and doesn't have a consistent version string, so we just use the update version.
verify_update 8 ${jdk_version}
verify_update 11 "${CORRETTO_11_GENERIC_LINUX}|${CORRETTO_11_AMAZON_LINUX}|${CORRETTO_11_ALPINE}"
verify_update 17 "${CORRETTO_17_GENERIC_LINUX}|${CORRETTO_17_AMAZON_LINUX}|${CORRETTO_17_ALPINE}"
verify_update 21 "${CORRETTO_21_GENERIC_LINUX}|${CORRETTO_21_AMAZON_LINUX}|${CORRETTO_21_ALPINE}"
verify_update 24 "${CORRETTO_24_GENERIC_LINUX}|${CORRETTO_24_AMAZON_LINUX}|${CORRETTO_24_ALPINE}"
