# About this repo

This is the Git repository holding the official CodeMeter container image and the
Helm chart available at [Docker Hub - wibusystems](https://hub.docker.com/r/wibusystems)

## About the container image

This container image contains the CodeMeter Runtime for multiple use cases.
Those use cases include `NetworkServer`, `NetworkClient`, and `CmCloud` licenses.

Sources and documentation are available in our official [GitHub repository](https://github.com/wibu-systems/docker-codemeter).

### CodeMeter Runtime configuration

#### Using environment variables

| Environment variable                 | Value                      | Effect                                                                                                              |
| ------------------------------------ | -------------------------  | ------------------------------------------------------------------------------------------------------------------- |
| `CM_LOG_BOOTSTRAP`                   | [on,off] (default: off)    | Enables event logging during bootstrap step.                                                                        |
| `CM_USE_BROADCAST_REMOTE_SERVERS`    | [on,off] (default: on)     | Enables CodeMeter to broadcast to other CodeMeter network servers.                                                  |
| `CM_NETWORK_SERVER`                  | [on,off] (default: off)    | Start CodeMeter in container as network server.                                                                     |
| `CM_REMOTE_SERVER`                   | IP address or hostname     | Adds the given address to the server search list. Multiple remote servers must be separated by comma.               |
| `CM_LICENSE_FILE`                    | /path/to/license/file      | Imports the given license file(s) into the CodeMeter subsystem. Multiple files must be separated by comma.          |
| `CM_CMCLOUD_CREDENTIALS`<sup>1</sup> | /path/to/credentials/file  | Imports the given cloud credential file(s) into the CodeMeter subsystem. Multiple files must be separated by comma. |

Notes:

- <sup>1</sup>: This option is not compatible with `CM_LICENSE_FILE`,
  `CM_REMOTE_SERVER`, and `CM_USE_BROADCAST_REMOTE_SERVERS`.

#### Using Server.ini file

By default, CodeMeter stores and loads its settings from the `Server.ini`
file located at `/etc/wibu/CodeMeter/Server.ini`. This file can be placed
in a `volume` and modified. CodeMeter reads the configuration only during
startup.

### Exit codes

The entry point script defines dedicated exit codes depending on the reason for
failure. These exit codes are typically preceded by a descriptive error message.

| Exit Code | Meaning                                                           |
|-----------|-------------------------------------------------------------------|
| 0         | CodeMeter terminated gracefully.                                  |
| 1         | CodeMeter terminated with an error.                               |
| 15        | Invalid combination of environment variable configurations.       |
| 16        | A file was specified for import during bootstrap but was missing  |
| 17        | During bootstrap the import of a file failed - check the eventlog |

## About the Helm chart

The Helm chart provides a customizable Kubernetes deployment for the CodeMeter
container image.

Sources and documentation are available in our official [GitHub repository](https://github.com/wibu-systems/docker-codemeter).

### Configuration

| Option                                  | Type                                            | Default                           | Description                                                                                                                                     |
| --------------------------------------- | ----------------------------------------------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `image.repository`                      | `string`                                        | `docker.io/wibusystems/codemeter` | CodeMeter runtime image to deploy.                                                                                                              |
| `image.tag`                             | `string`                                        | `docker.io/wibusystems/codemeter` | CodeMeter runtime image tag.                                                                                                                    |
| `config.logBootstrap`                   | `bool`                                          | `null`                            | Maps to environment variable `CM_LOG_BOOTSTRAP`. Only passed if value is not `null`.                                                            |
| `config.useBroadcastRemoteServers`      | `bool`                                          | `null`                            | Maps to environment variable `CM_USE_BROADCAST_REMOTE_SERVERS`.  Only passed if value is not `null`.                                            |
| `config.networkServer`                  | `bool`                                          | `null`                            | Maps to environment variable `CM_NETWORK_SERVER`. Only passed if value is not `null`.                                                           |
| `config.remoteServer`                   | `list(string)`                                  | `[]`                              | Maps to environment variable `CM_REMOTE_SERVER`. Only passed if value is not `[]`.                                                              |
| `config.licenseFile`                    | `list({secretName: string, secretKey: string})` | `[]`                              | Lists references to specific secret keys. Maps to environment variable `CM_LICENSE_FILE`. Only passed if value is not `[]`.                     |
| `config.cmCloudCredentials`<sup>1</sup> | `list({secretName: string, secretKey: string})` | `[]`                              | Lists references to specific secret keys. Maps to environment variable `CM_CMCLOUD_CREDENTIALS`. Only passed if value is not `[]`.              |
| `config.serverIni`                      | `string`                                        | `...`                             | Contains the `Server.ini` which is mounted to `/etc/wibu/CodeMeter/Server.ini`. Changes to the file are not synchronized back to the ConfigMap. |

Notes:

- <sup>1</sup>: This option is not compatible with `config.licenseFile`,
  `config.remoteServer`, and `config.useBroadcastRemoteServers`

Refer to the `values.yaml` file for all available configurable options.

### Versioning

The Helm chart uses the same major and minor version as the container image.
However, the patch version may differ.  This enables patching of either the
container image or the Helm chart independently.

By keeping the major and minor versions in sync, compatibility remains
transparent. We test each Helm chart against the container image with the same
major and minor version. In addition, the default container image tag points
to the image’s major.minor version.

Example:

- Helm chart version `1.2.x`
  - compatibility with `wibusystems/codemeter:v1.2.y` tested
  - deploys `wibusystems/codemeter:v1.2` per default (`major.minor` pinning)

## Questions or feedback?

For support questions ("How do I?", "I got this error, why?", ...), please read
the [Documentation](https://www.wibu.com/support/manuals-guides.html) before
contacting our customer support.

Please refer to `BUILDING.md` before trying to build any of the images.
