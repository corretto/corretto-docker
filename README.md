# Corretto Docker ![Build Status](https://github.com/corretto/corretto-docker/workflows/Verify%20Docker%20Images/badge.svg)

Master repository where Dockerfiles for Amazon Corretto are hosted. These docker files are used to build images for [Amazon Corretto Offical Images](https://hub.docker.com/_/amazoncorretto) and ECR images.

# Notice: Default images moved from Amazon Linux 2 to Amazon Linux 2023

Amazon Linux 2 (AL2) is now end of life. The default `amazoncorretto` images (for example
`amazoncorretto:8`, `amazoncorretto:11`, `amazoncorretto:17`, `amazoncorretto:21` and `latest`)
are now based on Amazon Linux 2023 (AL2023). Corretto 22+ images were already AL2023 based.

If you cannot upgrade to AL2023 yet, the AL2 based images remain available as a fallback via the
`-al2` tags, for example `amazoncorretto:17-al2`. Note that AL2 no longer receives standard
support; migrating to AL2023 is strongly recommended.

For most users the switch is transparent:
* AL2023 uses `dnf` as its package manager, but `yum` remains available as a symlink to `dnf`
  (`/usr/bin/yum -> dnf`), so `RUN yum install ...` lines in downstream Dockerfiles keep working.
  Some rarely used yum options are not supported by dnf; see the
  [AL2023 package management documentation](https://docs.aws.amazon.com/linux/al2023/ug/package-management.html).
* The default images now use the Corretto RPMs built specifically for Amazon Linux instead of the
  generic Linux RPMs. Package versions will match Amazon Linux Security Advisory (ALAS) bulletins,
  and the JDK uses the platform certificate store (`lib/security/cacerts` is a symlink to
  `/etc/pki/java/cacerts`) instead of a bundled copy.
* See the [AL2023 comparison guide](https://docs.aws.amazon.com/linux/al2023/ug/compare-with-al2.html)
  for other differences between AL2 and AL2023.

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
docker build -t amazon-corretto-{major_version} -f ./{major_version}/{jdk|jre|slim}/{al2023|al2|alpine|debian}/Dockerfile .
```

# Security
If you would like to report a potential security issue in this project, please do not create a GitHub issue. Instead,
please follow the instructions [here](https://aws.amazon.com/security/vulnerability-reporting/ ) or email
AWS security directly.

## Why does security scanner show that a docker image has a CVE?

If a security scanner reports that an amazoncorretto image includes a CVE, the first recommended action is to pull an updated version of this image with `docker pull amazoncorretto:<tag>`.

If no updated image is available, run the appropriate command to update packages for the platform in your Dockerfiles or running systems to resolve the issue immediately.
 * AmazonLinux 2023 (default images): `dnf update -y --security --releasever=latest`
 * AmazonLinux 2 and many other RPM based distrobutions: `yum update -y --security`
 * AlpineLinux: `apk -U upgrade`

If no updated package is available, please treat this as a potential security issue and follow [these instructions](https://aws.amazon.com/security/vulnerability-reporting/) or email AWS security directly at [aws-security@amazon.com](mailto:aws-security@amazon.com).

It is the responsibility of the base docker image supplier to provide timely security updates to images and packages. The amazoncorretto images are automatically rebuilt when a new base image is made available, but we do not make changes to our Dockerfiles to pull in one-off package updates. If a new base image has not yet been made generally available by a base docker image maintainer, please contact that maintainer to request that the issue be addressed.

Note that there are multiple reasons why a CVE may appear to be present in a docker image, as explained in the [docker library FAQs](https://github.com/docker-library/faq/tree/73f10b0daf2fb8e7b38efaccc0e90b3510919d51#why-does-my-security-scanner-show-that-an-image-has-cves).

Security scanners may use heuristics or version checks of packages compared to a security advisory to determine if an image is potentially vulnerable. The generic Linux Corretto RPMs use a slightly different version than packages built specifically for Amazon Linux, images are available for both package types. When an Amazon Linux Security Advisory (ALAS) bulliten is published it will include the Corretto package name and version that contains the fix and that version will not correctly match the generic Linux package. 

## Types of images provided

**amazoncorretto:<version>**
The default image, based on Amazon Linux 2023 using the Corretto RPMs specifically built for the platform using the platform’s toolchain. These will include all dependencies and the version of the Corretto packages will match ALAS bulletins. This is the same image as `amazoncorretto:<version>-al2023`. **Notice:** in this image, the Corretto JDK uses the default platform certificates and `lib/security/cacerts` is just a simlink to `/etc/pki/java/cacerts`.

**amazoncorretto:<version>-al2**
Based on Amazon Linux 2 and using the Corretto generic Linux RPM packages. This was the default image until July 21, 2026 for Corretto 8, 11, 17, and 21. AL2 is end of life and these images are provided only as a fallback for users who cannot migrate to AL2023 yet. The Corretto packages installed support a wide range of Linux versions, and not all GUI dependencies are installed. The Corretto generic linux packages use a slightly different version scheme than native packages, which may not match exact versions posted in ALAS bulletins. However, both generic linux and native Amazon Linux packages will contain the same code. **Notice:** in this image, the Corretto JDK comes with its own, bundled version of certificates under `lib/security/cacerts`.

**amazoncorretto:<version>-alpine**
Based on [Alpine Linux](https://www.alpinelinux.org/) that uses [musl libc](https://musl.libc.org/), with a focus on smaller image sizes. Images are available for each supported Alpine version. When new versions of Alpine come out, a pre-built image is typically provided on the next Corretto security release after the base image is available.

**amazoncorretto:<version>-al2-native**
Based on Amazon Linux 2 using the Corretto RPMs specifically built for the platform using the platform’s toolchain. These will include all dependencies, and the version of the Corretto packages will match ALAS bulletins. **Notice:** in this image, the Corretto JDK uses the default platform certificates and `lib/security/cacerts` is just a simlink to `/etc/pki/java/cacerts`.

**amazoncorretto:<version>-al2023**
Based on Amazon Linux 2023 using the Corretto RPMs specifically built for the platform using the platform’s toolchain. These will include all dependencies and the version of the Corretto packages will match ALAS bulletins. This is the same image as the `amazoncorretto:<version>` default. **Notice:** in this image, the Corretto JDK uses the default platform certificates and `lib/security/cacerts` is just a simlink to `/etc/pki/java/cacerts`.

**amazoncorretto:<version>-debian**
The dockerfiles are provided as examples only. Corretto is supported on `apt`/`deb` based distributions, but does not provide pre-built images.

### Image subtypes

#### Corretto 8
**jre** - Contains only the runtime components and not the compiler. Suitable for most services.

**jdk** - Full development environment with compiler and tools.

#### Corretto 11+
**headless** - Contains runtime components without GUI libraries and dependencies. This will be the smallest image and is suitable for most services.

**headful** - Runtime components with GUI libraries and dependencies.

**jdk** - Full development environment with compiler and tools.

### Version Tags

Image tags contain either just the major version or a specific security update version. Corretto 8 version tags have a format of `8u<security_update_version>`, for example `8u402` . Corretto 11 and later use `<major_version>.0.<security_update_version>`, for example `11.0.22` . Images for a major version always point to the latest security update. Once a new security update version is released, the old tag no longer gets base image updates but remains available.
