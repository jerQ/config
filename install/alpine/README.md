# Alpine CIS install

Unattended-ish Alpine install with CIS-style partitioning. Alpine's own
installer (`setup-disk`) can only create boot, swap and root. So
`cis-install.sh` partitions the disk and mounts the filesystems with CIS mount
options under `/mnt`. Then it runs `setup-alpine -f <answerfile>` with
`DISKOPTS="-m sys /mnt"`, which installs onto that tree and copies each
mount's options into the new `/etc/fstab`.

## Files

| File | Purpose |
|------|---------|
| `cis-install.sh` | Partitions, (optionally) encrypts, creates LVM volumes, mounts, runs `setup-alpine`, fixes fstab |
| `answers.example.conf` | Answer file template with placeholders. Copy it to `answers.conf`, which git ignores. |

## Layout

GPT on both UEFI and BIOS (detected automatically). LVM volume group `vg0`, optionally on LUKS2.

| Mount | Device | Default size | Options | CIS |
|-------|--------|--------------|---------|-----|
| `/boot` | EFI system partition (UEFI, vfat) or ext4 partition (BIOS) | 512M | `nodev,nosuid,noexec` (+`umask=0077` on vfat) | – |
| `/` | `lv_root` | 8G | defaults | – |
| `/var` | `lv_var` | 4G | `nodev,nosuid` | separate `/var` |
| `/var/log` | `lv_varlog` | 2G | `nodev,nosuid,noexec` | separate `/var/log` |
| `/var/log/audit` | `lv_audit` | 1G | `nodev,nosuid,noexec` | separate `/var/log/audit` |
| `/var/tmp` | `lv_vartmp` | 1G | `nodev,nosuid,noexec` | separate `/var/tmp` |
| `/home` | `lv_home` | 4G | `nodev,nosuid` | separate `/home` |
| `/tmp` | tmpfs | – | `nodev,nosuid,noexec` | separate `/tmp` |
| `/dev/shm` | tmpfs | – | `nodev,nosuid,noexec` | `/dev/shm` options |
| swap | `lv_swap` | 2G | – | – |

You need a disk of about 24 GB or more. Everything beyond the volumes above stays free in `vg0`, so you can grow any volume later:

```sh
doas lvextend -r -L +10G vg0/lv_home
```

Override the sizes from the environment, e.g. `HOME_SIZE=50G VAR_SIZE=20G sh cis-install.sh …`.

On BIOS machines the disk also gets a 1M BIOS boot partition, which GRUB needs on GPT. `/boot` is never encrypted, so GRUB doesn't need LUKS support.

The answer file also sets the installed system's kernel command line: `lsm=…,apparmor audit=1 audit_backlog_limit=8192`.

## Usage

1. Copy the template and fill in the placeholders:

   ```sh
   cp answers.example.conf answers.conf   # git-ignored
   ```

2. Boot the Alpine **standard** or **extended** ISO and log in as `root`.
3. Get a network connection and download the script:

   ```sh
   setup-interfaces -ar
   wget https://raw.githubusercontent.com/jerQ/config/main/install/alpine/cis-install.sh
   ```

4. Get the answer file onto the machine. Either serve it from your workstation with `python3 -m http.server` (run in this directory) and pass its URL, or copy it on a USB stick.
5. Run the installer:

   ```sh
   sh cis-install.sh /dev/sda http://<WORKSTATION_IP>:8000/answers.conf
   sh cis-install.sh --encrypt /dev/nvme0n1 answers.conf     # with LUKS2
   ```

   It asks you to type `YES` before wiping the disk. With `--encrypt` it then asks for the LUKS passphrase. `setup-alpine` asks for the root password. At the end, the script asks for the user's password: `setup-user` skips it when the answer file names the user, but doas needs it.
6. Remove the ISO and reboot. With `--encrypt`, you type the passphrase at every boot.
7. Harden the installed system (AppArmor, auditd, sysctl, firewall, SSH, …):

   ```sh
   ansible-playbook -i inventory.ini alpine/site.yml -e hardening=true
   ```

## Not covered

- **GRUB password** (CIS bootloader password). It needs a secret, so set it by hand if you want it.
- **AIDE** (file integrity). It's only in Alpine's testing repository.
- **Everything after first boot** (services, auditd rules, sysctl, firewall, SSH). `ansible/alpine/hardening.yml` does that.
