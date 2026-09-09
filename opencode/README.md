# opencode

Configuration for [OpenCode](https://opencode.ai).

Deploy: symlink `opencode/opencode.json` to `~/.config/opencode/opencode.json` (handled by `install.sh`).

## Provider

Defines a local Ollama provider (`http://localhost:11434/v1`, OpenAI-compatible) with two models:

- `gemma2:2b` — Gemma 2 (2B)
- `qwen2.5-coder:1.5b` — Qwen 2.5 Coder (1.5B)

## Models

- Main model: `ollama/qwen2.5-coder:1.5b`
- Small model: `ollama/gemma2:2b`
