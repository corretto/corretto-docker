# Corretto Docker [![Build Status](https://travis-ci.org/corretto/corretto-docker.svg?branch=master)](https://travis-ci.org/corretto/corretto-docker)

Master repository where Dockerfiles for Amazon Corretto are hosted. These docker files are used to build images for [Amazon Corretto Offical Images](https://hub.docker.com/_/amazoncorretto) and ECR images.

# Usage

The docker images are available on [Amazon Corretto Official Images](https://hub.docker.com/_/amazoncorretto)

To use Amazon Corretto Official Images from Docker hub run
```
docker pull amazoncorretto:11
```

The docker images are also available on **Amazon ECR**.

To use the docker images from Amazon ECR, you would need to authenticate with the ECR registry (id: 489478819445) with the
help of instruction from [here](https://aws.amazon.com/blogs/compute/authenticating-amazon-ecr-repositories-for-docker-cli-with-credential-helper/).
Once authenticated, Amazon Corretto docker images can be pulled using command

```
docker pull 489478819445.dkr.ecr.us-west-2.amazonaws.com/amazoncorretto:latest
docker run -it 489478819445.dkr.ecr.us-west-2.amazonaws.com/amazoncorretto:latest /bin/bash
```

You can view the available tags, run
```
aws ecr list-images --region us-west-2 --registry-id 489478819445 --repository-name amazoncorretto | jq -r '.imageIds[] | .imageTag'
```


# Supported Tags
* [8, 8u265, 8u265-al2, 8-al2-full,8-al2-jdk, latest](https://hub.docker.com/_/amazoncorretto)
* [11, 11.0.8, 11.0.8-al2, 11-al2-jdk, 11-al2-full](https://hub.docker.com/_/amazoncorretto)
* [8-alpine, 8u265-alpine, 8-alpine-full, 8-alpine-jdk](https://hub.docker.com/_/amazoncorretto)
* [8-alpine-jre, 8u265-alpine-jre](https://hub.docker.com/_/amazoncorretto)
* [11-alpine, 11.0.8-alpine, 11-alpine-full, 11-alpine-jdk](https://hub.docker.com/_/amazoncorretto)
* [11-alpine-jre, 11.0.8-alpine-jre](https://hub.docker.com/_/amazoncorretto)

# Building
To build the docker images, you can use the following command.

```
docker build -t amazon-corretto-{major_version} -f ./{major_version}/{jdk|jre}/{al2|alpine|debian}/Dockerfile .
```

# Security
If you would like to report a potential security issue in this project, please do not create a GitHub issue. Instead,
please follow the instructions [here](https://aws.amazon.com/security/vulnerability-reporting/ ) or email
AWS security directly.
