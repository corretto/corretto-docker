#!/bin/bash
set -euo pipefail


# 1. Fetch and setup test framework.
# For more info and usage examples, see:
#   https://github.com/GoogleContainerTools/container-structure-test

# only linux and osx are supported
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  cst_ostype="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  cst_ostype="darwin"
else
  echo "Unsupported operating system[$OSTYPE]"
  exit 1
fi
mkdir -p build/tool
wget -N \
     -P build/tool \
      https://storage.googleapis.com/container-structure-test/latest/container-structure-test-${cst_ostype}-amd64
chmod +x build/tool/container-structure-test-${cst_ostype}-amd64

# 2. Build the docker image.
# You can set $1 to a Dockerfile to test interractively
docker build -f ${1-${DOCKER_FILE}} --tag corretto-docker `dirname ${1-$DOCKER_FILE}}`

corretto_version=$(echo ${1-${DOCKER_FILE}} | rev | cut -d'/' -f4 | rev)
install=$(echo ${1-${DOCKER_FILE}} | rev | cut -d'/' -f3 | rev)
# 3. Test using container-structure-test.
build/tool/container-structure-test-${cst_ostype}-amd64 test \
    --image corretto-docker \
    --config test-image-corretto${corretto_version}-${install}.yaml
