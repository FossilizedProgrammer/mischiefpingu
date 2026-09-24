# 🐧 Озорной Пингвин (MischiefPingu)

<div align="center">

**Многопрофильный клиент — Psiphon • Aether • Tor • SSTP • WireGuard**

Графический интерфейс Flutter для настольных ПК (Linux и Windows), объединяющий несколько ядер обхода цензуры в чистом и целостном интерфейсе.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

</div>

---

## ️ Правовое уведомление о Psiphon

> Это **неофициальный** клиент Psiphon, не имеющий отношения к компании Psiphon Inc. и не одобренный ею.  
> Название «Psiphon» и официальное ядро Psiphon являются товарными знаками компании Psiphon Inc.

---

##  Возможности

### 🔌 Пять подключаемых ядер

| Ядро | Описание |
|------|----------|
| **Psiphon** | Официальный бинарный файл `psiphon-tunnel-core` вместе с форком SunAndLion для CDN-фронтинга |
| **Aether** | Протоколы MASQUE / MIM / WireGuard / Gool с автоматическим сканированием конечных точек |
| **Tor** | Интеграция expert-bundle с плагинами obfs4, meek, snowflake, webtunnel и conjure |
| **SSTP** | SSTP-прокси клиент, разработанный автором этого приложения |
| **WireGuard** | Пользовательский клиент на основе wireproxy с двумя ядрами: **Standard** (wireguard-go) и **AmneziaWG** (обфусцированная версия для жёсткой цензуры) |

**Общие возможности:**  
Поддержка вставки конфигов или URI, локальный SOCKS-порт, Share-on-LAN и автоматическое переподключение.

---

###  Умные режимы подключения (Psiphon)

| Режим | Описание |
|-------|----------|
| **Фронтинг (CDN)** | Форк SunAndLion с настройкой `FRONTED-MEEK-CDN-OSSH`. Лучший выбор при жёсткой цензуре |
| **Апстрим через Aether** | Официальное ядро Psiphon через SOCKS5 Aether |
| **Conduit (WebRTC Inproxy)** | Децентрализованные пиринговые ретрансляторы |
| **Прямой** | Официальное ядро Psiphon без фронтинга |

---

### 🔗 Цепочки туннелей

- Tor через Aether / Psiphon / SSTP
- SSTP через Aether / Psiphon / Tor
- Psiphon через Aether / Tor / SSTP / ручной прокси

---

### ️ Профили Aether — автоматический поиск пути

Aether не требует от пользователя возни со сложными настройками. В нём есть несколько готовых профилей, которые он пробует по очереди, пока не найдёт лучший работающий путь:

| Профиль | Описание |
|---------|----------|
| **Адаптивный** | Баланс скорости и покрытия; MASQUE/HTTP-3 → MASQUE/HTTP-2 → WireGuard → Gool |
| **Нестабильный сигнал** | Для нестабильного мобильного интернета; также пробует MIM/HTTP-3 и использует `--noize balanced` |
| **Ограниченная сеть** | Для ограниченного Wi-Fi или жёсткой фильтрации; fragment + masque-in-masque и `--noize gfw` |
| **Ручной** | Полный контроль для продвинутых пользователей |

> 💡 Последний успешный протокол и конечная точка запоминаются и пробуются в первую очередь при следующем запуске.

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

Встроенный обновлятор для всех бинарных файлов (Aether, Tor, Psiphon, SunAndLion, SSTP, wireproxy). Обновления сохраняются и применяются при следующем запуске.

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
| [**Aether**](https://github.com/CluvexStudio/Aether) | Ядро Aether обеспечивает все транспорты в этом приложении, кроме Psiphon, Tor и SSTP. Все заслуги ядра Aether принадлежат его автору |
| [**Форк SunAndLion Psiphon**](https://github.com/shirokhorshid/psiphon-tunnel-core) | Режим фронтинга / CDN в этом приложении полностью основан на этом форке. Разработка этого ядра ведётся автором SunAndLion |
| [**Официальный Psiphon**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | Официальное ядро Psiphon используется для режимов Direct, Aether Upstream, Conduit, Tor Upstream и SSTP Upstream |
| [**Проект Tor**](https://www.torproject.org/) | За специализированный бандл Tor и плагины транспорта |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | Пользовательский клиент WireGuard, предоставляющий SOCKS5/HTTP прокси |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | Обфусцированный форк WireGuard для сопротивления DPI |
| [**Flutter**](https://flutter.dev/) | Весь графический интерфейс построен на Flutter |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | SSTP-прокси клиент в этом приложении разработан автором MischiefPingu. Эта реализация предоставляет протокол в виде локального прокси, что делает возможным цепочку туннелей |

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
