# MischiefPingu

**Multi-core proxy client — Psiphon • Aether • Tor • SSTP**

A Flutter desktop GUI (Linux & Windows) that wraps multiple censorship-circumvention cores behind a single, clean interface.

🔗 **GitHub:** [github.com/FossilizedProgrammer/mischiefpingu](https://github.com/FossilizedProgrammer/mischiefpingu)
📬 **Contact (X / Twitter):** [@tenblockperhour](https://x.com/tenblockperhour)

> **Legal notice regarding Psiphon:**
> This is an **unofficial Psiphon client**. It is **not affiliated with or endorsed by Psiphon Inc.** The "Psiphon" name and the official Psiphon tunnel core are the property of Psiphon Inc.

---

## ✨ Features

### 🔌 Four Connectable Cores
- **Psiphon** — official psiphon-tunnel-core binaries, plus the **Shiro Khorshid (SunAndLion / شیر و خورشید)** fork for CDN fronting.
- **Aether** — MASQUE / MIM / WireGuard / Gool transports with automatic endpoint scanning.
- **Tor** — expert-bundle integration with pluggable transports (obfs4, meek, snowflake, webtunnel, conjure).
- **SSTP** — SSTP proxy client developed by the author of this project.

### 🧠 Smart Connection Modes (Psiphon)
1. **Fronting (CDN)** — Shiro Khorshid / SunAndLion fork, configured with `FRONTED-MEEK-CDN-OSSH` dial overrides. Best for heavy censorship.
2. **Aether upstream** — official Psiphon core routed through Aether SOCKS5.
3. **Conduit (WebRTC Inproxy)** — decentralized peer relays.
4. **Direct** — official Psiphon core, no fronting.

### 🔗 Chained Tunnels
- Tor over Aether / Psiphon / SSTP
- SSTP over Aether / Psiphon / Tor
- Psiphon over Aether / Tor / SSTP / manual proxy

### 🎛️ Aether Profiles — Automatic Route Discovery
Aether does not require the user to touch complex settings. It ships with multiple profiles and **automatically tries them in order until it finds a working path**:

- **Adaptive** — balance of speed and coverage; tries MASQUE/HTTP-3 → MASQUE/HTTP-2 → WireGuard → Gool.
- **Patchy signal** — for unstable mobile data; adds MIM/HTTP-3 to the candidate list and uses `--noize balanced`.
- **Strict network** — for restricted Wi-Fi / heavy filtering; tries fragment + masque-in-masque and `--noize gfw`.
- **Manual** — full control for advanced users.

The last successfully-used transport and endpoint are remembered and tried first on the next launch.

### 🛰️ CDN IP Scanner
- Built-in presets: Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure.
- CIDR / dash-range / single-IP expansion (up to 20 000 entries).
- Parallel TLS handshake verification with latency + reliability scoring.
- Apply Top 5 / Top 20 results directly to fronting settings.

### 🌐 VPN Gate SSTP Fetcher
- Scrapes **vpngate.net** (direct or via any running proxy).
- Auto-refresh every 15 minutes.
- Parallel health-check with TCP + TLS ClientHello probe.
- Copy results as plain list or detailed CSV.

### 🛠️ Core Updates
Built-in updater for every bundled binary (Aether, Tor, Psiphon, SunAndLion, SSTP). Updates are staged and applied on next startup when a core is running.

### 🌍 Localization
Full UI translations in **English**, **فارسی**, and **Русский**, switchable at runtime.

### 🎨 Extras
- 6 color themes with light/dark auto-switching.
- Persistent settings via SharedPreferences.
- Share-on-LAN support for every core.
- Auto-reconnect per core.
- Live log console with copy / clear.
- Tunnel watchdog with automatic recovery.
- Penguin mascot that reacts to connection events.

---

## 🐧 Linux — Prerequisites

Install GStreamer development packages before running or building on Linux:

~~~bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
~~~

---

## 📦 Building

~~~bash
flutter pub get
flutter build linux --release --no-tree-shake-icons
# or
flutter build windows --release --no-tree-shake-icons
~~~

---

## 🙏 Credits & Acknowledgements

This project would not exist without the work of others. Sincere thanks to:

- **Aether** — [CluvexStudio/Aether](https://github.com/CluvexStudio/Aether/releases#release-v2.0.0). The Aether core powers every non-Psiphon, non-Tor, non-SSTP transport in this app. All credit for the Aether engine goes to its author.
- **Shiro Khorshid (SunAndLion / شیر و خورشید) Psiphon fork** — [shirokhorshid/psiphon-tunnel-core](https://github.com/shirokhorshid/psiphon-tunnel-core). The fronting / CDN connection mode in this app relies entirely on this fork. **Development of this core is done by the Shiro Khorshid author** — the MischiefPingu author has only republished the compiled binary on this repo, because the upstream project did not ship a prebuilt binary.
- **Official Psiphon** — [Psiphon-Labs/psiphon-tunnel-core-binaries](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries). The official Psiphon core is used for direct / Aether-upstream / Conduit / Tor-upstream / SSTP-upstream modes.
- **Tor Project** — for the Tor Expert Bundle and pluggable transports.
- **Flutter** — [flutter.dev](https://flutter.dev). This entire GUI is built on Flutter.
- **FossilizedProgrammer/sstp-proxy** — [github.com/FossilizedProgrammer/sstp-proxy](https://github.com/FossilizedProgrammer/sstp-proxy). **The SSTP proxy client bundled with this app is developed by the author of MischiefPingu.** SSTP itself was historically used as a system-wide VPN protocol by other projects; the sstp-proxy implementation here provides it as a **local proxy** instead, which is what makes the chained-tunnel setups possible.

### A note on the SunAndLion binary

The file `psiphon-tunnel-core-sunandlion` inside the app is the locally-chosen filename for the Shiro Khorshid / SunAndLion fork of the Psiphon tunnel core. It is **not** the upstream name of the project. All development, maintenance and bug-fixing of that core happens at [shirokhorshid/psiphon-tunnel-core](https://github.com/shirokhorshid/psiphon-tunnel-core). This repository only mirrors the compiled binary so the app can fetch it via its built-in updater.

---

## 📬 Contact

Questions, bug reports, or feedback — reach the developer on X:
**[@tenblockperhour](https://x.com/tenblockperhour)**

---

## 📜 License

GNU General Public License v3.0 — see [LICENSE](LICENSE).
