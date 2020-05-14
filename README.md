# Corretto Docker 

Master repository where Dockerfiles for Amazon Corretto are hosted. These docker files are used to build images for [Amazon Corretto Offical Images](https://hub.docker.com/_/amazoncorretto)

# Building 

```
docker build -t amazon-corretto-{major_version} -f ./{major_version}/{jdk|jre}/{al2|alpine|debian}/Dockerfile . 
```

# Usage

The docker images are available on [Amazon Corretto Official Images](https://hub.docker.com/_/amazoncorretto)