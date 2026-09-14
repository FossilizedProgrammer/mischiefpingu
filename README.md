# MischiefPingu

**Unofficial multi-core proxy client — Psiphon • Aether • Tor • SSTP**

A Flutter desktop GUI (Linux & Windows) that wraps multiple censorship-circumvention cores behind a single, clean interface.

---

## ✨ Features

### 🔌 Four Connectable Cores
- **Psiphon** — official `psiphon-tunnel-core`, plus
  [Shiro Khorshid's fork](https://github.com/shirokhorshid/psiphon-tunnel-core)
  for CDN fronting. Inside the app this fork's binary is referred to as
  `psiphon-tunnel-core-sunandlion` (a local filename chosen by the
  project, not the upstream name).
- **Aether** — MASQUE / WireGuard / Gool transports with automatic endpoint scanning.
- **Tor** — expert-bundle integration with pluggable transports.
- **SSTP** — SSTP client from [FossilizedProgrammer/sstp-proxy](https://github.com/FossilizedProgrammer/sstp-proxy).

### 🧠 Smart Connection Modes (Psiphon)
1. **Fronting (CDN)** — Shiro Khorshid's Psiphon Tunnel Core fork
   (`psiphon-tunnel-core-sunandlion` inside the app), configured with
   `FRONTED-MEEK-CDN-OSSH` dial overrides. Best for heavy censorship.
2. **Aether upstream** — official Psiphon core routed through Aether SOCKS5.
3. **Conduit (WebRTC Inproxy)** — decentralized peer relays.
4. **Direct** — official Psiphon core, no fronting.

### 🔗 Chained Tunnels
- Tor over Aether / Psiphon / SSTP
- SSTP over Aether / Psiphon / Tor
- Psiphon over Aether / Tor / SSTP / manual proxy

### 🛰️ CDN IP Scanner
- Built-in presets: Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure, Iran ISP ranges.
- CIDR / dash-range / single-IP expansion (up to 20 000 entries).
- Parallel TLS handshake verification with latency + reliability scoring.

### 🌐 VPN Gate SSTP Fetcher
- Scrapes **vpngate.net** (direct or via any running proxy).
- Auto-refresh every 15 minutes.
- Parallel health-check with TCP + TLS ClientHello probe.
- Copy results as plain list or detailed CSV.

### 🛠️ Core Updates
Built-in updater for every bundled binary. Updates are staged and applied on next startup when a core is running.

### 🎨 Extras
- 6 color themes with light/dark auto-switching.
- Persistent settings via `SharedPreferences`.
- Share-on-LAN support for every core.
- Auto-reconnect per core.
- Live log console with copy / clear.

---

## 🐧 Linux — Prerequisites

Before running or building on Linux, install GStreamer development packages:

```bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
