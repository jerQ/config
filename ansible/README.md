# ansible

Playbooks for system provisioning.

## Playbooks

| Playbook | Description |
|----------|-------------|
| `update.yml` | Update all packages (Debian/Ubuntu via `apt`, Fedora via `dnf`) |

## Usage

Run against localhost:

```sh
ansible-playbook update.yml -i localhost,
```
