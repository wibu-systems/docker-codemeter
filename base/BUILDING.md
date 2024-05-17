# How to Build  

This is a short description on how the images are built

## Context Preparation

The `Dockerfile` assumes that the deb package for this arch is located next at the build context root (usually next to the docker file). Therefore it may be required to copy that file into your build context.

## Build image

Building the image is done using a single command:

```shell
docker build -t wibusystems/codemeter --no-cache -f Dockerfile .
```

### Additonal Build Parameters

When cross building images for another architecture, the additonal `platform` parameter may be passed when building. Currently only amd64 and arm64 CPU Architectures are supported.  
Example:

```shell
docker build -t wibusystems/codemeter --no-cache --platform=linux/arm64 -f Dockerfile .
```

Changing the CodeMeter Version can be done by placing another CodeMeter-Deb Package into this directory and passing the build argument `CODEMETER_VERSION`.
Example:  

```shell
docker build -t wibusystems/codemeter:8.00a --no-cache --build-arg CODEMETER_VERSION=8.0.5974.501 -f Dockerfile .
```

When Building mutliple platforms at once, buildx is recommended.  
Example:

```shell
docker buildx build --platform linux/amd64,linux/arm64 -t wibusystems/cm_internal:8.10 -f Dockerfile .
```
