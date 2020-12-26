# Source: https://github.com/qemu/qemu
# Ref: https://wiki.qemu.org/Hosts/Linux
FROM python:3.7-stretch AS qemu-build-base
RUN set -ex;\
    apt-get update;\
    apt-get install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev \
            git-email \
            libaio-dev libbluetooth-dev libbrlapi-dev libbz2-dev \
            libcap-dev libcap-ng-dev libcurl4-gnutls-dev libgtk-3-dev \
            libibverbs-dev  libncurses5-dev libnuma-dev \
            librbd-dev librdmacm-dev \
            libsasl2-dev libsdl1.2-dev libseccomp-dev libsnappy-dev libssh2-1-dev \
            libvde-dev libvdeplug-dev  libxen-dev liblzo2-dev \
            valgrind xfslibs-dev \
            libnfs-dev libiscsi-dev;

WORKDIR /
RUN set -ex;\
    git clone https://github.com/qemu/qemu.git qemu;\
    cd qemu;\
    echo "Install qemu version 4.2.50";\
    git checkout -q 7afee874f1b27abc998b8b747d16b77cb6398716;

WORKDIR /qemu/build
RUN set -ex;\
    ../configure --target-list=mips64el-linux-user,aarch64-linux-user --disable-werror --static;
RUN set -ex;\
    make -j8;

FROM busybox
WORKDIR /qemu
LABEL maintainer="devops@inspur.com"
ENV QEMU_VERSION="4.2.50"
COPY --from=qemu-build-base /qemu/build/mips64el-linux-user/qemu-mips64el /qemu/qemu-mips64el-static
COPY --from=qemu-build-base /qemu/build/aarch64-linux-user/qemu-aarch64 /qemu/qemu-aarch64-static
