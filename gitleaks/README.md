# gitleaks

Global [gitleaks](https://github.com/gitleaks/gitleaks) config: gitleaks' built-in rules plus rules for Wi-Fi credentials, plain passwords and account names, which the built-in rules miss.

Deploy: `install.sh` symlinks `gitleaks.toml` → `~/.config/gitleaks/gitleaks.toml`.

Requires `gitleaks` installed (Fedora: `sudo dnf install gitleaks`). The global git pre-commit hook (`~/.config/git/hooks/pre-commit`, via `core.hooksPath`) scans staged changes with this config, unless a repository has its own `.gitleaks.toml`.

## Rules

| Rule | Catches |
|------|---------|
| `wifi-credential` | Wi-Fi SSID or password assigned as a quoted literal: `WIFI_SSID = "<WIFI_SSID>"`, `#define WLAN_PASS "<WIFI_PASSWORD>"` |
| `wifi-credential-config` | Unquoted Wi-Fi values in config files (`.conf`, `.ini`, `.env`, `.yaml`, `.nmconnection`, `wpa_supplicant`, …) |
| `wpa-psk-hex` | 64-hex-character WPA pre-shared keys |
| `nmcli-wifi` | Network name and password in `nmcli dev wifi connect <WIFI_SSID> password <WIFI_PASSWORD>` |
| `password-literal` | Password, passphrase or secret assigned as a quoted literal |
| `account-name-literal` | Username or account name assigned as a quoted literal |

A quoted key needs an operator (`=`, `:=`, `:`, `=>`). A bare space only separates an unquoted key (`#define X "v"`), so lists of quoted file names such as `"passphrase.c" "serial_protocol.c"` or `"wifi.c" "main.c"` are not findings.

## Allowlist

Placeholders and references are not findings: empty values, `<WIFI_SSID>`, `$VAR`, `%s`, `{{ template }}`, `{name}`, `****`, `xxxx`, `your_password`, `changeme`, `example…`, and values read via `getenv`/`environ`/`process.env`/`secrets.`.

## False positives

Prefer fixing a rule over ignoring a finding. For a one-off, add the finding's fingerprint to `.gitleaksignore` in that repository's root.
