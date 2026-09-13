#!/bin/bash
# pingutunnel — offline-first release build.
#
# "Download once, done": dependencies resolve ONLY from pubspec.lock and the
# local pub cache, so a build never touches the network unless dependencies
# actually changed.
#
# Why this exists: `flutter build` re-runs an *online* `pub get` whenever
# pubspec.yaml is newer than pubspec.lock/package_config.json. With a stale
# proxy in the environment (e.g. ALL_PROXY pointing at a dead local SOCKS
# port) that online resolve fails with 403s and re-downloads packages on
# every single build. This script keeps the tree in a state where Flutter
# skips its implicit pub get entirely and goes straight to compiling.
set -e
cd "$(dirname "$0")"

# A stale proxy env breaks pub (403s) and forces repeated downloads — drop it.
# The build itself needs no network at all.
unset ALL_PROXY all_proxy

# Resolve strictly from pubspec.lock + warm cache. Fails fast with a clear
# error if a genuinely new package is needed — then run one online
# `flutter pub get` with working network and rebuild.
flutter pub get --offline

# Keep Flutter's up-to-date check satisfied
# (pubspec.yaml older than pubspec.lock AND package_config.json) so
# `flutter build` skips its own implicit online `pub get`.
touch pubspec.lock .dart_tool/package_config.json

flutter build linux --release "$@"
