# 🐧 MischiefPingu

<div align="center">

**Cliente multinúcleo — Psiphon • Aether • Tor • SSTP • WireGuard • Firefox VPN • Lantern • Geph • NPV Tunnel (napsternetV)**

Una interfaz gráfica en Flutter para escritorio (Linux y Windows) que reúne varios núcleos de elusión de censura en una interfaz limpia e integrada.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (antes Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![Licencia](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

[English](README.md) | [فارسی](README.fa.md) | [Русский](README.ru.md) | **Español**

</div>

---

## ⚠️ Aviso legal sobre Psiphon

> Este es un cliente **no oficial** de Psiphon y no está afiliado ni avalado por Psiphon Inc.  
> El nombre «Psiphon» y el núcleo oficial de Psiphon son marcas registradas de Psiphon Inc.

---

## ⚠️ Aviso legal sobre Firefox VPN

> Este es un cliente **no oficial** de Firefox VPN y no está afiliado ni avalado por Firefox / Mozilla.  
> «Firefox» y «Mozilla» son marcas registradas de la Mozilla Foundation. Este proyecto no está patrocinado, apoyado ni avalado por Mozilla y no es un producto oficial de Mozilla.

---

## ✨ Características

### 🔌 Núcleos conectables

| Núcleo | Descripción |
|--------|-------------|
| **Psiphon** | El binario oficial `psiphon-tunnel-core` junto con la bifurcación SunAndLion para fronting por CDN |
| **Aether** | Protocolos MASQUE / MIM / WireGuard / Gool con escaneo automático de endpoints |
| **Tor** | Integración con expert-bundle — transportes obfs4, meek, webtunnel, scramblesuit y snowflake a través del binario `lyrebird`, además de conjure (`conjure-client`) |
| **SSTP** | Cliente de proxy SSTP, desarrollado por el autor de esta aplicación |
| **WireGuard** | Cliente de espacio de usuario basado en wireproxy con dos núcleos: **Estándar** (wireguard-go) y **AmneziaWG** (versión ofuscada para censura intensa) |
| **Firefox VPN** | Cliente de la **Protección de IP** integrada en Firefox (`ffvpn`, impulsado por Mozilla VPN) — inicia sesión con tu cuenta de Firefox y expone un proxy SOCKS5/HTTP local |
| **Lantern** | Dos motores: **Radiance** (`lantern-radiance`, el motor del cliente oficial Lantern v10 — el predeterminado) y **Clásico** (el binario headless `lantern`). Ambos exponen un proxy SOCKS5/HTTP local y ambos entran en el actualizador integrado |
| **Geph** | Cliente **Geph 5** no oficial (`geph5-proxy`) — creación/acceso a la cuenta, elección de país de salida gratis/Premium, proxy SOCKS5/HTTP local |
| **NPV Tunnel** | Cliente `npv-go`, desarrollado por el autor de esta aplicación — descifra las configuraciones exportadas de la aplicación Android **NPV Tunnel V2raySSH** (`.npvs`), las sondea todas y se conecta a la más rápida en activo; proxy SOCKS5/HTTP local. Los ajustes listan cada configuración del archivo, ordenadas por latencia medida, con el motivo de las que no responden |

**Características comunes:**  
Puerto SOCKS local en todos los núcleos; compartir en la red local en todos los núcleos salvo Firefox VPN y Lantern; reconexión automática en Psiphon, Tor, SSTP, Aether, WireGuard y NPV; y pegar configuraciones, URI o listas de puentes allí donde el núcleo los acepte (`.conf` / `wireguard://` / `vpn://` en WireGuard, `.npvs` en NPV, puentes en Tor, listas de servidores/CDN en SSTP y Psiphon).

---

### 🧠 Modos de conexión inteligentes (Psiphon)

| Modo | Descripción |
|------|-------------|
| **Fronting (CDN)** | Bifurcación SunAndLion con el ajuste `FRONTED-MEEK-CDN-OSSH`. Ideal para censura intensa |
| **Conduit (WebRTC Inproxy)** | Relés descentralizados entre pares |
| **Directo** | Núcleo oficial de Psiphon sin fronting |

---

### 🔗 Túneles encadenados

Cualquier núcleo en marcha puede servir de salto de upstream para el túnel que va sobre él. Si el upstream no está levantado, arranca automáticamente.

| Túnel | Puede ir sobre |
|-------|----------------|
| **Tor** | Aether · Psiphon · SSTP · WireGuard · Firefox VPN · Lantern · Geph · NPV · proxy manual |
| **Psiphon** | Tor · SSTP · WireGuard · Firefox VPN · Lantern · Geph · NPV · proxy manual |
| **SSTP** | Aether · Psiphon · Tor · WireGuard · Firefox VPN · Lantern · Geph · NPV · proxy manual |
| **Firefox VPN** | Aether · Psiphon · Tor · SSTP · WireGuard · Lantern · Geph · NPV · proxy manual |
| **Lantern** | Aether · Psiphon · Tor · SSTP · WireGuard · Firefox VPN · Geph · NPV · proxy manual |
| **Geph** | Aether · Psiphon · Tor · SSTP · WireGuard · Firefox VPN · Lantern · NPV · proxy manual |

Aether, WireGuard y NPV Tunnel solo sirven como salto base: no tienen selector de upstream y siempre conectan directo.

---


### 🎛️ Perfiles de Aether — descubrimiento automático de la ruta

Aether no exige que el usuario se pelee con ajustes complejos. Incluye varios perfiles preparados y los prueba en orden hasta encontrar la mejor ruta que funcione:

| Perfil | Descripción |
|--------|-------------|
| **Adaptativo** | Equilibrio entre velocidad y cobertura; MASQUE/HTTP-2 → MASQUE/HTTP-3 → MIM → Gool → WireGuard, escaneo `balanced` y sin ofuscación extra (el mismo primer intento que el cliente de referencia en Android) |
| **Señal irregular** | Para datos móviles inestables; prueba también MIM/HTTP-3 y usa `--noize balanced` |
| **Red estricta** | Para Wi-Fi restringida o filtrado intenso; fragment + masque dentro de masque y `--noize gfw` |
| **Manual** | Control total para usuarios avanzados |

> 💡 Se recuerdan el último protocolo y endpoint exitosos y se prueban primero en la siguiente ejecución.

---

### 🛰️ Escáner de IP de CDN

- **Presets listos:** Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure (más tu propia lista)
- **Expansión de CIDR / rangos / IP sueltas** en tres modos de escaneo — Rápido (200 IP), Equilibrado (2 000) y Profundo (expansión completa, hasta 20 000)
- **Comprobaciones de handshake TLS en paralelo** con puntuación de latencia y estabilidad
- **Reconocimiento de SNI** — encuentra nombres de fronting que no están bloqueados en tu red
- **Aplicar Top 5 / Top 20** a los ajustes de fronting

---

### 📡 Extractor de servidores de VPN Gate

- Extrae datos de `vpngate.net` (directamente o a través de cualquier proxy activo)
- Actualización automática opcional cada 15 minutos
- Comprobaciones de estado en paralelo con TCP + ClientHello de TLS
- Copia los resultados como lista simple o CSV detallado

---

### 🔄 Actualizador de núcleos

Actualizador integrado para los binarios de Aether, Tor, Psiphon, SunAndLion, SSTP, wireproxy (tanto el binario Estándar como el de AmneziaWG), Firefox VPN, Lantern y NPV Tunnel — Geph viene en el paquete pero no lo cubre el actualizador. Las actualizaciones se guardan y se aplican en el siguiente arranque.

---

### 🌍 Multilingüe

Interfaz totalmente traducida al **inglés**, **persa**, **ruso** y **español**, con cambio instantáneo.

---

### 🎨 Otras características

- 6 temas de color con modo claro/oscuro automático
- Ajustes guardados con SharedPreferences
- Compartir en la red local en todos los núcleos que levantan un proxy local — Psiphon, Tor, SSTP, Aether, WireGuard, Geph y NPV (Firefox VPN y Lantern se quedan solo en localhost)
- Reconexión automática en Psiphon, Tor, SSTP, Aether, WireGuard y NPV
- Consola de registro en vivo con copiar / limpiar
- Watchdog de túneles con recuperación automática
- **Estado del túnel** — latencia, pérdida, jitter, tiempo activo y contador de reconexiones de cada túnel en marcha
- **Calidad de internet** — sondeo en segundo plano del enlace con nota de calidad e historial
- **Escáner de puentes** — obtén y mide puentes obfs4, webtunnel, snowflake, meek y conjure
- **Informe de diagnóstico** — copiar/guardar el estado de la aplicación con los datos sensibles eliminados
- **Actualización de la aplicación** — comprueba la última versión y la descarga a través de un túnel activo si hace falta
- ¡Un pingüino que reacciona a los eventos de conexión! 🐧

---

## 🚀 Instalación y ejecución

### 🐧 Linux — Requisitos previos

Antes de ejecutar o compilar en Linux, instala los paquetes de desarrollo de GStreamer:

**sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev**

### 📦 Compilación

La primera vez:

**flutter pub get**

Luego para Linux:

**flutter build linux --release --no-tree-shake-icons**

O para Windows:

**flutter build windows --release --no-tree-shake-icons**

En Linux, `./tool/build-linux.sh` ejecuta esa compilación y además copia `bundled/linux/` junto al bundle, así que **`build/linux/x64/release/bundle` es la única salida ejecutable**. Todo lo que haya bajo `build/linux/x64/debug/` es material provisional de `flutter run` — no trae los núcleos bundled y no es una versión publicada.

---

## 🙏 Agradecimientos

Este proyecto no existiría sin el trabajo de otras personas. Agradecimiento sincero a:

| Proyecto | Descripción |
|----------|-------------|
| [**Aether**](https://github.com/CluvexStudio/Aether) | El núcleo Aether impulsa los transportes MASQUE/MIM/WireGuard/Gool de esta aplicación. Todo el mérito del núcleo Aether corresponde a su autor |
| [**Bifurcación SunAndLion de Psiphon**](https://github.com/shirokhorshid/psiphon-tunnel-core) | El modo fronting / CDN de esta aplicación se basa por completo en esta bifurcación. El desarrollo de ese núcleo lo lleva el autor de SunAndLion |
| [**Psiphon oficial**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | El núcleo oficial de Psiphon ejecuta Directo, Conduit y cualquier modo sin fronting; la bifurcación SunAndLion solo se usa con el fronting activado |
| [**Proyecto Tor**](https://www.torproject.org/) | Por el bundle especializado de Tor y sus complementos de transporte |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | Cliente de WireGuard en espacio de usuario que ofrece un proxy SOCKS5/HTTP |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | Bifurcación de WireGuard ofuscada para resistir la inspección profunda de paquetes |
| [**Flutter**](https://flutter.dev/) | Toda la interfaz gráfica está construida sobre Flutter |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | El cliente de proxy SSTP de esta aplicación lo desarrolló el autor de MischiefPingu. Esta implementación ofrece el protocolo como proxy local y permite encadenar túneles |
| [**firefox-vpn-go**](https://github.com/FossilizedProgrammer/firefox-vpn-go) | El núcleo de Firefox VPN de esta aplicación — un cliente Go independiente para la VPN de protección de IP integrada en el navegador (Mozilla VPN), distribuido como binarios precompilados |
| [**Lantern**](https://github.com/getlantern/lantern) | El proyecto Lantern — esta aplicación ejecuta su cliente headless y el motor [Radiance](https://github.com/getlantern/radiance), distribuidos mediante las compilaciones `lantern-headless-iran` |
| [**Geph**](https://github.com/geph-official/geph5) | El núcleo de Geph 5 (`geph5-proxy`) que hay detrás del túnel Geph de esta aplicación |
| [**npv-go**](https://github.com/FossilizedProgrammer/npv-go) | El núcleo NPV de esta aplicación — descifra las exportaciones `.npvs` que genera la aplicación Android NPV Tunnel (V2raySSH) y las ejecuta con xray-core en el propio proceso. Publicado como binarios de versión que el actualizador de núcleos puede instalar |

---

### 📝 Nota sobre el binario de SunAndLion

> El archivo `psiphon-tunnel-core-sunandlion` dentro de la aplicación es un nombre elegido localmente para la bifurcación SunAndLion. No es el nombre original del proyecto. Todo el desarrollo, mantenimiento y corrección de errores de ese núcleo ocurre en [`shirokhorshid/psiphon-tunnel-core`](https://github.com/shirokhorshid/psiphon-tunnel-core). Este repositorio solo refleja el binario compilado para que la aplicación pueda descargarlo mediante su actualizador interno.

---

## 📬 Contacto con el desarrollador

Preguntas, informes de errores o comentarios — escribe al desarrollador en X:

<div align="center">

[![X (antes Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x&style=for-the-badge)](https://x.com/tenblockperhour)

</div>

---

## 📄 Licencia

Este proyecto se publica bajo la **GNU General Public License v3.0**.  
Consulta el archivo [`LICENSE`](LICENSE) para más detalles.

---

<div align="center">

**Hecho con ❤️ por [FossilizedProgrammer](https://github.com/FossilizedProgrammer)**

</div>
