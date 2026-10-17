# 🐧 Озорной Пингвин (MischiefPingu)

<div align="center">

**Многопрофильный клиент — Psiphon • Tor • SSTP • WireGuard • Firefox VPN • Lantern • Geph**

Графический интерфейс Flutter для настольных ПК (Linux и Windows), объединяющий несколько ядер обхода цензуры в чистом и целостном интерфейсе.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

[English](README.md) | [فارسی](README.fa.md) | **Русский**

</div>

---

## ️ Правовое уведомление о Psiphon

> Это **неофициальный** клиент Psiphon, не имеющий отношения к компании Psiphon Inc. и не одобренный ею.  
> Название «Psiphon» и официальное ядро Psiphon являются товарными знаками компании Psiphon Inc.

---

## ️ Правовое уведомление о Firefox VPN

> Это **неофициальный** клиент Firefox VPN, не имеющий отношения к Mozilla и не одобренный ею.  
> Названия «Firefox» и «Mozilla» являются товарными знаками Mozilla Foundation. Данный проект не спонсируется, не поддерживается и не одобряется Mozilla и не является официальным продуктом Mozilla.

---

##  Возможности

### 🔌 Восемь подключаемых ядер

| Ядро | Описание |
|------|----------|
| **Psiphon** | Официальный бинарный файл `psiphon-tunnel-core` вместе с форком SunAndLion для CDN-фронтинга |
| **Tor** | Интеграция expert-bundle с плагинами obfs4, meek, snowflake, webtunnel и conjure |
| **SSTP** | SSTP-прокси клиент, разработанный автором этого приложения |
| **WireGuard** | Пользовательский клиент на основе wireproxy с двумя ядрами: **Standard** (wireguard-go) и **AmneziaWG** (обфусцированная версия для жёсткой цензуры) |
| **Firefox VPN** | Встроенный клиент **IP Protection** в Firefox (`ffvpn` на базе Mozilla VPN) — вход через аккаунт Firefox и локальный SOCKS5/HTTP-прокси |
| **Lantern** | Headless-ядро Lantern (`lantern`) с локальным SOCKS5/HTTP-прокси и встроенным обновлятором |
| **Geph** | Неофициальный клиент **Geph 5** (`geph5-proxy`) — регистрация/вход в аккаунт, выбор страны выхода (Free/Premium), локальный SOCKS5/HTTP-прокси |

**Общие возможности:**  
Поддержка вставки конфигов или URI, локальный SOCKS-порт, Share-on-LAN и автоматическое переподключение.

---

###  Умные режимы подключения (Psiphon)

| Режим | Описание |
|-------|----------|
| **Фронтинг (CDN)** | Форк SunAndLion с настройкой `FRONTED-MEEK-CDN-OSSH`. Лучший выбор при жёсткой цензуре |
| **Conduit (WebRTC Inproxy)** | Децентрализованные пиринговые ретрансляторы |
| **Прямой** | Официальное ядро Psiphon без фронтинга |

---

### 🔗 Цепочки туннелей

- Tor через Psiphon / SSTP / Lantern / Geph
- SSTP через Psiphon / Tor / Lantern / Geph
- Psiphon через Tor / SSTP / Lantern / Geph / ручной прокси
- Firefox VPN через Lantern / Geph
- Lantern или Geph через любое другое ядро (или ручной прокси)

---


### 🛰️ Сканер IP CDN

- **Готовые пресеты:** Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure
- **Развёртывание CIDR / диапазонов / отдельных IP** (до 20 000 записей)
- **Параллельные проверки TLS handshake** с оценкой задержки и стабильности
- **Применение Top 5 / Top 20** к настройкам фронтинга

---

###  Получатель серверов VPN Gate

- Сбор данных с `vpngate.net` (напрямую или через любой активный прокси)
- Автообновление каждые 15 минут
- Параллельные проверки работоспособности через TCP + TLS ClientHello
- Копирование результатов в виде простого списка или подробного CSV

---

### 🛠️ Обновление ядер

Встроенный обновлятор для всех бинарных файлов (Tor, Psiphon, SunAndLion, SSTP, wireproxy, Firefox VPN, Lantern). Обновления сохраняются и применяются при следующем запуске.

---

### 🌍 Многоязычность

Полный перевод интерфейса на **английский**, **персидский** и **русский** языки с мгновенным переключением.

---

### 🎨 Другие возможности

- 6 цветовых тем с автоматическим светлым/тёмным режимом
- Сохранение настроек через SharedPreferences
- Поддержка общего доступа в локальной сети для всех ядер (включая WireGuard)
- Автоматическое переподключение для каждого ядра
- Живая консоль логов с копированием / очисткой
- Сторожевой таймер туннеля с автоматическим восстановлением
- Пингвин, который реагирует на события подключения! 🐧

---

## 🚀 Установка и запуск

###  Linux — зависимости

Перед запуском или сборкой на Linux установите пакеты разработки GStreamer:

**sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev**

### 📦 Сборка

Сначала выполните:

**flutter pub get**

Затем для Linux:

**flutter build linux --release --no-tree-shake-icons**

Или для Windows:

**flutter build windows --release --no-tree-shake-icons**

---

## 🙏 Благодарности

Этот проект не существовал бы без усилий других людей. Искренняя благодарность:

| Проект | Описание |
|--------|----------|
| [**Форк SunAndLion Psiphon**](https://github.com/shirokhorshid/psiphon-tunnel-core) | Режим фронтинга / CDN в этом приложении полностью основан на этом форке. Разработка этого ядра ведётся автором SunAndLion |
| [**Официальный Psiphon**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | Официальное ядро Psiphon используется для режимов Direct, Conduit, Tor Upstream и SSTP Upstream |
| [**Проект Tor**](https://www.torproject.org/) | За специализированный бандл Tor и плагины транспорта |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | Пользовательский клиент WireGuard, предоставляющий SOCKS5/HTTP прокси |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | Обфусцированный форк WireGuard для сопротивления DPI |
| [**Flutter**](https://flutter.dev/) | Весь графический интерфейс построен на Flutter |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | SSTP-прокси клиент в этом приложении разработан автором MischiefPingu. Эта реализация предоставляет протокол в виде локального прокси, что делает возможным цепочку туннелей |
| [**firefox-vpn-go**](https://github.com/FossilizedProgrammer/firefox-vpn-go) | Ядро Firefox VPN в этом приложении — самостоятельный Go-клиент для встроенного VPN-прокси Firefox (IP Protection на базе Mozilla VPN), распространяемый в виде готовых бинарных файлов release |
| [**Lantern**](https://github.com/getlantern/lantern) | Проект Lantern — это приложение запускает его headless-ядро, распространяемое через релизы `lantern-headless-iran` |
| [**Geph**](https://github.com/geph-official/geph5) | Ядро Geph 5 (`geph5-proxy`), лежащее в основе туннеля Geph в этом приложении |

---

### 📝 Примечание о бинарном файле SunAndLion

> Файл `psiphon-tunnel-core-sunandlion` внутри приложения — это локально выбранное имя для форка SunAndLion. Это не оригинальное название проекта. Вся разработка, поддержка и исправление ошибок этого ядра ведутся в репозитории [`shirokhorshid/psiphon-tunnel-core`](https://github.com/shirokhorshid/psiphon-tunnel-core). Данный репозиторий лишь зеркалирует скомпилированный бинарный файл, чтобы приложение могло загрузить его через встроенный обновлятор.

---

##  Связь с разработчиком

Вопросы, отчёты об ошибках или обратная связь — свяжитесь с разработчиком в X:

<div align="center">

[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x&style=for-the-badge)](https://x.com/tenblockperhour)

</div>

---

## 📄 Лицензия

Этот проект распространяется под лицензией **GNU General Public License v3.0**.  
Подробности см. в файле [`LICENSE`](LICENSE).

---

<div align="center">

**Сделано с ❤️ [FossilizedProgrammer](https://github.com/FossilizedProgrammer)**

</div>
