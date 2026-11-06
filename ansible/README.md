# ansible

Playbooks for system provisioning, split per OS. Pick the directory that matches the machine — there's no OS detection, so the playbooks contain no `when:` conditions.

## Layout

| Path | Description |
|------|-------------|
| `fedora/` / `debian/` / `alpine/` | OS-specific playbooks (`dnf` / `apt` / `apk`) |
| `common/` | OS-independent playbooks, also imported by the OS-specific ones |

| Playbook | Description |
|----------|-------------|
| `<os>/site.yml` | Run everything in order: update → packages → gui → neovim → starship → setup, then hardening if `-e hardening=true` is passed |
| `<os>/update.yml` | Upgrade all packages |
| `<os>/packages.yml` | Install common CLI tools |
| `<os>/gui.yml` | Install GUI apps (`keepassxc`) — skip on headless machines |
| `<os>/neovim.yml` | Install Neovim, `ripgrep`, `fzf`, `clangd` and `pip` from the distro repos, then run `common/lsp.yml` |
| `<os>/hardening.yml` | Optional security hardening (MAC, auditd, sysctl, firewall, SSH, fail2ban, auto-updates). Skipped in `site.yml` unless `-e hardening=true` is passed. See [Hardening](#hardening) |
| `common/lsp.yml` | Install `pyright` (pip) and `lua-language-server` (GitHub release, x86_64 or aarch64) |
| `common/starship.yml` | Install `starship` into `~/.local/bin` via the official script (no sudo) |
| `common/setup.yml` | Create `~/Devel`, clone config repo, and run `install.sh` (no sudo) |
| `common/audit-hardening.rules.j2` | Audit rules template shared by the three `hardening.yml` playbooks |

## Usage

Run everything:

```sh
ansible-playbook -i inventory.ini fedora/site.yml
ansible-playbook -i inventory.ini debian/site.yml
ansible-playbook -i inventory.ini alpine/site.yml
ansible-playbook -i inventory.ini debian/site.yml -e hardening=true   # also run hardening.yml
```

Or pick only what you need (several playbooks can be passed at once):

```sh
ansible-playbook -i inventory.ini debian/update.yml
ansible-playbook -i inventory.ini debian/packages.yml debian/neovim.yml common/setup.yml
```

## packages.yml

**CLI tools:** `git`, `gh`, `curl`, `fzf`, `fd-find`, `zoxide`, `ripgrep`, `tree`, `tmux`, `bat`, `cmake`, `make`, `gcc`, `autoconf`, `automake`, `golang`, `cargo`, `python3`, `ansible`, `podman`

A few package names differ between the OSes (e.g. `gcc-c++`/`g++`, `golang`/`golang-go`). `doctl` is Fedora-only — it isn't packaged in the standard Debian/Ubuntu apt repos and needs manual install there.

## neovim.yml

Neovim comes from the distro repos (current Fedora and Debian/Ubuntu releases ship a version new enough for `vim.pack`). The LSP servers used by `neovim-minimal/init.lua`:

- `clangd` — `clang-tools-extra` (Fedora) / `clangd` (Debian/Ubuntu) via the system package manager
- `pyright` — via `pip3 install` (`common/lsp.yml`)
- `lua_ls` — latest `lua-language-server` release binary from GitHub, extracted to `/usr/local/lua-language-server` and symlinked into `/usr/local/bin` (`common/lsp.yml`)

## Alpine

- Requires the `community.general` collection (`apk` and `npm` modules, `doas` become plugin): `ansible-galaxy collection install community.general`.
- Ansible needs `python3` on the target. `install/alpine/cis-install.sh` installs it; on other Alpine hosts run `doas apk add python3` first.
- Privilege escalation uses `doas` (Alpine's default), not `sudo`. Your user needs a `doas.conf` rule, e.g. `permit persist :wheel`. Pass `-K` if doas asks for a password.
- `packages.yml` also installs `bash`, which `install.sh` needs.
- `neovim.yml` doesn't use `common/lsp.yml`, because the upstream `lua-language-server` binaries and pyright's pip wrapper (which downloads node) are glibc-only. It installs `lua-language-server` from apk and `pyright` via npm instead.
- clangd is only packaged under a versioned name (`clangNN-extra-tools`). `clang_version` defaults to `22` (Alpine v3.24). Override it with `-e clang_version=NN` on other releases.

## Hardening

`<os>/hardening.yml` is optional. Run it on its own, or as part of `site.yml` with `-e hardening=true`; without that flag `site.yml` skips it. Each section is tagged, so you can apply only some of them:

```sh
ansible-playbook -i inventory.ini debian/hardening.yml --check --diff     # dry run first
ansible-playbook -i inventory.ini fedora/hardening.yml --tags sysctl,firewall
```

The same sections on every OS:

| Tag | What it does |
|-----|--------------|
| `audit` | Installs auditd and writes rules selected from [Neo23x0/auditd](https://github.com/Neo23x0/auditd) (`common/audit-hardening.rules.j2`). File watches (`audit_watches`, per OS): accounts, sudo/doas, PAM, SSH including `/root/.ssh`, audit config and log reads, sysctl, modules, init/services, bootloader, fstab, cron, package sources, shell profiles, library search path, network, firewall, MAC policy, time zone. A watch is skipped when its directory doesn't exist. Syscalls: module loading, kexec, swap, clock, mount, hostname, setuid/setgid bits (anyone), `chmod`/`chown`/xattr by users as themselves, ptrace, `process_vm_*`, `memfd_create`, bpf, `userfaultfd`, `io_uring_setup`, and every 32-bit syscall (`audit_32bit_abi: false` on hosts that run 32-bit software). Writes to `/usr`, `/bin` and `/boot` are not watched, since every package upgrade would flood the log. `audit_telemetry: true` adds exec, connect, failed access and delete events (high volume, for a SIEM). Sizes log retention in `auditd.conf`, and adds `audit=1 audit_backlog_limit=8192` to the kernel command line. Set `audit_immutable: true` to lock the rules until reboot. The section runs last, after the sections that create watched directories. |
| `sysctl` | `/etc/sysctl.d/90-hardening.conf`: kernel pointer and dmesg restrictions, BPF hardening, ptrace scope 1, protected links and FIFOs, no core dumps for setuid programs, and no redirects or source routing. User namespaces stay enabled for rootless podman. |
| `modules` | Blocks loading of unused network protocols and filesystems (`blacklisted_modules`). |
| `mounts` | `/dev/shm` mounted with `nosuid,nodev,noexec`. |
| `firewall` | Inbound blocked by default, except established connections, loopback, ICMP and the ports in `firewall_allowed_tcp` (default `[22]`). |
| `ssh` | sshd drop-in: no root login, keys only, `MaxAuthTries 3`. **Stops** if `~/.ssh/authorized_keys` is missing or empty, so it can't lock you out. |
| `fail2ban` | `sshd` jail. |
| `autoupdate` | Automatic package updates. Kernel updates still need a manual reboot. |

How each OS does it:

| | Alpine | Debian/Ubuntu | Fedora |
|---|---|---|---|
| Mandatory access control (MAC) | `apparmor`: installs AppArmor and turns it on with `lsm=…,apparmor` on the kernel command line (extlinux, GRUB or `cmdline.txt`). **Reboot required.** | `apparmor`: already on in the kernel. Installs the profiles and enables the service, and warns if the kernel has it off (e.g. Raspberry Pi OS). | `selinux`: makes sure SELinux is enforcing with the targeted policy. A reboot is needed only if it was disabled. |
| Setting `audit=1 audit_backlog_limit=8192` | Together with `lsm=` (`kernel_cmdline_args`), each argument only when missing | GRUB or `cmdline.txt` (`audit_kernel_args`), each argument only when missing | `grubby --update-kernel=ALL` (`audit_kernel_args`) |
| Audit watches | doas, apk, crontabs, OpenRC (`init.d`, `conf.d`, runlevels, `local.d`), nftables, AppArmor, musl's `ld-musl-*.path` | sudo, PAM, apt, cron, systemd, netplan/NetworkManager, nftables, AppArmor, `ld.so.*` | sudo, PAM, polkit, dnf, cron, systemd, `/etc/sysconfig`, NetworkManager, firewalld, SELinux, `ld.so.*` |
| Audit base rules | Written (`-D`, `-b 8192`, `-f 1`): the package has none | The package's own | Fedora's default `-a task,never` (turns off all syscall auditing) is replaced with the package's `10-base-config.rules` |
| Audit log retention | 15 × 50 MB, sized for the 1G `/var/log/audit` volume from `install/alpine` | 10 × 20 MB (usually on the root filesystem) | 10 × 20 MB (usually on the root filesystem) |
| Firewall | nftables (`/etc/nftables.nft`) | nftables (`/etc/nftables.conf`). Stops if ufw or firewalld is active. | firewalld: switches the default zone to `public` (the `FedoraWorkstation` zone opens ports 1025–65535) |
| fail2ban | reads `/var/log/messages`, bans through nftables | reads the systemd journal, bans through nftables | reads the systemd journal, bans through firewalld |
| Auto-updates | daily `apk upgrade` (everything) | `unattended-upgrades` (security only) | `dnf5-automatic` (`autoupdate_type: security`) |

Before you run it:

- Keep a second SSH session open while applying the `ssh` or `firewall` tags.
- If SSH runs on a non-default port, set `firewall_allowed_tcp`.
- Alpine and Debian: rootful podman containers need forwarding, so set `firewall_forward_policy: accept` on hosts that run them. On Fedora, firewalld handles podman itself.
- Fedora Workstation: switching to the `public` zone closes the high ports that, for example, KDE Connect and GSConnect use. To keep them, set `firewall_zone: FedoraWorkstation`.
- Raspberry Pi kernels may not have AppArmor built in. Check `/sys/kernel/security/lsm` after rebooting.

Check the result after a reboot:
- `cat /sys/kernel/security/lsm`, plus `aa-status` (AppArmor) or `getenforce` (SELinux)
- `auditctl -l` (rules) and `auditctl -s` (`lost` should stay 0)
- `nft list ruleset` (Alpine, Debian) or `firewall-cmd --list-all` (Fedora)
- `sshd -T | grep -E 'permitrootlogin|passwordauthentication'`
- `fail2ban-client status sshd`

### Variables

Override any of these with `-e`, in the inventory, or in `group_vars`/`host_vars`. Switches work from the command line too (`-e audit_telemetry=true`).

| Variable | Default | OS | Meaning |
|----------|---------|----|---------|
| `audit_immutable` | `false` | all | Lock the audit rules (`-e 2`) until the next reboot |
| `audit_telemetry` | `false` | all | Add exec, connect, failed access and delete events. High volume: only useful when logs are shipped to a SIEM |
| `audit_32bit_abi` | `true` | all | Log every 32-bit syscall. Turn off on hosts that run 32-bit software (Steam, Wine) |
| `audit_uid_min` | `1000` | all | First login UID, used by the rules about human activity |
| `audit_max_log_file` / `audit_num_logs` | `50` / `15` on Alpine, `20` / `10` elsewhere | all | Audit log size in MB, and how many logs to keep |
| `audit_space_left` / `audit_admin_space_left` | `150` / `75` | all | Free MB at which auditd warns via syslog / suspends logging |
| `audit_watches` | per OS | all | Files and directories to watch: `{ path, key, dir: true, perm: rwa }` (`dir` and `perm` optional, `perm` defaults to `wa`) |
| `audit_kernel_args` | `[audit=1, audit_backlog_limit=8192]` | Debian, Fedora | Kernel arguments for audit |
| `lsm_list`, `kernel_cmdline_args` | AppArmor LSM list; `lsm=…`, `audit=1`, `audit_backlog_limit=8192` | Alpine | Kernel arguments for AppArmor and audit |
| `blacklisted_modules` | `dccp, sctp, rds, tipc, cramfs, freevxfs, jffs2, hfs, hfsplus` | all | Kernel modules that can't be loaded |
| `firewall_allowed_tcp` | `[22]` | all | Inbound TCP ports to open |
| `firewall_forward_policy` | `drop` | Alpine, Debian | `accept` on hosts running rootful podman |
| `firewall_zone` | `public` | Fedora | firewalld default zone |
| `fail2ban_bantime` / `fail2ban_findtime` / `fail2ban_maxretry` | `1h` / `10m` / `5` | all | sshd jail |
| `autoupdate_type` | `security` | Fedora | `security` or `default` (all updates) for dnf5-automatic |

### Reading the audit log

Every rule has a key. Search by key, e.g. who changed the sudo or doas config, or who set a setuid bit:

```sh
ausearch -k privilege -i
ausearch -k setuid -i --start today
aureport -k --summary          # events per key
```

| Keys | What they cover |
|------|-----------------|
| `identity`, `privilege`, `login`, `pam`, `sshd`, `rootkey` | Accounts, sudo/doas, login and PAM config, SSH config and host keys, root's SSH keys |
| `auditlog`, `auditconfig` | Reads of the audit logs, changes to the audit config |
| `sysctl`, `modprobe`, `modules`, `kexec`, `swap` | Kernel parameters, module config and loading, kexec, swap |
| `init`, `systemd`, `bootloader`, `fstab`, `udev`, `mdev`, `sysconfig` | Boot, services and devices |
| `cron`, `apk` / `apt` / `dnf` | Scheduled jobs, package sources |
| `shell_profiles`, `libpath` | Shell startup files, library search path (`ld.so.*`, musl's `ld-musl-*.path`) |
| `network`, `hostname`, `firewall`, `mac_policy`, `time`, `localtime`, `mount` | Network, firewall and MAC config, clock and time zone, mounts |
| `setuid`, `perm_mod` | setuid/setgid bits set by anyone; permission, owner and xattr changes by users as themselves |
| `tracing`, `process_vm`, `anon_file_create`, `bpf`, `userfaultfd`, `io_uring`, `32bit_abi` | Attack techniques: ptrace, cross-process memory access, in-memory execution (`memfd_create`), eBPF, exploitation primitives, 32-bit syscalls |
| `process_creation`, `network_connect_4`, `network_connect_6`, `file_access`, `delete` | Only with `audit_telemetry: true` |

Writes to `/usr`, `/bin` and `/boot` aren't audited, because every package upgrade would flood the log. To check installed files against the package database, use `apk audit --system` (Alpine), `debsums -c` (Debian, package `debsums`) or `rpm -Va` (Fedora).

### Tested on

- **Alpine 3.24**, installed with `install/alpine/cis-install.sh` (UEFI + LUKS, and BIOS), x86_64
- **Debian 13** and **Fedora 45** cloud images, x86_64

Each one got two runs (the second changes nothing), a reboot, then the checks above. On aarch64 (Raspberry Pi), only the generated audit rules were checked: they load.

### Testing in a VM

The Debian and Fedora cloud images configure themselves with cloud-init, which can read its config from a plain HTTP server, so no ISO is needed:

```sh
mkdir -p seed/debian
printf 'instance-id: test\nlocal-hostname: debian-test\n' > seed/debian/meta-data
cat > seed/debian/user-data <<'END'
#cloud-config
users:
  - name: <USERNAME>
    groups: [sudo]          # wheel on Fedora
    shell: /bin/bash
    lock_passwd: false
    plain_text_passwd: <TEST_PASSWORD>
    ssh_authorized_keys: ["<SSH_PUBLIC_KEY>"]
END
(cd seed && python3 -m http.server 8766 --bind 127.0.0.1) &

qemu-img create -f qcow2 -F qcow2 -b debian-13-genericcloud-amd64.qcow2 debian.qcow2 12G
qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 -display none \
  -drive file=debian.qcow2,if=virtio \
  -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2223-:22 -device virtio-net-pci,netdev=n0 \
  -smbios 'type=1,serial=ds=nocloud;s=http://10.0.2.2:8766/debian/'
```

Then point an inventory at `127.0.0.1`, port `2223`, and run the playbook with `-K`. For Alpine, boot the ISO in QEMU and run `cis-install.sh`; see [install/alpine/README.md](../install/alpine/README.md#testing-in-a-vm).
