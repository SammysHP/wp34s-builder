FROM ubuntu:22.04 AS base

RUN <<EOF
  set -eux
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    7zip \
    ca-certificates \
    gcc-multilib \
    gnupg \
    make \
    wget
  rm -rf /var/lib/apt/lists/*
EOF

ARG WINE_BRANCH="stable"
RUN <<EOF
  set -eux
  wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -
  echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list
  dpkg --add-architecture i386
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends winehq-${WINE_BRANCH}
  rm -rf /var/lib/apt/lists/*
  wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
  chmod +x /usr/bin/winetricks
EOF

ENV WINEDEBUG=-all



FROM base AS yagarto

RUN wget -nv -O yagarto_install.exe https://sourceforge.net/projects/yagarto/files/YAGARTO%20for%20Windows/20110429/yagarto-bu-2.21_gcc-4.6.0-c-c%2B%2B_nl-1.19.0_gdb-7.2_eabi_20110429.exe/download

RUN mkdir yagarto && cd yagarto \
  && 7zz x ../yagarto_install.exe

COPY --chmod=0755 <<"EOF" /yagarto/bin/arm-none-eabi-wine
#!/bin/sh
exec wine /yagarto/bin/"${0##*/}" "$@"
EOF

RUN <<EOF
  set -eux
  ln -s arm-none-eabi-wine /yagarto/bin/arm-none-eabi-gcc
  ln -s arm-none-eabi-wine /yagarto/bin/arm-none-eabi-ar
  ln -s arm-none-eabi-wine /yagarto/bin/arm-none-eabi-nm
  ln -s arm-none-eabi-wine /yagarto/bin/arm-none-eabi-objcopy
  ln -s arm-none-eabi-wine /yagarto/bin/arm-none-eabi-ranlib
EOF



FROM base AS deploy

COPY --from=yagarto /yagarto /yagarto
ENV PATH="/yagarto/bin:${PATH}"
