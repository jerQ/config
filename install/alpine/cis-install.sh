#!/bin/sh
# CIS-style Alpine install: partitions <disk> with separate /var, /var/tmp,
# /var/log, /var/log/audit and /home logical volumes (optionally on LUKS2),
# mounts them under /mnt with CIS mount options, then runs
# `setup-alpine -f <answerfile>` (DISKOPTS="-m sys /mnt") to install onto them.
#
# Run as root from the Alpine live ISO:
#   sh cis-install.sh [--encrypt] <disk> <answerfile|URL>
#
# Volume sizes can be overridden from the environment, e.g. HOME_SIZE=50G.
# The rest of the volume group is left free for `lvextend -r` later.
set -eu

ROOT_SIZE=${ROOT_SIZE:-8G}
VAR_SIZE=${VAR_SIZE:-4G}
VARLOG_SIZE=${VARLOG_SIZE:-2G}
AUDIT_SIZE=${AUDIT_SIZE:-1G}
VARTMP_SIZE=${VARTMP_SIZE:-1G}
HOME_SIZE=${HOME_SIZE:-4G}
SWAP_SIZE=${SWAP_SIZE:-2G}
BOOT_SIZE_MIB=512
VG=vg0
MNT=/mnt

# GPT partition type GUIDs
GUID_ESP=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
GUID_BIOS=21686148-6449-6E6F-744E-656564454649
GUID_LINUX=0FC63DAF-8483-4772-8E79-3D69D8477DE4
GUID_LVM=E6D6D379-F507-44C2-A23C-238F2A3DF928
GUID_LUKS=CA7D7CCB-63ED-4C53-861C-1742536059CC

step="start"
encrypt=0
crypt_opened=0

die() { echo "ERROR: $*" >&2; exit 1; }
info() { step="$*"; printf '\n==> %s\n' "$*"; }
on_exit() {
    rc=$?
    [ "$rc" -eq 0 ] || echo "FAILED during: $step (exit $rc). /mnt and $VG may still be mounted/active." >&2
}
trap on_exit EXIT

usage() {
    echo "usage: sh $0 [--encrypt] <disk> <answerfile|URL>" >&2
    exit 1
}

# /dev/sda -> /dev/sda1, /dev/nvme0n1 -> /dev/nvme0n1p1
part() {
    case "$1" in
        *[0-9]) echo "${1}p$2" ;;
        *) echo "$1$2" ;;
    esac
}

# 8G -> 8192, 512M -> 512
to_mib() {
    case "$1" in
        *[Gg]) echo $(( ${1%?} * 1024 )) ;;
        *[Mm]) echo "${1%?}" ;;
        *) die "size '$1' must end in G or M" ;;
    esac
}

wait_for() {
    i=0
    while [ ! -b "$1" ]; do
        i=$((i + 1))
        [ "$i" -le 20 ] || die "device $1 did not appear"
        mdev -s 2>/dev/null || true
        sleep 0.5
    done
}

# ---------------------------------------------------------------- arguments
[ "${1:-}" = "--encrypt" ] && { encrypt=1; shift; }
[ $# -eq 2 ] || usage
disk=$1
answers=$2

# ---------------------------------------------------------------- pre-flight
info "Pre-flight checks"
[ "$(id -u)" -eq 0 ] || die "run as root"
command -v setup-alpine >/dev/null || die "setup-alpine not found: run this from the Alpine live ISO"
[ -b "$disk" ] || die "$disk is not a block device"
if grep -q "^$disk" /proc/mounts; then die "$disk (or a partition on it) is mounted"; fi
if grep -q " $MNT " /proc/mounts; then die "$MNT is already mounted"; fi
case "$answers" in
    http://*|https://*)
        # Fetch once, so this script can read LOCALEOPTS from it too
        wget -q -O /tmp/answers.conf "$answers" || die "could not download $answers"
        answers=/tmp/answers.conf ;;
    *) [ -f "$answers" ] || die "answer file $answers not found" ;;
esac
# setup-alpine has no locale step: LOCALEOPTS is applied after the install
locale=$(sed -n 's/^LOCALEOPTS="\{0,1\}\([^"]*\)"\{0,1\}[[:space:]]*$/\1/p' "$answers" | tail -n 1)
case "$locale" in
    ''|none) locale= ;;
    *[!A-Za-z0-9_.@-]*) die "invalid LOCALEOPTS: $locale" ;;
esac

if [ -d /sys/firmware/efi ]; then firmware=uefi; else firmware=bios; fi

pkgs="sfdisk e2fsprogs dosfstools lvm2 blkid"
[ "$encrypt" -eq 1 ] && pkgs="$pkgs cryptsetup"
# The ISO's own repository may not carry these (the virt ISO doesn't), so
# fall back to an online mirror. Needs networking (setup-interfaces -ar).
# shellcheck disable=SC2086
if ! apk add --quiet $pkgs 2>/dev/null; then
    echo "Packages not on the ISO, adding an online mirror"
    setup-apkrepos -1 -c >/dev/null
    apk add --quiet $pkgs || die "could not install: $pkgs (is the network up? run setup-interfaces -ar)"
fi
modprobe dm-mod 2>/dev/null || true
[ "$encrypt" -eq 1 ] && { modprobe dm-crypt 2>/dev/null || true; }

if vgs "$VG" >/dev/null 2>&1; then
    die "volume group $VG already exists on this system; remove it first (vgchange -an $VG)"
fi

disk_mib=$(( $(blockdev --getsize64 "$disk") / 1024 / 1024 ))
need_mib=$(( BOOT_SIZE_MIB + 2 \
    + $(to_mib "$ROOT_SIZE") + $(to_mib "$VAR_SIZE") + $(to_mib "$VARLOG_SIZE") \
    + $(to_mib "$AUDIT_SIZE") + $(to_mib "$VARTMP_SIZE") + $(to_mib "$HOME_SIZE") \
    + $(to_mib "$SWAP_SIZE") + 256 ))
[ "$disk_mib" -ge "$need_mib" ] || die "$disk is ${disk_mib} MiB, need at least ${need_mib} MiB (or lower the *_SIZE values)"

echo "Firmware:   $firmware"
echo "Encryption: $([ "$encrypt" -eq 1 ] && echo LUKS2 || echo none)"
echo "Disk:       $disk (${disk_mib} MiB, ${need_mib} MiB used, rest left free in $VG)"
lsblk "$disk" 2>/dev/null || fdisk -l "$disk" 2>/dev/null || true
printf '\nALL DATA ON %s WILL BE DESTROYED. Type YES to continue: ' "$disk"
read -r confirm
[ "$confirm" = "YES" ] || die "aborted"

# ---------------------------------------------------------------- partitions
info "Partitioning $disk (GPT, $firmware)"
if [ "$encrypt" -eq 1 ]; then pv_type=$GUID_LUKS; else pv_type=$GUID_LVM; fi
if [ "$firmware" = uefi ]; then
    printf 'label: gpt\nsize=%sMiB, type=%s, name=esp\ntype=%s, name=system\n' \
        "$BOOT_SIZE_MIB" "$GUID_ESP" "$pv_type" |
        sfdisk --quiet --wipe always --wipe-partitions always "$disk"
    boot_part=$(part "$disk" 1)
    pv_part=$(part "$disk" 2)
else
    printf 'label: gpt\nsize=1MiB, type=%s, name=bios\nsize=%sMiB, type=%s, name=boot\ntype=%s, name=system\n' \
        "$GUID_BIOS" "$BOOT_SIZE_MIB" "$GUID_LINUX" "$pv_type" |
        sfdisk --quiet --wipe always --wipe-partitions always "$disk"
    boot_part=$(part "$disk" 2)
    pv_part=$(part "$disk" 3)
fi
wait_for "$boot_part"
wait_for "$pv_part"

# ---------------------------------------------------------------- encryption
pv=$pv_part
if [ "$encrypt" -eq 1 ]; then
    info "Encrypting $pv_part (LUKS2) - choose a passphrase"
    cryptsetup luksFormat --type luks2 --batch-mode --verify-passphrase "$pv_part"
    info "Opening $pv_part"
    cryptsetup open "$pv_part" root
    crypt_opened=1
    pv=/dev/mapper/root
fi

# ---------------------------------------------------------------- LVM
info "Creating LVM volume group $VG"
pvcreate --quiet -ff -y "$pv"
vgcreate --quiet "$VG" "$pv"
lvcreate --quiet -y -L "$ROOT_SIZE"   -n lv_root   "$VG"
lvcreate --quiet -y -L "$VAR_SIZE"    -n lv_var    "$VG"
lvcreate --quiet -y -L "$VARLOG_SIZE" -n lv_varlog "$VG"
lvcreate --quiet -y -L "$AUDIT_SIZE"  -n lv_audit  "$VG"
lvcreate --quiet -y -L "$VARTMP_SIZE" -n lv_vartmp "$VG"
lvcreate --quiet -y -L "$HOME_SIZE"   -n lv_home   "$VG"
lvcreate --quiet -y -L "$SWAP_SIZE"   -n lv_swap   "$VG"
mdev -s 2>/dev/null || true
for lv in root var varlog audit vartmp home swap; do wait_for "/dev/$VG/lv_$lv"; done

# ---------------------------------------------------------------- filesystems
info "Creating filesystems"
for lv in root var varlog audit vartmp home; do
    mkfs.ext4 -q -F -L "$lv" "/dev/$VG/lv_$lv"
done
mkswap -L swap "/dev/$VG/lv_swap" >/dev/null
if [ "$firmware" = uefi ]; then
    mkfs.vfat -F 32 -n ESP "$boot_part" >/dev/null
    boot_fs=vfat
    boot_opts=nodev,nosuid,noexec,umask=0077
else
    mkfs.ext4 -q -F -L boot "$boot_part"
    boot_fs=ext4
    boot_opts=nodev,nosuid,noexec
fi

# ---------------------------------------------------------------- mounts
# setup-fstab copies these options from /proc/mounts into the new fstab.
info "Mounting under $MNT with CIS mount options"
mnt() { # <device> <mountpoint> <fstype> <options>
    mkdir -p "$MNT$2"
    mount -t "$3" -o "$4" "$1" "$MNT$2"
}
mnt "/dev/$VG/lv_root"   /              ext4 defaults
mnt "/dev/$VG/lv_var"    /var           ext4 nodev,nosuid
mnt "/dev/$VG/lv_varlog" /var/log       ext4 nodev,nosuid,noexec
mnt "/dev/$VG/lv_audit"  /var/log/audit ext4 nodev,nosuid,noexec
mnt "/dev/$VG/lv_vartmp" /var/tmp       ext4 nodev,nosuid,noexec
mnt "/dev/$VG/lv_home"   /home          ext4 nodev,nosuid
mnt "$boot_part"         /boot          "$boot_fs" "$boot_opts"
chmod 1777 "$MNT/var/tmp"
mkdir -p "$MNT/tmp" && chmod 1777 "$MNT/tmp"
chmod 0700 "$MNT/var/log/audit"

# ---------------------------------------------------------------- install
info "Running setup-alpine with $answers"
# GPT on BIOS needs GRUB (syslinux would be picked for a dos label).
export BOOTLOADER=grub DISKLABEL=gpt
setup-alpine -f "$answers"

[ -f "$MNT/etc/fstab" ] || die "setup-alpine did not install to $MNT (is DISKOPTS=\"-m sys /mnt\" set in the answer file?)"

# ---------------------------------------------------------------- fstab fixes
info "Finishing fstab"
fstab=$MNT/etc/fstab
# setup-disk appends /tmp as tmpfs without noexec
sed -i -E 's|^(tmpfs[[:space:]]+/tmp[[:space:]]+tmpfs[[:space:]]+)[^[:space:]]+|\1nosuid,nodev,noexec|' "$fstab"
grep -qE '^[^#]*[[:space:]]/tmp[[:space:]]' "$fstab" ||
    printf 'tmpfs\t/tmp\ttmpfs\tnosuid,nodev,noexec\t0 0\n' >> "$fstab"
grep -qE '^[^#]*[[:space:]]/dev/shm[[:space:]]' "$fstab" ||
    printf 'shm\t/dev/shm\ttmpfs\tnosuid,nodev,noexec\t0 0\n' >> "$fstab"
swap_uuid=$(blkid -s UUID -o value "/dev/$VG/lv_swap")
grep -q "$swap_uuid" "$fstab" ||
    printf 'UUID=%s\tnone\tswap\tdefaults\t0 0\n' "$swap_uuid" >> "$fstab"
[ -f "$MNT/boot/grub/grub.cfg" ] && chmod 0600 "$MNT/boot/grub/grub.cfg"
echo "--- $fstab"
cat "$fstab"

# ---------------------------------------------------------------- chroot fixes
mount --bind /dev "$MNT/dev"
# setup-disk only enables swap when it created the swap itself
chroot "$MNT" rc-update add swap boot >/dev/null

# Ansible (the next step after first boot) needs Python on the target
info "Installing python3 for Ansible"
apk add --quiet --root "$MNT" python3 || die "could not install python3"

# musl has no locale data of its own: musl-locales provides it, and
# /etc/profile.d sets LANG for login shells
if [ -n "$locale" ]; then
    info "Setting locale $locale"
    apk add --quiet --root "$MNT" musl-locales || die "could not install musl-locales"
    [ -f "$MNT/usr/share/i18n/locales/musl/$locale" ] ||
        echo "WARNING: musl-locales has no $locale, setting LANG anyway" >&2
    printf 'export LANG=%s\n' "$locale" > "$MNT/etc/profile.d/20locale.sh"
fi

# setup-user is non-interactive when the answer file names the user, so no
# password gets set. The user needs one for console login and doas.
for home in "$MNT"/home/*; do
    u=${home##*/}
    grep -q "^$u:" "$MNT/etc/passwd" || continue
    info "Set a password for $u (console login and doas)"
    until chroot "$MNT" passwd "$u"; do echo "Try again."; done
done
umount "$MNT/dev"

# ---------------------------------------------------------------- cleanup
info "Unmounting"
sync
# busybox umount has no -R: unmount everything below $MNT, deepest first
awk -v m="$MNT" '$2 == m || index($2, m "/") == 1 { print $2 }' /proc/mounts |
    sort -r | while read -r mp; do umount "$mp"; done
vgchange --quiet -an "$VG" >/dev/null
[ "$crypt_opened" -eq 1 ] && cryptsetup close root

step="done"
cat <<EOF

Install finished. Remove the ISO and reboot.
After first boot, harden the system with:
  ansible-playbook -i inventory.ini alpine/site.yml -e hardening=true
EOF
