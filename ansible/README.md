# ansible

Playbooks for system provisioning, split per OS. Pick the directory that matches the machine — there's no OS detection, so the playbooks contain no `when:` conditions.

## Layout

| Path | Description |
|------|-------------|
| `fedora/` / `debian/` / `alpine/` | OS-specific playbooks (`dnf` / `apt` / `apk`) |
| `common/` | OS-independent playbooks, also imported by the OS-specific ones |

| Playbook | Description |
|----------|-------------|
| `<os>/site.yml` | Run everything in order: update → packages → gui → neovim → starship → setup |
| `<os>/update.yml` | Upgrade all packages |
| `<os>/packages.yml` | Install common CLI tools |
| `<os>/gui.yml` | Install GUI apps (`keepassxc`) — skip on headless machines |
| `<os>/neovim.yml` | Install Neovim, `ripgrep`, `fzf`, `clangd` and `pip` from the distro repos, then run `common/lsp.yml` |
| `alpine/hardening.yml` | Optional security hardening (AppArmor, auditd, sysctl, nftables, SSH, fail2ban, auto-updates). Not part of `site.yml` |
| `common/lsp.yml` | Install `pyright` (pip) and `lua-language-server` (GitHub release, x86_64 or aarch64) |
| `common/starship.yml` | Install `starship` into `~/.local/bin` via the official script (no sudo) |
| `common/setup.yml` | Create `~/Devel`, clone config repo, and run `install.sh` (no sudo) |

## Usage

Run everything:

```sh
ansible-playbook -i inventory.ini fedora/site.yml
ansible-playbook -i inventory.ini debian/site.yml
ansible-playbook -i inventory.ini alpine/site.yml
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

### Hardening (`alpine/hardening.yml`)

Run it when needed. It's not imported by `site.yml`. Each section is tagged, so you can apply only some of them:

```sh
ansible-playbook -i inventory.ini alpine/hardening.yml --check --diff     # dry run first
ansible-playbook -i inventory.ini alpine/hardening.yml --tags sysctl,firewall
```

| Tag | What it does |
|-----|--------------|
| `apparmor` | Installs AppArmor and its profiles, enables the service, and adds `lsm=…,apparmor audit=1` to the kernel command line (extlinux, GRUB or `/boot/cmdline.txt`). **Reboot required.** Profiles stay in their packaged mode; enforce them yourself with `aa-enforce`. |
| `audit` | Installs `audit`, adds watch rules (identity files, `doas.conf`, sshd config, apk repositories, periodic jobs, module loading, clock changes, mount, hostname), and enables `auditd`. Set `audit_immutable: true` to lock the rules until reboot. |
| `sysctl` | `/etc/sysctl.d/90-hardening.conf`: kernel pointer and dmesg restrictions, BPF hardening, ptrace scope 1, protected links and FIFOs, no core dumps for setuid programs, and no redirects or source routing. User namespaces stay enabled for rootless podman. |
| `modules` | Blocks loading of unused network protocols and filesystems (`blacklisted_modules`). |
| `mounts` | `/dev/shm` mounted with `nosuid,nodev,noexec`. |
| `firewall` | nftables: inbound blocked by default, except established connections, loopback, rate-limited ICMP and the ports in `firewall_allowed_tcp` (default `[22]`). |
| `ssh` | sshd drop-in: no root login, keys only, `MaxAuthTries 3`. **Stops** if `~/.ssh/authorized_keys` is missing or empty, so it can't lock you out. |
| `fail2ban` | `sshd` jail that bans through nftables. |
| `autoupdate` | Daily `apk update && apk upgrade` from `/etc/periodic/daily`, logged to syslog. Kernel updates still need a manual reboot. |

Before you run it:

- Keep a second SSH session open while applying the `ssh` or `firewall` tags.
- If SSH runs on a non-default port, set `firewall_allowed_tcp`.
- Rootful podman containers need forwarding, so set `firewall_forward_policy: accept` on hosts that run them.
- The Raspberry Pi kernel (`linux-rpi`) may not have AppArmor built in. Check `/sys/kernel/security/lsm` after rebooting.

Check the result after a reboot: `cat /sys/kernel/security/lsm`, `aa-status`, `auditctl -l`, `nft list ruleset`, `sshd -T | grep -E 'permitrootlogin|passwordauthentication'`, `fail2ban-client status sshd`.
