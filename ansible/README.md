# ansible

Playbooks for system provisioning.

## Playbooks

| Playbook | Description |
|----------|-------------|
| `main.yml` | Run all playbooks in order |
| `update.yml` | Update all packages (Debian/Ubuntu via `apt`, Fedora via `dnf`) |
| `packages.yml` | Install common packages and third-party repos (VS Code, Brave) |
| `neovim.yml` | Build and install latest Neovim from source |
| `setup.yml` | Create `~/Devel`, clone config repo, and run `install.sh` |

## Usage

Run all playbooks:

```sh
ansible-playbook main.yml -i localhost,
```

Or run individually:

```sh
ansible-playbook update.yml -i localhost,
ansible-playbook packages.yml -i localhost,
ansible-playbook neovim.yml -i localhost,
ansible-playbook setup.yml -i localhost,
```

## packages.yml

Installs the following:

**CLI tools:** `git`, `gh`, `curl`, `fzf`, `ripgrep`, `tree`, `tmux`, `bat`, `cmake`, `make`, `gcc`, `autoconf`, `automake`, `golang`, `cargo`, `python3`, `ansible`, `podman`, `neovim`

**GUI apps:** `keepassxc`

**Third-party repos (Fedora only):** VS Code (Microsoft repo), Brave Browser (Brave repo)

## neovim.yml

Fetches the latest stable release tag from GitHub, clones the source, and compiles with `RelWithDebInfo`. Installs to `/usr/local`. Also installs `ripgrep` and `fzf` as runtime dependencies.
