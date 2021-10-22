# Corretto Docker ![Build Status](https://github.com/corretto/corretto-docker/workflows/Verify%20Docker%20Images/badge.svg)

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
* [8, 8u312, 8u312-al2, 8-al2-full,8-al2-jdk, latest](https://hub.docker.com/_/amazoncorretto)
* [11, 11.0.13, 11.0.13-al2, 11-al2-jdk, 11-al2-full](https://hub.docker.com/_/amazoncorretto)
* [8-alpine3.12, 8u312-alpine3.12, 8-alpine3.12-full, 8-alpine3.12-jdk, 8-alpine, 8u312-alpine, 8-alpine-full, 8-alpine-jdk](https://hub.docker.com/_/amazoncorretto)
* [8-alpine3.12-jre, 8u312-alpine3.12-jre, 8-alpine-jre, 8u312-alpine-jre](https://hub.docker.com/_/amazoncorretto)
* [8-alpine3.13, 8u312-alpine3.13, 8-alpine3.13-full, 8-alpine3.13-jdk](https://hub.docker.com/_/amazoncorretto)
* [8-alpine3.13-jre, 8u312-alpine3.13-jre](https://hub.docker.com/_/amazoncorretto)
* [8-alpine3.14, 8u312-alpine3.14, 8-alpine3.14-full, 8-alpine3.14-jdk](https://hub.docker.com/_/amazoncorretto)
* [8-alpine3.14-jre, 8u312-alpine3.14-jre](https://hub.docker.com/_/amazoncorretto)
* [11-alpine3.12, 11.0.13-alpine3.12, 11-alpine3.12-full, 11-alpine3.12-jdk, 11-alpine, 11.0.13-alpine, 11-alpine-full, 11-alpine-jdk](https://hub.docker.com/_/amazoncorretto)
* [11-alpine3.13, 11.0.13-alpine3.13, 11-alpine3.13-full, 11-alpine3.13-jdk](https://hub.docker.com/_/amazoncorretto)
* [11-alpine3.14, 11.0.13-alpine3.14, 11-alpine3.14-full, 11-alpine3.14-jdk](https://hub.docker.com/_/amazoncorretto)
* [16, 16-al2-jdk, 16-al2-full](https://hub.docker.com/_/amazoncorretto)
* [16-alpine, 16-alpine-full, 16-alpine-jdk](https://hub.docker.com/_/amazoncorretto)
* [17, 17-al2-jdk, 17-al2-full](https://hub.docker.com/_/amazoncorretto)
* [17-alpine3.12, 17.0.1-alpine3.12, 17-alpine3.12-full, 17-alpine3.12-jdk](https://hub.docker.com/_/amazoncorretto)
* [17-alpine3.13, 17.0.1-alpine3.13, 17-alpine3.13-full, 17-alpine3.13-jdk](https://hub.docker.com/_/amazoncorretto)
* [17-alpine3.14, 17.0.1-alpine3.14, 17-alpine3.14-full, 17-alpine3.14-jdk, 17-alpine, 17.0.1-alpine, 17-alpine-full, 17-alpine-jdk](https://hub.docker.com/_/amazoncorretto)

# Building
To build the docker images, you can use the following command.

```
docker build -t amazon-corretto-{major_version} -f ./{major_version}/{jdk|jre|slim}/{al2|alpine|debian}/Dockerfile .
```

# Security
If you would like to report a potential security issue in this project, please do not create a GitHub issue. Instead,
please follow the instructions [here](https://aws.amazon.com/security/vulnerability-reporting/ ) or email
AWS security directly.

## Why does security scanner show that a docker image has a CVE?

If a security scanner reports that an amazoncorretto image includes a CVE, the first recommended action is to pull an updated version of this image.

If no updated image is available, run the appropriate command to update packages for the platform, ie. run "apk -U upgrade" for Alpine or "yum update -y --security" for AmazonLinux in your Dockerfiles or systems to resolve the issue immediately.

If no updated package is available, please treat this as a potential security issue and follow [these instructions](https://aws.amazon.com/security/vulnerability-reporting/) or email AWS security directly at [aws-security@amazon.com](mailto:aws-security@amazon.com).

It is the responsibility of the base docker image supplier to provide timely security updates to images and packages. The amazoncorretto images are automatically rebuilt when a new base image is made available, but we do not make changes to our Dockerfiles to pull in one-off package updates.  If a new base image has not yet been made generally available by a base docker image maintainer, please contact that maintainer to request that the issue be addressed.

Note that there are multiple reasons why a CVE may appear to be present in a docker image, as explained in the [docker library FAQs](https://github.com/docker-library/faq/tree/73f10b0daf2fb8e7b38efaccc0e90b3510919d51#why-does-my-security-scanner-show-that-an-image-has-cves).
