# About this repo

This is the Git Repositroy of the offical CodeMeter Docker Images available on [wibusystems/codemeter](https://hub.docker.com/r/wibusystems/codemeter).

## About the Image

This image provides the CodeMeter Runtime used for Licensing containerized Applications. Sources are available on our offical [github repo](https://github.com/wibu-systems/docker-codemeter)

### About the image content

This image contains the CodeMeter Runtime for mutliple use cases. Those usecases include, `NetworkServer`, `NetworkClient` and `CmCloud` licenses.

Please refere to our offcial Documentation on [github](https://github.com/wibu-system/docker-codemeter) for further information.

## Configure CodeMeter Runtime

### Via Entrypoint / Environment Variables

| Environment Variable  | Value                     | Effect                                                        |
| --------------------- | ------------------------- | ------------------------------------------------------------- |
| `CM_NETWORK_SERVER`   | [on,off] (default: off)   | Start CodeMeter in container as Networkserver                 |
| `CM_REMOTE_SERVER`    | IP-Address or Hostname    | Add the given Address to the Server Search List               |
| `CM_LICENSE_FILE`     | /path/to/license/file     | Import the given License File into the CodeMeter Subsystem    |
| `CM_LOG_BOOTSTRAP`    | [on,off] (default: off)   | Enable eventlogging for during bootstrap step                 |

### Via Server.ini

By default CodeMeter saves and reads it settings from the `Server.ini` file at `/etc/wibu/CodeMeter/Server.ini` which can be placed into a `volume` and edited.
CodeMeter will load this configuration during startup only.

## Exit Codes

The entrypoint script defines dedicated exit codes, depending on the failure reason.
Those exit codes are usually preceeded by a meaningfull error message.

| Exit Code | Meaning                                                            |
| --------- | ------------------------------------------------------------------ |
| 0         | CodeMeter terminated gracefully.                                   |
| 1         | CodeMeter terminated with an error.                                |
| 16        | A file was specified for import during bootstrap but was missing   |
| 17        | During bootstrap the import of a file failed - check the eventlog  |

## Have Questions or Feedback?

For support questions ("How do I?", "I got this error, why?", ...), please first read the [Documentation](https://www.wibu.com/support/manuals-guides.html) before heading to our customer support.  

Please refere to `BUILDING.md` before trying to build any of the images.
