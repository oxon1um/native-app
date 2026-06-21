# SAGE Docker

This is a Dockerized fork of the Go native backend for the SAGE App.

## Building

To build the app, you need to have the go compiler installed. You can download
it from [here](https://golang.org/dl/).

On linux, you will also need to install
[GTK related libraries](https://github.com/webview/webview?tab=readme-ov-file#prerequisites)
(make sure to use version 4.1).

Once you have the go compiler installed, you can run the following command to
build the app:

```bash
go build
```

> [!NOTE]  
> If you are having issues building, you should run `git tag` and checkout the
> latest tag. This will ensure that you are building the latest version of the
> app which is known to work.

You can also find pre-built binaries in the
[releases](https://github.com/sag-enhanced/native-app/releases) section.

## Docker

This fork includes a Linux desktop container that exposes the SAGE window
through noVNC.

```bash
docker compose up --build
```

Open
[http://localhost:6080/vnc.html?autoconnect=1&resize=scale](http://localhost:6080/vnc.html?autoconnect=1&resize=scale)
in a browser. Application data is persisted in the `sage-data` Docker volume.

The published image can also be started directly:

```bash
docker run --rm \
  -p 127.0.0.1:6080:6080 \
  -v sage-data:/data \
  --shm-size=1g \
  ghcr.io/oxon1um/sage-docker:latest
```

Set `SAGE_VNC_PASSWORD` when using Compose to require a VNC password:

```bash
SAGE_VNC_PASSWORD='replace-me' docker compose up
```

Compose binds noVNC to `127.0.0.1` by default. Set `SAGE_NOVNC_HOST=0.0.0.0`
only when remote access is required, and set a VNC password whenever the port
is reachable by other machines.

The container packages the Linux GUI and backend. Features that inspect,
patch, stop, or launch Steam require Steam to run inside the same container.
In particular, a container running through Docker Desktop cannot manage a
Steam installation running directly on a macOS or Windows host.

## Issues

If you have any issues with the app, please open an issue in the
[issue tracker](https://github.com/sag-enhanced/sage-issues/issues). See
[SECURITY.md](SECURITY.md) for more information on how to report security
issues.

## LICENSE

This project is licensed under a SOURCE AVAILABLE license. See the
[LICENSE](LICENSE.md) file for more details.
