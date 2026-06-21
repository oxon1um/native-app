# syntax=docker/dockerfile:1

FROM golang:1.24-bookworm AS builder

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        libgtk-3-dev \
        libwebkit2gtk-4.1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=1 go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/native-app \
    .

FROM debian:bookworm-slim AS runtime

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        dbus-x11 \
        fonts-dejavu-core \
        libgtk-3-0 \
        libwebkit2gtk-4.1-0 \
        novnc \
        openbox \
        tini \
        websockify \
        x11vnc \
        xdg-utils \
        xvfb \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 --shell /bin/sh sage \
    && mkdir -p /data \
    && chown sage:sage /data

COPY --from=builder /out/native-app /usr/local/bin/native-app
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint

RUN chmod 0755 /usr/local/bin/native-app /usr/local/bin/docker-entrypoint

ENV DISPLAY=:99 \
    RESOLUTION=1280x800x24 \
    SAGE_DATA_DIR=/data

EXPOSE 6080

VOLUME ["/data"]

USER sage

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint"]

