# About this repo

This is the Git Repository of the official CodeMeter Docker Images available
on [wibusystems/codemeter](https://hub.docker.com/r/wibusystems/codemeter).

## About the Image

This image provides the CodeMeter Runtime used for Licensing containerized Applications. Sources are available on our
official [github repo](https://github.com/wibu-systems/docker-codemeter)

### About the image content

This image contains the CodeMeter Runtime for multiple use cases. Those use cases include, `NetworkServer`, `NetworkClient` and `CmCloud`
licenses.

Please refer to our official Documentation on [github](https://github.com/wibu-systems/docker-codemeter) for further information.

## Configure CodeMeter Runtime

### Via Entrypoint / Environment Variables

| Environment Variable                 | Value                     | Effect                                                                                                             |
|--------------------------------------|---------------------------|--------------------------------------------------------------------------------------------------------------------|
| `CM_NETWORK_SERVER`                  | [on,off] (default: off)   | Start CodeMeter in container as Network-server                                                                     |
| `CM_REMOTE_SERVER`                   | IP-Address or Hostname    | Add the given Address to the Server Search List. Multiple Remote Servers must be separated with a colon            |
| `CM_LICENSE_FILE`                    | /path/to/license/file     | Import the given License File(s) into the CodeMeter Subsystem. Multiple files must be separated with a colon       |
| `CM_LOG_BOOTSTRAP`                   | [on,off] (default: off)   | Enable eventlogging for during bootstrap step                                                                      |
| `CM_USE_BROADCAST_REMOTE_SERVERS`    | [on,off] (default: on)    | Enables CodeMeter to Broadcast to other CodeMeter Network Servers                                                  |
| `CM_CMCLOUD_CREDENTIALS`<sup>1</sup> | /path/to/credentials/file | Imports the given cloud credential file(s) into the CodeMeter subsystem. Multiple files must be separated by comma |

Notes:

- <sup>1</sup>: This option is not compatible with `CM_LICENSE_FILE`, `CM_REMOTE_SERVER`, and `CM_USE_BROADCAST_REMOTE_SERVERS`.

### Via Server.ini

By default, CodeMeter saves and reads it settings from the `Server.ini` file at `/etc/wibu/CodeMeter/Server.ini` which can be placed into
a `volume` and edited.
CodeMeter will load this configuration during startup only.

## Exit Codes

The entrypoint script defines dedicated exit codes, depending on the failure reason.
Those exit codes are usually preceded by a meaningful error message.

| Exit Code | Meaning                                                           |
|-----------|-------------------------------------------------------------------|
| 0         | CodeMeter terminated gracefully.                                  |
| 1         | CodeMeter terminated with an error.                               |
| 15        | Invalid combination of environment variable configurations.       |
| 16        | A file was specified for import during bootstrap but was missing  |
| 17        | During bootstrap the import of a file failed - check the eventlog |

## Have Questions or Feedback?

For support questions ("How do I?", "I got this error, why?", ...), please first read
the [Documentation](https://www.wibu.com/support/manuals-guides.html) before heading to our customer support.

Please refer to `BUILDING.md` before trying to build any of the images.

