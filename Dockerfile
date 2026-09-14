FROM debian:13.6@sha256:f324c7ff54321e8d9c588493a20244965938ce0aa50bbd1022d38010e9ffc4b1 AS builder

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
