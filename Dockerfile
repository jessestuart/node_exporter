ARG target
FROM golang:1.14-alpine as builder

ARG goarch
ENV GOARCH $goarch
ENV GOOS linux

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on

ENV GO_PKG github.com/prometheus/node_exporter

ARG VERSION

RUN  \
  apk add --no-cache git && \
  git clone --depth=1 https://${GO_PKG} && \
  cd node_exporter && \
  GOARCH=${GOARCH} make common-build

FROM $target/alpine:3.11

COPY --from=builder node_exporter /bin/node_exporter

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL \
  maintainer="Jesse Stuart <hi@jessestuart.com>" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.url="https://hub.docker.com/r/jessestuart/node_exporter" \
  org.label-schema.vcs-url="https://github.com/jessestuart/node_exporter" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.version="${VERSION}" \
  org.label-schema.schema-version="1.0"

COPY qemu-* /usr/bin/

EXPOSE      9100
USER        nobody
ENTRYPOINT  [ "/bin/node_exporter" ]
