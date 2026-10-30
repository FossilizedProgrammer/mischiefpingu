# 🐧 Озорной Пингвин (MischiefPingu)

<div align="center">

**Многопрофильный клиент — Psiphon • Aether • Tor • SSTP • WireGuard • Firefox VPN • Lantern • Geph • NPV Tunnel (napsternetV)**

Графический интерфейс Flutter для настольных ПК (Linux и Windows), объединяющий несколько ядер обхода цензуры в чистом и целостном интерфейсе.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

[English](README.md) | [فارسی](README.fa.md) | **Русский** | [Español](README.es.md)

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

## ✨ Возможности

### 🔌 Девять подключаемых ядер

| Ядро | Описание |
|------|----------|
| **Psiphon** | Официальный бинарный файл `psiphon-tunnel-core` вместе с форком SunAndLion для CDN-фронтинга |
| **Aether** | Протоколы MASQUE / MIM / WireGuard / Gool с автоматическим сканированием конечных точек |
| **Tor** | Интеграция expert-bundle — транспорты obfs4, meek, webtunnel, scramblesuit и snowflake через бинарный файл `lyrebird`, а также conjure (`conjure-client`) |
| **SSTP** | SSTP-прокси клиент, разработанный автором этого приложения |
| **WireGuard** | Пользовательский клиент на основе wireproxy с двумя ядрами: **Standard** (wireguard-go) и **AmneziaWG** (обфусцированная версия для жёсткой цензуры) |
| **Firefox VPN** | Встроенный клиент **IP Protection** в Firefox (`ffvpn` на базе Mozilla VPN) — вход через аккаунт Firefox и локальный SOCKS5/HTTP-прокси |
| **Lantern** | Два движка: **Radiance** (`lantern-radiance`, движок официального клиента Lantern v10 — по умолчанию) и **Classic** (headless `lantern`). Оба отдают локальный SOCKS5/HTTP-прокси и оба обновляются встроенным обновлятором |
| **Geph** | Неофициальный клиент **Geph 5** (`geph5-proxy`) — регистрация/вход в аккаунт, выбор страны выхода (Free/Premium), локальный SOCKS5/HTTP-прокси |
| **NPV Tunnel** | Клиент `npv-go`, разработанный автором этого приложения — расшифровывает конфигурации, экспортированные из Android-приложения **NPV Tunnel V2raySSH** (файлы `.npvs`), проверяет все их и подключается к самому быстрому живому; локальный SOCKS5/HTTP-прокси. В настройках показывает все конфигурации файла в порядке измеренной задержки, а мёртвые — с причиной ошибки |

**Общие возможности:**  
Локальный SOCKS-порт у всех ядер; Share-on-LAN у всех ядер, кроме Firefox VPN и Lantern; автоматическое переподключение у Psiphon, Tor, SSTP, Aether, WireGuard и NPV; вставка конфигов, URI или списков мостов там, где ядро их принимает (`.conf` / `wireguard://` / `vpn://` для WireGuard, `.npvs` для NPV, мосты для Tor, списки серверов/CDN для SSTP и Psiphon).

---

### 🧠 Умные режимы подключения (Psiphon)

| Режим | Описание |
|-------|----------|
| **Фронтинг (CDN)** | Форк SunAndLion с настройкой `FRONTED-MEEK-CDN-OSSH`. Лучший выбор при жёсткой цензуре |
| **Conduit (WebRTC Inproxy)** | Децентрализованные пиринговые ретрансляторы |
| **Прямой** | Официальное ядро Psiphon без фронтинга |

---

### 🔗 Цепочки туннелей

Любое запущенное ядро может быть upstream-переходом для туннеля, который поверх него работает. Если upstream ещё не запущен, он стартует автоматически.

| Туннель | Может работать через |
|---------|----------------------|
| **Tor** | Aether · Psiphon · SSTP · WireGuard · Firefox VPN · Lantern · Geph · NPV · ручной прокси |
| **Psiphon** | Tor · SSTP · WireGuard · Firefox VPN · Lantern · Geph · NPV · ручной прокси |
| **SSTP** | Aether · Psiphon · Tor · WireGuard · Firefox VPN · Lantern · Geph · NPV · ручной прокси |
| **Firefox VPN** | Aether · Psiphon · Tor · SSTP · WireGuard · Lantern · Geph · NPV · ручной прокси |
| **Lantern** | Aether · Psiphon · Tor · SSTP · WireGuard · Firefox VPN · Geph · NPV · ручной прокси |
| **Geph** | Aether · Psiphon · Tor · SSTP · WireGuard · Firefox VPN · Lantern · NPV · ручной прокси |

Aether, WireGuard и NPV Tunnel — только базовые переходы: у них нет выбора upstream, они подключаются напрямую.

---


### 🎛️ Профили Aether — автоматический поиск пути

Aether не требует от пользователя возни со сложными настройками. В нём есть несколько готовых профилей, которые он пробует по очереди, пока не найдёт лучший работающий путь:

| Профиль | Описание |
|---------|----------|
| **Адаптивный** | Баланс скорости и покрытия; MASQUE/HTTP-2 → MASQUE/HTTP-3 → MIM/HTTP-2 → MIM/HTTP-3 → Gool → WireGuard, сканирование `balanced` и без дополнительной обфускации (та же первая попытка, что в Android-клиенте) |
| **Нестабильный сигнал** | Для нестабильного мобильного интернета; также пробует MIM/HTTP-3 и использует `--noize balanced` |
| **Ограниченная сеть** | Для ограниченного Wi-Fi или жёсткой фильтрации; fragment + masque-in-masque и `--noize gfw` |
| **Ручной** | Полный контроль для продвинутых пользователей |

> 💡 Последний успешный протокол и конечная точка запоминаются и пробуются в первую очередь при следующем запуске.

---

### 🛰️ Сканер IP CDN

- **Готовые пресеты:** Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure (плюс собственный список)
- **Развёртывание CIDR / диапазонов / отдельных IP** в трёх режимах сканирования — Quick (200 IP), Balanced (2 000) и Deep (полное развёртывание, до 20 000)
- **Параллельные проверки TLS handshake** с оценкой задержки и стабильности
- **Разведка SNI** — подбирает фронтинг-имена, которые не блокируются в вашей сети
- **Применение Top 5 / Top 20** к настройкам фронтинга

---

### 📡 Получатель серверов VPN Gate

- Сбор данных с `vpngate.net` (напрямую или через любой активный прокси)
- Необязательное автообновление каждые 15 минут
- Параллельные проверки работоспособности через TCP + TLS ClientHello
- Копирование результатов в виде простого списка или подробного CSV

---

### 🛠️ Обновление ядер

Встроенный обновлятор для бинарных файлов Aether, Tor, Psiphon, SunAndLion, SSTP, wireproxy (оба бинарника — Standard и AmneziaWG), Firefox VPN, Lantern и NPV Tunnel — Geph поставляется в комплекте, но обновлятором не покрывается. Обновления сохраняются и применяются при следующем запуске.

---

### 🌍 Многоязычность

Полный перевод интерфейса на **английский**, **персидский**, **русский** и **испанский** языки с мгновенным переключением.

---

### 🎨 Другие возможности

- 6 цветовых тем с автоматическим светлым/тёмным режимом
- Сохранение настроек через SharedPreferences
- Общий доступ в локальной сети у всех ядер, которые поднимают локальный прокси — Psiphon, Tor, SSTP, Aether, WireGuard, Geph и NPV (Firefox VPN и Lantern остаются только на localhost)
- Автоматическое переподключение для Psiphon, Tor, SSTP, Aether, WireGuard и NPV
- Живая консоль логов с копированием / очисткой
- Сторожевой таймер туннеля с автоматическим восстановлением
- **Состояние туннеля** — задержка, потери, джиттер, аптайм и счётчик переподключений для каждого работающего туннеля
- **Качество интернета** — фоновая проверка канала с оценкой качества и историей
- **Сканер мостов** — получение и проверка задержки мостов obfs4, webtunnel, snowflake, meek и conjure
- **Отчёт диагностики** — копирование/сохранение состояния приложения с автоматическим удалением чувствительных данных
- **Обновление приложения** — проверка последнего релиза и скачивание через активный туннель, если напрямую не выходит
- Пингвин, который реагирует на события подключения! 🐧

---

## 🚀 Установка и запуск

### 🐧 Linux — зависимости

Перед запуском или сборкой на Linux установите пакеты разработки GStreamer:

**sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev**

### 📦 Сборка

Сначала выполните:

**flutter pub get**

Затем для Linux:

**flutter build linux --release --no-tree-shake-icons**

Или для Windows:

**flutter build windows --release --no-tree-shake-icons**

На Linux вместо этих команд можно запустить **./tool/build-linux.sh**: он выполняет тот же release-сбор и копирует `bundled/linux/` внутрь бандла, поэтому **`build/linux/x64/release/bundle` — единственный готовый к запуску результат**. Всё, что лежит в `build/linux/x64/debug/`, — это вывод `flutter run`; там нет встроенных ядер, и релизом это не является.

---

## 🙏 Благодарности

Этот проект не существовал бы без усилий других людей. Искренняя благодарность:

| Проект | Описание |
|--------|----------|
| [**Aether**](https://github.com/CluvexStudio/Aether) | Ядро Aether обеспечивает транспорты MASQUE/MIM/WireGuard/Gool в этом приложении. Все заслуги ядра Aether принадлежат его автору |
| [**Форк SunAndLion Psiphon**](https://github.com/shirokhorshid/psiphon-tunnel-core) | Режим фронтинга / CDN в этом приложении полностью основан на этом форке. Разработка этого ядра ведётся автором SunAndLion |
| [**Официальный Psiphon**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | Официальное ядро Psiphon запускает Direct, Conduit и вообще любой режим без фронтинга — форк SunAndLion используется только при включённом фронтинге |
| [**Проект Tor**](https://www.torproject.org/) | За специализированный бандл Tor и плагины транспорта |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | Пользовательский клиент WireGuard, предоставляющий SOCKS5/HTTP прокси |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | Обфусцированный форк WireGuard для сопротивления DPI |
| [**Flutter**](https://flutter.dev/) | Весь графический интерфейс построен на Flutter |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | SSTP-прокси клиент в этом приложении разработан автором MischiefPingu. Эта реализация предоставляет протокол в виде локального прокси, что делает возможным цепочку туннелей |
| [**firefox-vpn-go**](https://github.com/FossilizedProgrammer/firefox-vpn-go) | Ядро Firefox VPN в этом приложении — самостоятельный Go-клиент для встроенного VPN-прокси Firefox (IP Protection на базе Mozilla VPN), распространяемый в виде готовых бинарных файлов release |
| [**Lantern**](https://github.com/getlantern/lantern) | Проект Lantern — это приложение запускает его headless-ядро и движок [Radiance](https://github.com/getlantern/radiance), распространяемые через релизы `lantern-headless-iran` |
| [**Geph**](https://github.com/geph-official/geph5) | Ядро Geph 5 (`geph5-proxy`), лежащее в основе туннеля Geph в этом приложении |
| [**npv-go**](https://github.com/FossilizedProgrammer/npv-go) | Ядро NPV этого приложения, также разработанное автором MischiefPingu — расшифровывает файлы `.npvs`, экспортированные Android-приложением NPV Tunnel (V2raySSH), и запускает xray-core внутри собственного процесса. Публикуется как готовые бинарники в Releases; раздел «Обновление ядер» устанавливает их |

---

### 📝 Примечание о бинарном файле SunAndLion

> Файл `psiphon-tunnel-core-sunandlion` внутри приложения — это локально выбранное имя для форка SunAndLion. Это не оригинальное название проекта. Вся разработка, поддержка и исправление ошибок этого ядра ведутся в репозитории [`shirokhorshid/psiphon-tunnel-core`](https://github.com/shirokhorshid/psiphon-tunnel-core). Данный репозиторий лишь зеркалирует скомпилированный бинарный файл, чтобы приложение могло загрузить его через встроенный обновлятор.

---

## 📬 Связь с разработчиком

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
