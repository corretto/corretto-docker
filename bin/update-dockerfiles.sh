#!/bin/bash
################################################################################
# Usage: ./bin/update-dockerfiles.sh <spaced version strings (optional)>
# Ex: ./bin/update-dockerfiles.sh 8.512.08.1 11.0.33.0.9 17.0.21.0.10
#
# Note: args update each release's canonical version for all platforms.
#       otherwise, versions.json isn't changed and used as source of truth
#       For platform-specific versions, edit versions.json and run without args.
#       CORRETTO_PACKAGE_RELEASE defaults to 1 for the new version format.
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

native_package_version() {
    local canonical=$1 major=$2 update first_new_update release
    update=$(echo "${canonical}" | cut -d'.' -f3)
    # First published updates using feature.interim.update.patch.build.
    # Older releases, including 26, retain build.package-release.
    case "${major}" in
        11) first_new_update=33 ;;
        17) first_new_update=21 ;;
        21) first_new_update=13 ;;
        25) first_new_update=5 ;;
        27) first_new_update=1 ;;
        26) printf '%s-%s\n' "${canonical%.*}" "${canonical##*.}"; return ;;
        *) first_new_update=0 ;;
    esac
    if (( 10#${update} < first_new_update )); then
        printf '%s-%s\n' "${canonical%.*}" "${canonical##*.}"
    else
        release=${CORRETTO_PACKAGE_RELEASE:-1}
        [[ "${release}" =~ ^[0-9]+$ ]] || { echo "Invalid package release: ${release}" >&2; return 1; }
        printf '%s-%s\n' "${canonical}" "${release}"
    fi
}

update_native_dockerfile() {
    local dockerfile=$1 canonical=$2 major=$3 package_pin
    [[ -f "${dockerfile}" ]] || return 0
    package_pin=$(native_package_version "${canonical}" "${major}")
    python3 - "${dockerfile}" "${package_pin}" "${canonical}" <<'PY'
from pathlib import Path
import re
import sys

path, package_pin, canonical = sys.argv[1:]
path = Path(path)
text = path.read_text()
text, count = re.subn(r"^ARG version=.*$", lambda _: "ARG version=" + package_pin, text, flags=re.M)
if count != 1:
    raise ValueError(f"Expected one version argument in {path}")
if "RPM_LIST=" in text and "corretto.aws/downloads/resources/" in text:
    if re.search(r"^ARG resource_version=", text, re.M):
        text = re.sub(r"^ARG resource_version=.*$", lambda _: "ARG resource_version=" + canonical, text, flags=re.M)
    else:
        text = text.replace("ARG version=" + package_pin, "ARG version=" + package_pin + "\nARG resource_version=" + canonical, 1)
    text = text.replace("$(echo $version | tr '-' '.')", "${resource_version}")
    text = re.sub(r"^\s*&& export (?:resouce_version|resource_version)=\$\{resource_version\} \\\n", "", text, flags=re.M)
    text = text.replace("${resouce_version}", "${resource_version}")
path.write_text(text)
PY
}

update_generic_linux() {
    local canonical=$1 major=$2
    for dockerfile in "./${major}/jdk/al2-generic/Dockerfile" "./${major}/jdk/debian/Dockerfile" "./${major}/slim/debian/Dockerfile" "./${major}/slim/al2/Dockerfile"; do
        update_native_dockerfile "${dockerfile}" "${canonical}" "${major}"
    done
}

update_amazon_linux_2023() {
    local canonical=$1 major=$2
    for image_type in jdk headful headless; do
        update_native_dockerfile "./${major}/${image_type}/al2023/Dockerfile" "${canonical}" "${major}"
    done
}

update_amazon_linux() {
    local canonical=$1 major=$2
    for image_type in jdk jre headful headless; do
        update_native_dockerfile "./${major}/${image_type}/al2/Dockerfile" "${canonical}" "${major}"
    done
    update_native_dockerfile "./${major}/slim/al2/Dockerfile" "${canonical}" "${major}"
}

cp versions.json tmp.json
for version_input in "$@"; do
    major_version="${version_input%%.*}"
    jq --arg major "${major_version}" --arg canonical "${version_input}" \
       '.[$major] |= if type == "object" then
          .GENERIC_LINUX = $canonical | .ALPINE = $canonical |
          .AMAZON_LINUX = $canonical | .AMAZON_LINUX_2023 = $canonical
        else $canonical end' tmp.json > tmp-new.json
    mv tmp-new.json tmp.json
done
mv tmp.json versions.json

VERSIONS=$(jq -r 'keys |@sh' versions.json|tr -d \')
PLATFORMS=("GENERIC_LINUX" "ALPINE" "AMAZON_LINUX" "AMAZON_LINUX_2023")
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
    # AMAZON_LINUX_2023 defaults to the AMAZON_LINUX (al2) value when not explicitly set,
    # so existing entries that omit the key keep the previous all-Amazon-Linux behavior.
    al2023_fallback="CORRETTO_${version}_AMAZON_LINUX_2023"
    al_fallback="CORRETTO_${version}_AMAZON_LINUX"
    if [[ "${!al2023_fallback}" == "null" || -z "${!al2023_fallback}" ]]; then
        eval CORRETTO_${version}_AMAZON_LINUX_2023="${!al_fallback}"
    fi
    if [[ "${version}" != "8" ]]; then
        generic_var="CORRETTO_${version}_GENERIC_LINUX"
        al_var="CORRETTO_${version}_AMAZON_LINUX"
        al2023_var="CORRETTO_${version}_AMAZON_LINUX_2023"
        update_generic_linux "${!generic_var}" "${version}"
        update_amazon_linux "${!al_var}" "${version}"
        update_amazon_linux_2023 "${!al2023_var}" "${version}"
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
fi

if [ ! -z "${CORRETTO_8_AMAZON_LINUX_2023}" ]; then
    jdk_version=$(echo ${CORRETTO_8_AMAZON_LINUX_2023} | cut -d'.' -f2)
    jdk_build=$(echo ${CORRETTO_8_AMAZON_LINUX_2023} | cut -d'.' -f3)
    corretto_version=$(echo ${CORRETTO_8_AMAZON_LINUX_2023} | cut -d'.' -f4)

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
    al2023_var="CORRETTO_${version}_AMAZON_LINUX_2023"
    verify_update "${version}" "${!generic_var}|${!al_var}|${!alpine_var}|${!al2023_var}"
done
