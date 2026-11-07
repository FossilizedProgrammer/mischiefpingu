#!/usr/bin/env bash
# Build the Linux app and assemble the one runnable bundle.
# Mirrors the CI job in .github/workflows/build.yml, so cores resolve from
# <bundle>/linux instead of relying on whatever the data folder already holds.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build linux --release --no-tree-shake-icons

readonly bundle=build/linux/x64/release/bundle

mkdir -p "$bundle/linux"
cp -a bundled/linux/. "$bundle/linux/"
for f in server_list.dat geoip geoip6; do
  [[ -f bundled/linux/$f ]] && cp -f "bundled/linux/$f" "$bundle/"
done

chmod +x "$bundle/mischiefpingu"
echo "→ $bundle/mischiefpingu"
