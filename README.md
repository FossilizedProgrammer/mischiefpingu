# 🐧 MischiefPingu

<div align="center">

**Multi-core client — Psiphon • Aether • Tor • SSTP • WireGuard • Firefox VPN • Lantern • Geph • NPV Tunnel (napsternetV)**

A Flutter GUI for desktop (Linux and Windows) that unifies multiple censorship-circumvention cores in a clean, integrated interface.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**English** | [فارسی](README.fa.md) | [Русский](README.ru.md) | [Español](README.es.md)

</div>

---

## ⚠️ Legal Notice Regarding Psiphon

> This is an **unofficial** Psiphon client and has no affiliation with or endorsement from Psiphon Inc.  
> The name "Psiphon" and the official Psiphon core are trademarks of Psiphon Inc.

---

## ⚠️ Legal Notice Regarding Firefox VPN

> This is an **unofficial** Firefox VPN client and has no affiliation with or endorsement from Firefox / Mozilla.  
> "Firefox" and "Mozilla" are trademarks of the Mozilla Foundation. This project is not sponsored, supported, or endorsed by Mozilla and is not an official Mozilla product.

---

## ✨ Features

### 🔌 Connectable Cores

| Core | Description |
|------|-------------|
| **Psiphon** | Official `psiphon-tunnel-core` binary along with the SunAndLion fork for CDN fronting |
| **Aether** | MASQUE / MIM / WireGuard / Gool protocols with automatic endpoint scanning |
| **Tor** | expert-bundle integration — obfs4, meek, webtunnel, scramblesuit and snowflake through the bundled `lyrebird` transport, plus conjure (`conjure-client`) |
| **SSTP** | SSTP proxy client, developed by the author of this application |
| **WireGuard** | Userspace client based on wireproxy with two cores: **Standard** (wireguard-go) and **AmneziaWG** (obfuscated version for heavy censorship) |
| **Firefox VPN** | Firefox's built-in **IP Protection** client (`ffvpn`, powered by Mozilla VPN) — signs in with your Firefox Account and exposes a local SOCKS5/HTTP proxy |
| **Lantern** | Two engines: **Radiance** (`lantern-radiance`, the engine of the official Lantern v10 client — the default) and **Classic** (the headless `lantern` binary). Both expose a local SOCKS5/HTTP proxy and are covered by the built-in updater |
| **Geph** | Unofficial **Geph 5** client (`geph5-proxy`) — account sign-up/login, free/Premium exit-country selection, local SOCKS5/HTTP proxy |
| **NPV Tunnel** | `npv-go` client, developed by the author of this application — decrypts configs exported from the **NPV Tunnel V2raySSH** Android app (`.npvs`), probes them all and connects to the fastest live one; local SOCKS5/HTTP proxy. Settings list every config in the file, ranked by measured latency, with the reason for the dead ones |

**Common features:**  
A local SOCKS port on every core; Share-on-LAN on all cores except Firefox VPN and Lantern; automatic reconnection on Psiphon, Tor, SSTP, Aether, WireGuard and NPV; pasting configs, URIs or bridge lists wherever the core takes them (WireGuard `.conf` / `wireguard://` / `vpn://`, NPV `.npvs`, Tor bridges, SSTP and Psiphon server/CDN lists).

---

### 🧠 Smart Connection Modes (Psiphon)

| Mode | Description |
|------|-------------|
| **Fronting (CDN)** | SunAndLion fork with `FRONTED-MEEK-CDN-OSSH` setting. Best for heavy censorship |
| **Conduit (WebRTC Inproxy)** | Decentralized peer relays |
| **Direct** | Official Psiphon core without fronting |

---

### 🔗 Chained Tunnels

Any running core can be the upstream hop for the tunnel that rides on it. The
upstream is started automatically if it is not running yet.

| Tunnel | Can ride on |
|--------|-------------|
| **Tor** | Aether · Psiphon · SSTP · WireGuard · Firefox VPN · Lantern · Geph · NPV · manual proxy |
| **Psiphon** | Tor · SSTP · WireGuard · Firefox VPN · Lantern · Geph · NPV · manual proxy |
| **SSTP** | Aether · Psiphon · Tor · WireGuard · Firefox VPN · Lantern · Geph · NPV · manual proxy |
| **Firefox VPN** | Aether · Psiphon · Tor · SSTP · WireGuard · Lantern · Geph · NPV · manual proxy |
| **Lantern** | Aether · Psiphon · Tor · SSTP · WireGuard · Firefox VPN · Geph · NPV · manual proxy |
| **Geph** | Aether · Psiphon · Tor · SSTP · WireGuard · Firefox VPN · Lantern · NPV · manual proxy |

Aether, WireGuard and NPV Tunnel are upstream-only hops: they always connect
directly and have no upstream selector of their own.

---


### 🎛️ Aether Profiles — Automatic Path Discovery

Aether does not require the user to fiddle with complex settings. It comes with several ready-made profiles and tries them in order until it finds the best working path:

| Profile | Description |
|---------|-------------|
| **Adaptive** | Balance of speed and coverage; MASQUE/HTTP-2 → MASQUE/HTTP-3 → MIM → Gool → WireGuard, `balanced` scan and no extra obfuscation (same first attempt as the Android reference client) |
| **Patchy signal** | For unstable mobile data; also tries MIM/HTTP-3 and uses `--noize balanced` |
| **Strict network** | For restricted Wi-Fi or heavy filtering; fragment + masque-in-masque and `--noize gfw` |
| **Manual** | Full control for advanced users |

> 💡 The last successful protocol and endpoint are remembered and tried first on the next run.

---

### 🛰️ CDN IP Scanner

- **Ready-made presets:** Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure (plus your own list)
- **CIDR / range / single IP expansion** in three scan modes — Quick (200 IPs), Balanced (2,000) and Deep (full expansion, up to 20,000)
- **Parallel TLS handshake checks** with latency and stability scoring
- **SNI scouting** — finds fronting hostnames that are not blocked on your network
- **Apply Top 5 / Top 20** to fronting settings

---

### 📡 VPN Gate Server Fetcher

- Scrapes `vpngate.net` (directly or through any active proxy)
- Optional auto-refresh every 15 minutes
- Parallel health checks with TCP + TLS ClientHello
- Copy results as a plain list or detailed CSV

---

### 🔄 Core Updater

Built-in updater for the Aether, Tor, Psiphon, SunAndLion, SSTP, wireproxy (both the Standard and the AmneziaWG binary), Firefox VPN, Lantern and NPV Tunnel binaries — Geph is bundled but not covered by the updater. Updates are saved and applied on the next start.

---

### 🌍 Multilingual

Full UI translation in **English**, **Persian**, **Russian** and **Spanish** with instant switching.

---

### 🎨 Other Features

- 6 color themes with automatic light/dark mode
- Settings saved with SharedPreferences
- LAN sharing on every core that binds a local proxy — Psiphon, Tor, SSTP, Aether, WireGuard, Geph and NPV (Firefox VPN and Lantern stay localhost-only)
- Automatic reconnection for Psiphon, Tor, SSTP, Aether, WireGuard and NPV
- Live log console with copy / clear
- Tunnel watchdog with automatic recovery
- **Tunnel Health** — latency, loss, jitter, uptime and reconnect counters per running tunnel
- **Internet Quality** — background probe of the link with a quality grade and history
- **Bridge Scanner** — fetch and latency-test obfs4, webtunnel, snowflake, meek and conjure bridges
- **Diagnostics Report** — one-tap copy/save of the app state with sensitive values redacted
- **App Update** — checks the latest release and downloads it through an active tunnel if needed
- A penguin that reacts to connection events! 🐧

---

## 🚀 Installation & Running

### 🐧 Linux — Prerequisites

Before running or building on Linux, install the GStreamer development packages:

**sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev**

### 📦 Build

First run:

**flutter pub get**

Then for Linux:

**flutter build linux --release --no-tree-shake-icons**

Or for Windows:

**flutter build windows --release --no-tree-shake-icons**

On Linux, `./tool/build-linux.sh` runs that build and additionally copies `bundled/linux/` next to the bundle, so **`build/linux/x64/release/bundle` is the only runnable output**. Anything under `build/linux/x64/debug/` is `flutter run` scratch — it has no bundled cores and is not a release.

---

## 🙏 Acknowledgments

This project would not exist without the efforts of others. Sincere thanks to:

| Project | Description |
|---------|-------------|
| [**Aether**](https://github.com/CluvexStudio/Aether) | The Aether core powers the MASQUE/MIM/WireGuard/Gool transports in this app. All credit for the Aether core belongs to its author |
| [**SunAndLion Psiphon Fork**](https://github.com/shirokhorshid/psiphon-tunnel-core) | The fronting / CDN mode in this app is entirely based on this fork. Development of this core is handled by the SunAndLion author |
| [**Official Psiphon**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | The official Psiphon core runs Direct, Conduit and every non-fronted mode — the SunAndLion fork is only used when fronting is on |
| [**Tor Project**](https://www.torproject.org/) | For the specialized Tor bundle and transport plugins |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | Userspace WireGuard client that provides a SOCKS5/HTTP proxy |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | Obfuscated WireGuard fork for DPI resistance |
| [**Flutter**](https://flutter.dev/) | The entire GUI is built on Flutter |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | The SSTP proxy client in this app was developed by the author of MischiefPingu. This implementation provides the protocol as a local proxy, enabling tunnel chaining |
| [**firefox-vpn-go**](https://github.com/FossilizedProgrammer/firefox-vpn-go) | The Firefox VPN core of this app — a standalone Go client for the browser's built-in IP Protection VPN (Mozilla VPN), distributed as prebuilt release binaries |
| [**Lantern**](https://github.com/getlantern/lantern) | The Lantern project — this app runs its headless client and the [Radiance](https://github.com/getlantern/radiance) engine, distributed via the `lantern-headless-iran` release builds |
| [**Geph**](https://github.com/geph-official/geph5) | The Geph 5 core (`geph5-proxy`) behind this app's Geph tunnel |
| [**npv-go**](https://github.com/FossilizedProgrammer/npv-go) | The NPV core of this app — decrypts the `.npvs` exports made by the NPV Tunnel (V2raySSH) Android app and runs them with xray-core in-process. Published as release binaries, which the core updater can install |

---

### 📝 A Note on the SunAndLion Binary

> The file `psiphon-tunnel-core-sunandlion` inside the app is a locally chosen name for the SunAndLion fork. This is not the original project name. All development, maintenance, and bug fixes for that core take place at [`shirokhorshid/psiphon-tunnel-core`](https://github.com/shirokhorshid/psiphon-tunnel-core). This repository only mirrors the compiled binary so the app can download it via its internal updater.

---

## 📬 Contact the Developer

Questions, bug reports, or feedback — reach out to the developer on X:

<div align="center">

[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x&style=for-the-badge)](https://x.com/tenblockperhour)

</div>

---

## 📄 License

This project is released under the **GNU General Public License v3.0**.  
See the [`LICENSE`](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by [FossilizedProgrammer](https://github.com/FossilizedProgrammer)**

</div>
