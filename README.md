# 🐧 MischiefPingu

<div align="center">

**Multi-core client — Psiphon • Tor • SSTP • WireGuard • Firefox VPN • Lantern • Geph**

A Flutter GUI for desktop (Linux and Windows) that unifies multiple censorship-circumvention cores in a clean, integrated interface.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**English** | [فارسی](README.fa.md) | [Русский](README.ru.md)

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
| **Tor** | expert-bundle integration with obfs4, meek, snowflake, webtunnel, and conjure plugins |
| **SSTP** | SSTP proxy client, developed by the author of this application |
| **WireGuard** | Userspace client based on wireproxy with two cores: **Standard** (wireguard-go) and **AmneziaWG** (obfuscated version for heavy censorship) |
| **Firefox VPN** | Firefox's built-in **IP Protection** client (`ffvpn`, powered by Mozilla VPN) — signs in with your Firefox Account and exposes a local SOCKS5/HTTP proxy |
| **Lantern** | Headless Lantern core (`lantern`) exposing a local SOCKS5/HTTP proxy, with a built-in updater |
| **Geph** | Unofficial **Geph 5** client (`geph5-proxy`) — account sign-up/login, free/Premium exit-country selection, local SOCKS5/HTTP proxy |

**Common features:**  
Supports pasting configs or URIs, local SOCKS port, Share-on-LAN, and automatic reconnection.

---

### 🧠 Smart Connection Modes (Psiphon)

| Mode | Description |
|------|-------------|
| **Fronting (CDN)** | SunAndLion fork with `FRONTED-MEEK-CDN-OSSH` setting. Best for heavy censorship |
| **Conduit (WebRTC Inproxy)** | Decentralized peer relays |
| **Direct** | Official Psiphon core without fronting |

---

### 🔗 Chained Tunnels

- Tor over Psiphon / SSTP / Lantern / Geph
- SSTP over Psiphon / Tor / Lantern / Geph
- Psiphon over Tor / SSTP / Lantern / Geph / manual proxy
- Firefox VPN over Lantern / Geph
- Lantern or Geph over any other core (or a manual proxy)

---


### 🛰️ CDN IP Scanner

- **Ready-made presets:** Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure
- **CIDR / range / single IP expansion** (up to 20,000 entries)
- **Parallel TLS handshake checks** with latency and stability scoring
- **Apply Top 5 / Top 20** to fronting settings

---

###  VPN Gate Server Fetcher

- Scrapes `vpngate.net` (directly or through any active proxy)
- Auto-refreshes every 15 minutes
- Parallel health checks with TCP + TLS ClientHello
- Copy results as a plain list or detailed CSV

---

### ️ Core Updater

Built-in updater for all binaries (Tor, Psiphon, SunAndLion, SSTP, wireproxy, Firefox VPN, Lantern). Updates are saved and applied on the next start.

---

### 🌍 Multilingual

Full UI translation in **English**, **Persian**, and **Russian** with instant switching.

---

### 🎨 Other Features

- 6 color themes with automatic light/dark mode
- Settings saved with SharedPreferences
- LAN sharing support for all cores (including WireGuard)
- Automatic reconnection for each core
- Live log console with copy / clear
- Tunnel watchdog with automatic recovery
- A penguin that reacts to connection events! 🐧

---

## 🚀 Installation & Running

###  Linux — Prerequisites

Before running or building on Linux, install the GStreamer development packages:

**sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev**

### 📦 Build

First run:

**flutter pub get**

Then for Linux:

**flutter build linux --release --no-tree-shake-icons**

Or for Windows:

**flutter build windows --release --no-tree-shake-icons**

---

## 🙏 Acknowledgments

This project would not exist without the efforts of others. Sincere thanks to:

| Project | Description |
|---------|-------------|
| [**SunAndLion Psiphon Fork**](https://github.com/shirokhorshid/psiphon-tunnel-core) | The fronting / CDN mode in this app is entirely based on this fork. Development of this core is handled by the SunAndLion author |
| [**Official Psiphon**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | The official Psiphon core is used for Direct, Conduit, Tor Upstream, and SSTP Upstream modes |
| [**Tor Project**](https://www.torproject.org/) | For the specialized Tor bundle and transport plugins |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | Userspace WireGuard client that provides a SOCKS5/HTTP proxy |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | Obfuscated WireGuard fork for DPI resistance |
| [**Flutter**](https://flutter.dev/) | The entire GUI is built on Flutter |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | The SSTP proxy client in this app was developed by the author of MischiefPingu. This implementation provides the protocol as a local proxy, enabling tunnel chaining |
| [**firefox-vpn-go**](https://github.com/FossilizedProgrammer/firefox-vpn-go) | The Firefox VPN core of this app — a standalone Go client for the browser's built-in IP Protection VPN (Mozilla VPN), distributed as prebuilt release binaries |
| [**Lantern**](https://github.com/getlantern/lantern) | The Lantern project — this app runs its headless core, distributed via the `lantern-headless-iran` release builds |
| [**Geph**](https://github.com/geph-official/geph5) | The Geph 5 core (`geph5-proxy`) behind this app's Geph tunnel |

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
