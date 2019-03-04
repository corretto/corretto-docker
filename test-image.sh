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
docker build --tag corretto-11 .

# 3. Test using container-structure-test.
build/tool/container-structure-test-${cst_ostype}-amd64 test \
    --image corretto-11 \
    --config test-image.yaml
