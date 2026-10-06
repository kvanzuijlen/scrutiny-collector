FROM debian:13.7@sha256:913f6706df59a68922d1dd08f78c2476560a8d367897200a6005b00e5f67c2d5 AS builder

RUN apt-get update && apt-get install -y build-essential && apt-get clean

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5

ADD https://github.com/smartmontools/smartmontools/releases/download/RELEASE_${SMARTMONTOOLS_VERSION}/smartmontools-${SMARTMONTOOLS_VERSION//_/.}.tar.gz smartmontools.tar.gz

RUN tar zxvf smartmontools.tar.gz
WORKDIR /smartmontools-${SMARTMONTOOLS_VERSION//_/.}
RUN ./configure --prefix=/smartmontools-install LDFLAGS="-static" && make && make install

FROM ghcr.io/analogj/scrutiny:v0.9.5-collector@sha256:e55394663d4430af7dec36b1979785a2a2481b317047077eac84acb8305d583d

LABEL authors="kvanzuijlen"

# renovate: datasource=github-tags depName=smartmontools/smartmontools versioning=loose extractVersion=^RELEASE_(?<version>.*)$
ENV SMARTMONTOOLS_VERSION=7_5
COPY --from=builder /smartmontools-install/etc/ /etc/
COPY --from=builder /smartmontools-install/sbin/ /sbin/
COPY --from=builder /smartmontools-install/share/ /share/
