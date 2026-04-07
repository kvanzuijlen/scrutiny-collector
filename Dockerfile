FROM debian:13.4@sha256:3352c2e13876c8a5c5873ef20870e1939e73cb9a3c1aeba5e3e72172a85ce9ed AS builder

RUN apt-get update && apt-get install -y build-essential && apt-get clean

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5

ADD https://github.com/smartmontools/smartmontools/releases/download/RELEASE_${SMARTMONTOOLS_VERSION}/smartmontools-${SMARTMONTOOLS_VERSION//_/.}.tar.gz smartmontools.tar.gz

RUN tar zxvf smartmontools.tar.gz
WORKDIR /smartmontools-${SMARTMONTOOLS_VERSION//_/.}
RUN ./configure --prefix=/smartmontools-install LDFLAGS="-static" && make && make install

FROM ghcr.io/analogj/scrutiny:v0.8.6-collector@sha256:c5228c99119a708e23f6235619273ae8d03735ba2a283aa97ecb5085787ea0f7

LABEL authors="kvanzuijlen"

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5
COPY --from=builder /smartmontools-install/etc/ /etc/
COPY --from=builder /smartmontools-install/sbin/ /sbin/
COPY --from=builder /smartmontools-install/share/ /share/
