This is a Rocky Linux 8 minimal container image similar to Fedora-minimal or UBI.

## How rootfs is created?
```bash
docker run --rm --privileged -v "$PWD:/build:z" \
    -e BUILD_KICKSTART=rocky8-minimal.ks \
    -e BUILD_ROOTFS=rocky8-minimal.tar.xz \
    quay.io/krestomatio/rootfs-creator
```

## How image is built?
```bash
docker build .
```

## Repository
This image is built from [this repo](https://github.com/krestomatio/container_builder/tree/master/rocky8-minimal)
