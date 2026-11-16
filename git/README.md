# git

Global git hooks. Scans every commit for secrets with [gitleaks](../gitleaks/README.md).

Deploy: `install.sh` symlinks `hooks/` → `~/.config/git/hooks` (directory symlink) and sets `git config --global core.hooksPath ~/.config/git/hooks` if it isn't set already. `~/.gitconfig` itself is not in this repo: it holds the user's name and email.

Requires `bash` and a current `gitleaks` (tested with 8.30.1; the hook uses the `gitleaks git` subcommand). Without them, the pre-commit hook blocks every commit. The `packages.yml` playbooks install both (see [ansible/README.md](../ansible/README.md#packagesyml)). The Debian/Ubuntu apt package (8.16) is too old.

## Hooks

| File | Does |
|------|------|
| `hooks/pre-commit` | Scans staged changes with `gitleaks git --pre-commit --staged --redact`, using the repository's own `.gitleaks.toml` if it has one, otherwise `~/.config/gitleaks/gitleaks.toml`. Blocks the commit on a finding, then runs the repository's own `.git/hooks/pre-commit`, if any. |
| `hooks/_chain` | Passthrough: runs the repository's own `.git/hooks/<name>`, if any. |
| `hooks/<other hook names>` | Symlinks to `_chain`, for every other client-side hook. |

A global `core.hooksPath` makes git ignore each repository's `.git/hooks`. The passthroughs keep per-repository hooks working.

## False positives

Prefer fixing a rule in `gitleaks/gitleaks.toml`. For a one-off, add the finding's fingerprint to `.gitleaksignore` in that repository's root. Never skip the scan with `--no-verify`.
