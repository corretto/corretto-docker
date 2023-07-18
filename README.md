# Corretto Docker ![Build Status](https://github.com/corretto/corretto-docker/workflows/Verify%20Docker%20Images/badge.svg)

Master repository where Dockerfiles for Amazon Corretto are hosted. These docker files are used to build images for [Amazon Corretto Offical Images](https://hub.docker.com/_/amazoncorretto) and ECR images.

# Usage

The docker images are available on [Amazon Corretto Official Images](https://hub.docker.com/_/amazoncorretto)

To use Amazon Corretto Official Images from Docker hub run
```
docker pull amazoncorretto:17
```

The docker images are also available on **Amazon ECR**.

To get Corretto docker images from Amazon ECR please see [Amazon Corretto's ECR Public Gallery](https://gallery.ecr.aws/amazoncorretto/amazoncorretto) as well as the [Docker Official Images ECR Public Gallery](https://gallery.ecr.aws/docker/library/amazoncorretto)

To use docker images from Corretto ECR Public Gallery run the following commands:

```
docker pull public.ecr.aws/amazoncorretto/amazoncorretto:17
docker run -it public.ecr.aws/amazoncorretto/amazoncorretto:17 /bin/bash
```

You can see the list of available images by going to:
https://gallery.ecr.aws/amazoncorretto/amazoncorretto



# Supported Tags

See https://hub.docker.com/_/amazoncorretto


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

:warning: If you are using a Corretto Docker image with an AL2 guest, then Amazon’s ECS scanning function can result in a [ALAS2-2021-1731 notification](https://alas.aws.amazon.com/AL2/ALAS-2021-1731.html). However, there is no reason to update the Corretto application within Docker. You can safely ignore this ALAS. Once the next Corretto quarterly release is posted, currently scheduled for January 19, 2022, the alarm condition will be satisfied.
This notice only affects the following Corretto Docker images with AL2 in the Docker ECR:
  
* [11, 11.0.20, 11.0.20-al2, 11-al2-jdk, 11-al2-full](https://hub.docker.com/_/amazoncorretto)
* [17, 17-al2-jdk, 17-al2-full](https://hub.docker.com/_/amazoncorretto)

---

If a security scanner reports that an amazoncorretto image includes a CVE, the first recommended action is to pull an updated version of this image.

If no updated image is available, run the appropriate command to update packages for the platform, ie. run "apk -U upgrade" for Alpine or "yum update -y --security" for AmazonLinux in your Dockerfiles or systems to resolve the issue immediately.

If no updated package is available, please treat this as a potential security issue and follow [these instructions](https://aws.amazon.com/security/vulnerability-reporting/) or email AWS security directly at [aws-security@amazon.com](mailto:aws-security@amazon.com).

It is the responsibility of the base docker image supplier to provide timely security updates to images and packages. The amazoncorretto images are automatically rebuilt when a new base image is made available, but we do not make changes to our Dockerfiles to pull in one-off package updates.  If a new base image has not yet been made generally available by a base docker image maintainer, please contact that maintainer to request that the issue be addressed.

Note that there are multiple reasons why a CVE may appear to be present in a docker image, as explained in the [docker library FAQs](https://github.com/docker-library/faq/tree/73f10b0daf2fb8e7b38efaccc0e90b3510919d51#why-does-my-security-scanner-show-that-an-image-has-cves).
