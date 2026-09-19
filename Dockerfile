FROM debian:13.7@sha256:a792639161fbe8a4249347e72ea43d0fa6039c97413097e3aa225406173ec1ec AS builder

RUN apt-get update && apt-get install -y build-essential && apt-get clean

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5

ADD https://github.com/smartmontools/smartmontools/releases/download/RELEASE_${SMARTMONTOOLS_VERSION}/smartmontools-${SMARTMONTOOLS_VERSION//_/.}.tar.gz smartmontools.tar.gz

RUN tar zxvf smartmontools.tar.gz
WORKDIR /smartmontools-${SMARTMONTOOLS_VERSION//_/.}
RUN ./configure --prefix=/smartmontools-install LDFLAGS="-static" && make && make install

FROM ghcr.io/analogj/scrutiny:v0.9.4-collector@sha256:3f84c69d040877a521fdb92ff4bc31818bef8fb3dd52d0b796e0b76a342d7f41

LABEL authors="kvanzuijlen"

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5
COPY --from=builder /smartmontools-install/etc/ /etc/
COPY --from=builder /smartmontools-install/sbin/ /sbin/
COPY --from=builder /smartmontools-install/share/ /share/
