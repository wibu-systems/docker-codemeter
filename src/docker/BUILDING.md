# How to Build  

This is a short description on how the images are built

## Context Preparation

The `Dockerfile` assumes that the deb package for this arch is located next at the build context root (usually next to the docker file). Therefore it is required to copy the installers into the build context.  
Example:  

```shell
cp -v ../*.deb .
```

## Build image

Building the image is done using a single command, when using `Docker`:

```shell
docker build -t wibusystems/codemeter --no-cache -f Dockerfile .
```

### Additonal Build Parameters

When cross building images for another architecture, the additonal `platform` parameter may be passed when building. Currently only amd64 and arm64 CPU Architectures are being tested.
Please refer to the [Docker Docs](https://docs.docker.com/build/building/multi-platform/) for more details about multiplatform images and builds.

Example:

```shell
docker build -t wibusystems/codemeter --no-cache --platform=linux/arm64 -f Dockerfile .
```

Changing the CodeMeter version can be done by placing another CodeMeter-Deb Package into this directory and passing the build argument `CODEMETER_VERSION`.
Example:  

```shell
docker build -t wibusystems/codemeter:8.20 --no-cache --build-arg CODEMETER_VERSION=8.20.6539.500 -f Dockerfile .
```

When Building mutliple platforms at once, buildx is recommended.  
Example:

```shell
docker buildx build --platform linux/amd64,linux/arm64 -t wibusystems/codemeter:8.20 -f Dockerfile .
```
