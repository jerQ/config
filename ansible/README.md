# ansible

Playbooks for system provisioning.

## Playbooks

| Playbook | Description |
|----------|-------------|
| `update.yml` | Update all packages (Debian/Ubuntu via `apt`, Fedora via `dnf`) |
| `packages.yml` | Install common packages and third-party repos (VS Code, Brave) |
| `neovim.yml` | Build and install latest Neovim from source |

## Usage

Run against localhost:

```sh
ansible-playbook update.yml -i localhost,
ansible-playbook packages.yml -i localhost,
ansible-playbook neovim.yml -i localhost,
```

## packages.yml

Installs the following:

**CLI tools:** `git`, `gh`, `curl`, `fzf`, `ripgrep`, `tree`, `tmux`, `bat`, `cmake`, `make`, `gcc`, `autoconf`, `automake`, `golang`, `cargo`, `python3`, `ansible`, `podman`

**GUI apps:** `keepassxc`

**Third-party repos (Fedora only):** VS Code (Microsoft repo), Brave Browser (Brave repo)

## neovim.yml

Fetches the latest stable release tag from GitHub, clones the source, and compiles with `RelWithDebInfo`. Installs to `/usr/local`. Also installs `ripgrep` and `fzf` as runtime dependencies.
