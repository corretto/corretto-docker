#!/bin/bash
################################################################################
# Usage: ./bin/update-dockerfiles.sh <spaced version strings (optional)>
# Ex: ./bin/update-dockerfiles.sh 8.382.05.1 11.0.20.8.1 17.0.8.7.1 21.0.2.9.1
#
# Note: if args are passed in, the script will auto update versions.json
#       otherwise, versions.json isn't changed and used as source of truth
################################################################################
set -xeou pipefail

SED="sed -i"
sed --version 2>/dev/null || SED="sed -i.bkp"

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

WARNING_MSG=""
cp versions.json tmp.json
for version_input in "$@"; do
    major_version="${version_input%%.*}"
    # if the entry isn't a simple string, skip the automatic version.json update
    if [[ $(jq -r ".\"${major_version}\"|type" versions.json) != "string" ]]; then
        WARNING_MSG="true"
        break
    fi
    jq -r ".\"${major_version}\" = \"${version_input}\"" tmp.json > tmp-new.json
    mv tmp-new.json tmp.json
done
if [[ -z "${WARNING_MSG}" ]]; then
    mv tmp.json versions.json
else
    rm tmp.json
fi

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
    if [[ "${version}" != "8" ]]; then
        generic_var="CORRETTO_${version}_GENERIC_LINUX"
        al_var="CORRETTO_${version}_AMAZON_LINUX"
        update_generic_linux "${!generic_var}" "${version}"
        update_amazon_linux "${!al_var}" "${version}"
    fi
done

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
for version in ${VERSIONS}; do
    if [[ "${version}" == "8" ]]; then
        continue
    fi
    generic_var="CORRETTO_${version}_GENERIC_LINUX"
    al_var="CORRETTO_${version}_AMAZON_LINUX"
    alpine_var="CORRETTO_${version}_ALPINE"
    verify_update "${version}" "${!generic_var}|${!al_var}|${!alpine_var}"
done

if [[ -n "${WARNING_MSG}" ]]; then
    set +x
    echo "################################################################################"
    echo "WARNING: version.json WAS NOT AUTOMATICALLY UPDATED!!"
    echo "         PLEASE MANUALLY VERIFY/UPDATE IT FOR CORRECTNESS"
    echo "################################################################################"
    set -x
fi
