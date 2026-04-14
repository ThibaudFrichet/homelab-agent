#!/usr/bin/env bash
set -euo pipefail

CONFIG="${OPENCODE_CONFIG:-$HOME/.config/opencode/opencode.json}"
PROVIDER="${OPENCODE_PROVIDER:-ollama}"

[[ -f "$CONFIG" ]] || { echo "config not found: $CONFIG" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

base_url=$(jq -r --arg p "$PROVIDER" '.provider[$p].options.baseURL // empty' "$CONFIG")
[[ -n "$base_url" ]] || { echo "no baseURL for provider '$PROVIDER' in $CONFIG" >&2; exit 1; }

tags_url="${base_url%/v1}/api/tags"

echo "fetching models from $tags_url"
tags_json=$(curl -fsS --max-time 5 "$tags_url") \
    || { echo "failed to reach Ollama at $tags_url" >&2; exit 1; }

models_block=$(jq '[.models[].name] | map({ (.): { name: . } }) | add // {}' <<<"$tags_json")

count=$(jq 'length' <<<"$models_block")
echo "discovered $count model(s)"

cp "$CONFIG" "$CONFIG.bak"

tmp=$(mktemp)
jq --arg p "$PROVIDER" --argjson m "$models_block" \
   '.provider[$p].models = $m' "$CONFIG" > "$tmp"
mv "$tmp" "$CONFIG"

echo "updated $CONFIG (backup at $CONFIG.bak)"
