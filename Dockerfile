FROM debian:13.6@sha256:34cd9e9fd437c0a095ec39cb2e73422c9f30821b0d0848ed74fd0d43bae4d958 AS builder

RUN apt-get update && apt-get install -y build-essential && apt-get clean

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5

ADD https://github.com/smartmontools/smartmontools/releases/download/RELEASE_${SMARTMONTOOLS_VERSION}/smartmontools-${SMARTMONTOOLS_VERSION//_/.}.tar.gz smartmontools.tar.gz

RUN tar zxvf smartmontools.tar.gz
WORKDIR /smartmontools-${SMARTMONTOOLS_VERSION//_/.}
RUN ./configure --prefix=/smartmontools-install LDFLAGS="-static" && make && make install

FROM ghcr.io/analogj/scrutiny:v0.9.3-collector@sha256:9e3413b1992eee55cd4138a2e5b9083ce47f6f3ffce7d1c1eb17995c05728b3e

LABEL authors="kvanzuijlen"

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5
COPY --from=builder /smartmontools-install/etc/ /etc/
COPY --from=builder /smartmontools-install/sbin/ /sbin/
COPY --from=builder /smartmontools-install/share/ /share/
