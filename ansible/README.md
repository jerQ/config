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

A few package names differ between the two (e.g. `gcc-c++`/`g++`, `golang`/`golang-go`). `doctl` is Fedora-only — it isn't packaged in the standard Debian/Ubuntu apt repos and needs manual install there.

## neovim.yml

Neovim comes from the distro repos (current Fedora and Debian/Ubuntu releases ship a version new enough for `vim.pack`). The LSP servers used by `neovim-minimal/init.lua`:

- `clangd` — `clang-tools-extra` (Fedora) / `clangd` (Debian/Ubuntu) via the system package manager
- `pyright` — via `pip3 install` (`common/lsp.yml`)
- `lua_ls` — latest `lua-language-server` release binary from GitHub, extracted to `/usr/local/lua-language-server` and symlinked into `/usr/local/bin` (`common/lsp.yml`)

## Alpine

- Requires the `community.general` collection (`apk` and `npm` modules, `doas` become plugin): `ansible-galaxy collection install community.general`.
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
| `audit` | Installs auditd and adds watch rules: identity files, sudo/doas config, sshd config, package sources, cron/periodic jobs, module loading, clock changes, mount, hostname (Alpine watches more; see below). Adds `audit=1` to the kernel command line. Set `audit_immutable: true` to lock the rules until reboot. |
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
| Setting `audit=1` | Included in the AppArmor kernel command line change | GRUB or `cmdline.txt` | `grubby --update-kernel=ALL` |
| Audit rules | Extended set adapted from [Neo23x0/auditd](https://github.com/Neo23x0/auditd): watches on Alpine/OpenRC paths (doas, apk, crontabs, `/etc/init.d`, `conf.d`, runlevels, nftables, AppArmor, musl's `ld-musl-*.path`), plus kexec, swap, user `chmod`/`chown`/xattr changes, ptrace, `memfd_create`, bpf, `userfaultfd`, `io_uring_setup` and a 32-bit syscall catch-all. `audit_telemetry: true` adds exec, connect, failed access and delete events (high volume). Adds base rules (`-D`, `-b 8192`, `-f 1`), which the package lacks, and keeps 15 × 50 MB of logs. | Kept | Fedora's default `-a task,never` (turns off all syscall auditing) is replaced with the package's `10-base-config.rules` |
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
- `auditctl -l`
- `nft list ruleset` (Alpine, Debian) or `firewall-cmd --list-all` (Fedora)
- `sshd -T | grep -E 'permitrootlogin|passwordauthentication'`
- `fail2ban-client status sshd`
