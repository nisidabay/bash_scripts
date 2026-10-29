#!/usr/bin/env bash
#
# Install Arch Linux ARM on Raspberry Pi SD card.
#
# Dependencies: parted, mkfs.vfat, mkfs.ext4, bsdtar, wget

SOURCE=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
MNTDIR=/mnt/arch
TEMPDIR=/tmp/raspiarch
TARBALL=raspiarch.tar.gz

if [[ ! -f "${TEMPDIR}/${TARBALL}" ]]; then
    echo "### Init ###"
    if [[ -d "${TEMPDIR}" ]]; then
        rm -rf "${TEMPDIR}"
    fi
    if [[ -d "${MNTDIR}" ]]; then
        rm -rf "${MNTDIR}"
    fi
    mkdir "${TEMPDIR}"
    mkdir "${MNTDIR}"
    echo "### Get tarball ###"
    mkdir -p ${TEMPDIR}
    wget ${SOURCE} -O ${TEMPDIR}/${TARBALL}
fi
echo "### Create filesystem ###"
parted /dev/sdc --script -- mklabel msdos
parted /dev/sdc --script -- mkpart primary fat32 1 256
parted /dev/sdc --script -- mkpart primary ext4 256 100%
parted /dev/sdc --script -- set 1 boot on
parted /dev/sdc --script print
sleep 5
mkfs.vfat -F32 /dev/sdc1
mkfs.ext4 -F /dev/sdc2
echo "### Copy tarball  content"
mkdir -p ${MNTDIR}/{boot,root}
mount /dev/sdc1 ${MNTDIR}/boot
mount /dev/sdc2 ${MNTDIR}/root
bsdtar -xpf ${TEMPDIR}/${TARBALL} -C ${MNTDIR}/root
sync
# tar xvzf ${TEMPDIR}/${TARBALL} -C ${MNTDIR}/root
mv ${MNTDIR}/root/boot/* ${MNTDIR}/boot
sleep 5
echo "### Change mmcblk ###"
sed -i 's/mmcblk0/mmcblk1/g' ${MNTDIR}/root/etc/fstab
umount ${MNTDIR}/boot
umount ${MNTDIR}/root
echo "### Cleaning ###"
rm -rf ${MNTDIR}
rm -rf ${TEMPDIR}
