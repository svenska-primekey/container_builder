# This is a minimal CentOS kickstart for containers.
# It will not produce a bootable system
# To use this kickstart, run the following command
# livemedia-creator --make-tar --ks="centos8-stream-minimal.ks" --image-name="centos8-stream-minimal.tar.xz" --no-virt
#
# Based on:
# https://github.com/CentOS/sig-cloud-instance-build/blob/master/docker/centos-8.ks
# https://pagure.io/fedora-kickstarts/raw/master/f/fedora-container-base-minimal.ks
# https://catalog.redhat.com/software/containers/detail/5c359a62bed8bd75a2c3fba8

# Basic setup information
url --url http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/
bootloader --disabled
timezone --isUtc --nontp Etc/UTC
rootpw --lock --iscrypted locked
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
network  --bootproto=dhcp --device=link --activate
network  --hostname=localhost.localdomain
skipx
reboot

# Disk setup
zerombr
clearpart --all --initlabel
autopart --noboot --nohome --noswap --nolvm --fstype=ext4

# Package setup
%packages --excludedocs --instLangs=en --nocore --excludeWeakdeps
centos-stream-release
centos-stream-repos
bash
coreutils-single
glibc-minimal-langpack
libusbx
microdnf
rootfiles
-crypto-policies-scripts
-dosfstools
-e2fsprogs
-fuse-libs
-gnupg2-smime
-grubby
-kernel
-libss
-pinentry
-qemu-guest-agent
-shared-mime-info
-trousers
-xfsprogs
-xkeyboard-config
%end

%addon com_redhat_kdump --disable --reserve-mb='128'

%end

%post --erroronfail --log=/root/anaconda-post.log
# container customizations inside the chroot
set -eux

# Limit languages to help reduce size.
LANG="C.utf8"
echo "%_install_langs $LANG" > /etc/rpm/macros.image-language-conf
echo "LANG=C.utf8" > /etc/locale.conf

# https://bugzilla.redhat.com/show_bug.cgi?id=1400682
echo "Import RPM GPG key"
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

# Remove network configuration files leftover from anaconda installation
# https://bugzilla.redhat.com/show_bug.cgi?id=1713089
rm -f /etc/sysconfig/network-scripts/ifcfg-*

echo "# fstab intentionally empty for containers" > /etc/fstab

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

%end

%post --logfile /root/anaconda-post.log --erroronfail
# remove some random help txt files
rm -fv usr/share/gnupg/help*.txt

# Pruning random things
rm usr/lib/rpm/rpm.daily
rm -rfv usr/lib64/nss/unsupported-tools/  # unsupported

# Statically linked crap
rm -fv usr/sbin/{glibc_post_upgrade.x86_64,sln}
ln usr/bin/ln usr/sbin/sln

# Remove some dnf info
rm -rfv /var/lib/dnf

# don't need icons
rm -rfv /usr/share/icons/*

#some random not-that-useful binaries
rm -fv /usr/bin/pinky

# we lose presets by removing /usr/lib/systemd but we do not care
rm -rfv /usr/lib/systemd

# if you want to change the timezone, bind-mount it from the host or reinstall tzdata
rm -fv /etc/localtime
mv /usr/share/zoneinfo/UTC /etc/localtime
rm -rfv  /usr/share/zoneinfo

# Final pruning
rm -rfv /var/cache/* /var/log/* /tmp/*

# remove the original RHEL8 EULA
# TODO: This affects the integrity of the installed rpm. Find a better way.
rm -f /usr/share/redhat-release/EULA
%end

%post --nochroot --erroronfail --log=/mnt/sysimage/root/anaconda-post-nochroot.log
set -eux

# https://bugzilla.redhat.com/show_bug.cgi?id=1343138
# Fix /run/lock breakage since it's not tmpfs in docker
# This unmounts /run (tmpfs) and then recreates the files
# in the /run directory on the root filesystem of the container
# NOTE: run this in nochroot because "umount" does not exist in chroot
umount /mnt/sysimage/run
# The file that specifies the /run/lock tmpfile is
# /usr/lib/tmpfiles.d/legacy.conf, which is part of the systemd
# rpm that isn't included in this image. We'll create the /run/lock
# file here manually with the settings from legacy.conf
# NOTE: chroot to run "install" because it is not in anaconda env
chroot /mnt/sysimage install -d /run/lock -m 0755 -o root -g root

# workarount error /mnt/sysimage/run cannot be unmounted
mount -t bind -o bind,defaults /run /mnt/sysimage/run

# See: https://bugzilla.redhat.com/show_bug.cgi?id=1051816
# NOTE: run this in nochroot because "find" does not exist in chroot
KEEPLANG=en_US
for dir in locale i18n; do
    find /mnt/sysimage/usr/share/${dir} -mindepth  1 -maxdepth 1 -type d -not \( -name "${KEEPLANG}" -o -name POSIX \) -exec rm -rfv {} +
done

%end
