# About this repo

This is the Git Repositroy of the offical CodeMeter Docker Images available on [wibusystems/codemeter](https://hub.docker.com/r/wibusystems/codemeter).

## About the Image

This image provides the CodeMeter Runtime used for Licensing containerized Applications. Sources are available on our offical [github repo](https://github.com/wibu-systems/docker-codemeter)

### Configure CodeMeter Runtime

#### Via Entrypoint / Environment Variables

| Environment Variable | Value | Effect |
| --------------------- | ------------------------- | ------------------------------------------------- |
| `CM_NETWORK_SERVER `  | [on,off] (default: off)   | Start CodeMeter in container as Networkserver     |
| `CM_REMOTE_SERVER `   | IP-Address or Hostname    | Add the given Address to the Server Search List   |
| `CM_LICENSE_FILE`     | /path/to/license/file     | Import the given License File into the CodeMeter Subsystem |

#### Via Server.ini

By default CodeMeter saves and reads it settings from the `Server.ini` file at `/etc/wibu/CodeMeter/Server.ini` which can be placed into a `volume` and edited.
CodeMeter will load this configuration file during startup, so changes may require a Container restart.  

## Repo Structure

This repo contains the Dockerfile as well as required scripts used by the image. Further the directory `blobs` contains the used deb packages, which are also available on our [Website](https://www.wibu.com/support/user/user-software.html).

## Have Questions or Feedback?

For support questions ("How do I?", "I got this error, why?", ...), please first read the [Documentation](wibu-systems/docker-codemeter/blob/main/docs/CodeMeterAndDocker.md) and the [User Doc](wibu-systems/docker-codemeter/blob/main/docs/UserDoc.md) before heading to our customer support.  

Please refere to `BUILDING.md` before trying to build any of the images.  
