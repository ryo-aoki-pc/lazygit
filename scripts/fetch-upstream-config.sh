#!/usr/bin/env bash
# lazygit 公式ドキュメント docs/Config.md の「Default」セクションにある
# デフォルト設定 YAML を取り出して config.yml に書き出す。
#
# 使い方: scripts/fetch-upstream-config.sh <lazygit のタグ>   例: v0.65.1
set -euo pipefail

tag="${1:?usage: $0 <lazygit tag, e.g. v0.65.1>}"
url="https://raw.githubusercontent.com/jesseduffield/lazygit/${tag}/docs/Config.md"
out="$(cd "$(dirname "$0")/.." && pwd)/config.yml"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$url" \
  | awk '/^## Default/{f=1;next} f&&/^```yaml/{g=1;next} g&&/^```/{g=0;f=0} g' \
  > "$tmp"

if [ ! -s "$tmp" ]; then
  echo "error: Default セクションの YAML を取り出せませんでした: $url" >&2
  exit 1
fi

mv "$tmp" "$out"
trap - EXIT
echo "wrote $out ($(wc -l < "$out") lines) from lazygit $tag"
