# ansible

Playbooks for system provisioning.

## Playbooks

| Playbook | Description |
|----------|-------------|
| `update.yml` | Update all packages (Debian/Ubuntu via `apt`, Fedora via `dnf`) |
| `packages.yml` | Install common packages and third-party repos (VS Code, Brave) |

## Usage

Run against localhost:

```sh
ansible-playbook update.yml -i localhost,
ansible-playbook packages.yml -i localhost,
```

## packages.yml

Installs the following:

**CLI tools:** `git`, `gh`, `curl`, `fzf`, `ripgrep`, `tree`, `tmux`, `bat`, `cmake`, `make`, `gcc`, `autoconf`, `automake`, `golang`, `cargo`, `python3`, `ansible`, `podman`

**GUI apps:** `keepassxc`

**Third-party repos (Fedora only):** VS Code (Microsoft repo), Brave Browser (Brave repo)
