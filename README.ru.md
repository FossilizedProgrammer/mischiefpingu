# MischiefPingu

**Многопротокольный прокси-клиент — Psiphon • Aether • Tor • SSTP**

GUI-приложение на Flutter для десктопа (Linux и Windows), объединяющее несколько ядер обхода цензуры в одном чистом интерфейсе.

🔗 **GitHub:** [github.com/FossilizedProgrammer/mischiefpingu](https://github.com/FossilizedProgrammer/mischiefpingu)
📬 **Связь с разработчиком (X / Twitter):** [@tenblockperhour](https://x.com/tenblockperhour)

> **Правовая информация о Psiphon:**
> Это **неофициальный клиент Psiphon**. Он **не связан с Psiphon Inc. и не одобрен ею.** Название «Psiphon» и официальное ядро Psiphon tunnel core являются собственностью Psiphon Inc.

---

## ✨ Возможности

### 🔌 Четыре подключаемых ядра
- **Psiphon** — официальные бинарники psiphon-tunnel-core и форк **Shiro Khorshid (SunAndLion)** для фронтинга через CDN.
- **Aether** — транспорты MASQUE / MIM / WireGuard / Gool с автосканированием endpoint-ов.
- **Tor** — интеграция expert-bundle с подключаемыми транспортами (obfs4, meek, snowflake, webtunnel, conjure).
- **SSTP** — прокси-клиент SSTP, разработанный автором этого проекта.

### 🧠 Умные режимы подключения (Psiphon)
1. **Фронтинг (CDN)** — форк Shiro Khorshid / SunAndLion с `FRONTED-MEEK-CDN-OSSH`. Лучше для жёсткой цензуры.
2. **Aether как upstream** — официальное ядро Psiphon через SOCKS5 Aether.
3. **Conduit (WebRTC Inproxy)** — децентрализованные ретрансляторы.
4. **Прямое** — официальное ядро Psiphon без фронтинга.

### 🔗 Цепочки туннелей
- Tor через Aether / Psiphon / SSTP
- SSTP через Aether / Psiphon / Tor
- Psiphon через Aether / Tor / SSTP / ручной прокси

### 🎛️ Профили Aether — автоматический поиск маршрута
Aether не требует от пользователя ручной настройки сложных параметров. У него есть несколько профилей, и он **автоматически перебирает их по порядку, пока не найдёт рабочий маршрут**:

- **Адаптивный** — баланс скорости и покрытия; MASQUE/HTTP-3 → MASQUE/HTTP-2 → WireGuard → Gool.
- **Нестабильный сигнал** — для мобильных сетей; добавляет MIM/HTTP-3 и использует `--noize balanced`.
- **Строгая сеть** — для ограниченного Wi-Fi / жёсткой фильтрации; fragment + masque-in-masque и `--noize gfw`.
- **Ручной** — полный контроль для продвинутых пользователей.

Последний успешный транспорт и endpoint запоминаются и пробуются первыми при следующем запуске.

### 🛰️ Сканер IP CDN
- Предустановки: Akamai, Cloudflare, Fastly, Google CDN, Amazon CloudFront, Microsoft Azure.
- Расширение CIDR / диапазонов / одиночных IP (до 20 000 записей).
- Параллельная проверка TLS handshake с оценкой задержки и надёжности.
- Применение Top 5 / Top 20 к настройкам фронтинга.

### 🌐 Загрузчик серверов VPN Gate
- Парсит **vpngate.net** (напрямую или через любой активный прокси).
- Автообновление каждые 15 минут.
- Параллельная проверка здоровья через TCP + TLS ClientHello.
- Копирование результатов списком или в CSV.

### 🛠️ Обновления ядер
Встроенный апдейтер для всех бинарников (Aether, Tor, Psiphon, SunAndLion, SSTP). Обновления откладываются и применяются при следующем запуске, если ядро запущено.

### 🌍 Локализация
Полный перевод интерфейса на **английский**, **فارسی** и **русский** с переключением на лету.

### 🎨 Прочее
- 6 цветовых тем с авто-переключением светлая/тёмная.
- Сохранение настроек через SharedPreferences.
- Share-on-LAN для каждого ядра.
- Авто-переподключение для каждого ядра.
- Живая консоль логов с копированием / очисткой.
- Watchdog туннелей с авто-восстановлением.
- Пингвин-маскот, реагирующий на события подключения.

---

## 🐧 Linux — предварительные требования

Перед сборкой или запуском на Linux установите пакеты разработки GStreamer:

~~~bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
~~~

---

## 📦 Сборка

~~~bash
flutter pub get
flutter build linux --release --no-tree-shake-icons
# или
flutter build windows --release --no-tree-shake-icons
~~~

---

## 🙏 Благодарности

Этот проект не существовал бы без работы других людей. Искренняя благодарность:

- **Aether** — [CluvexStudio/Aether](https://github.com/CluvexStudio/Aether/releases#release-v2.0.0). Ядро Aether обеспечивает работу всех транспортов в этом приложении, кроме Psiphon, Tor и SSTP. Вся заслуга движка Aether принадлежит его автору.
- **Форк Shiro Khorshid (SunAndLion) для Psiphon** — [shirokhorshid/psiphon-tunnel-core](https://github.com/shirokhorshid/psiphon-tunnel-core). Режим фронтинга / CDN в этом приложении полностью опирается на этот форк. **Разработкой этого ядра занимается автор Shiro Khorshid** — автор MischiefPingu лишь переопубликовал скомпилированный бинарник в своём репозитории, поскольку в upstream-проекте готового бинарника не было.
- **Официальный Psiphon** — [Psiphon-Labs/psiphon-tunnel-core-binaries](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries). Официальное ядро Psiphon используется для режимов Direct, Aether upstream, Conduit, Tor upstream и SSTP upstream.
- **Tor Project** — за Tor Expert Bundle и подключаемые транспорты.
- **Flutter** — [flutter.dev](https://flutter.dev). Весь этот GUI построен на Flutter.
- **FossilizedProgrammer/sstp-proxy** — [github.com/FossilizedProgrammer/sstp-proxy](https://github.com/FossilizedProgrammer/sstp-proxy). **Прокси-клиент SSTP, поставляемый с этим приложением, разработан автором MischiefPingu.** Исторически SSTP использовался другими проектами как системный VPN-протокол; реализация sstp-proxy предоставляет его как **локальный прокси**, и именно это делает возможными цепочки туннелей.

### Замечание о бинарнике Shiro Khorshid

Файл `psiphon-tunnel-core-sunandlion` внутри приложения — это локально выбранное имя для форка Shiro Khorshid / SunAndLion. Это **не** upstream-название проекта. Вся разработка, поддержка и исправление ошибок этого ядра происходит в [shirokhorshid/psiphon-tunnel-core](https://github.com/shirokhorshid/psiphon-tunnel-core). Этот репозиторий лишь зеркалит скомпилированный бинарник, чтобы приложение могло загрузить его через свой встроенный апдейтер.

---

## 📬 Связь с разработчиком

Вопросы, отчёты об ошибках или отзывы — свяжитесь с разработчиком в X:
**[@tenblockperhour](https://x.com/tenblockperhour)**

---

## 📜 Лицензия

GNU General Public License v3.0 — см. [LICENSE](LICENSE).
