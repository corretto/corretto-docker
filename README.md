# corretto-11-docker

[![Build Status](https://travis-ci.org/corretto/corretto-11-docker.svg?branch=master)](https://travis-ci.org/corretto/corretto-11-docker)

Master repository where Dockerfiles for [Corretto 11](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/what-is-corretto-11.html) are hosted.

## Building

```
docker build -t amazon-corretto-11 github.com/corretto/corretto-11-docker
```

## Testing

Tests are defined in `test-image.yaml` using [GoogleContainerTools/container-structure-test](
https://github.com/GoogleContainerTools/container-structure-test). To run tests, execute `./test-image.sh`.

## Usage

A `JAVA_HOME` environment variable is configured to assist in tasks that require a known location of additional JRE/JDK files.
