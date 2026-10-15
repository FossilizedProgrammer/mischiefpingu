// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Озорной Пингу';

  @override
  String get appSubtitle =>
      'Неофициальный клиент Psiphon, клиент Tor, клиент SSTP, клиент WireGuard, клиент Firefox VPN, клиент Lantern';

  @override
  String get add => 'Добавить';

  @override
  String get addNew => 'Добавить новое';

  @override
  String get allServers => 'Все серверы';

  @override
  String get any => 'Любой';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get appliedTop20Ips => 'Применены Top 20 IP';

  @override
  String get appliedTop5Ips => 'Применены Top 5 IP + SNI';

  @override
  String get applyTop20 => 'Применить Top 20';

  @override
  String get applyTop5 => 'Применить Top 5';

  @override
  String get authenticationOptional => 'Аутентификация (опционально)';

  @override
  String get autoFindIpSni => 'Авто-поиск IP и SNI';

  @override
  String get autoFirstProxy => 'Авто (первый активный прокси)';

  @override
  String get autoFirstRunningProxy => 'Авто (первый активный прокси)';

  @override
  String get autoReconnectPsiphon => 'Авто-переподключение Psiphon';

  @override
  String get autoReconnectSstp => 'Авто-переподключение SSTP';

  @override
  String get autoReconnectTor => 'Авто-переподключение Tor';

  @override
  String get autoRefresh15Min => 'Авто-обновление каждые 15 минут';

  @override
  String get autoRefreshSubtitle =>
      'Получает новые серверы и проверяет здоровье автоматически';

  @override
  String get binaryNotFound => 'Исполняемый файл не найден';

  @override
  String get bridgePresets => 'Предустановки мостов (опционально)';

  @override
  String get bridges => 'Мосты (по одному на строку, включая webtunnel)';

  @override
  String get bridgesHint => 'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get cancel => 'Отмена';

  @override
  String get cancelBtn => 'Отмена';

  @override
  String get cdnPreset => 'Предустановка CDN';

  @override
  String get cdnScanner => 'Сканер IP CDN';

  @override
  String get cdnScanModeQuick => 'Быстро';

  @override
  String get cdnScanModeBalanced => 'Сбалансированно';

  @override
  String get cdnScanModeDeep => 'Глубоко';

  @override
  String cdnScanModeQuickDesc(String samples, String max) {
    return 'Быстро · $samples IP на CIDR · до $max всего · ~1-2 мин';
  }

  @override
  String cdnScanModeBalancedDesc(String samples, String max) {
    return 'Сбалансированно · $samples IP на CIDR · до $max всего · ~5-10 мин';
  }

  @override
  String cdnScanModeDeepDesc(String max) {
    return 'Глубоко · полное расширение · до $max всего · ~30-60 мин';
  }

  @override
  String get cdnScoutTitle => 'Найти рабочие SNI (рекомендуется)';

  @override
  String cdnScoutProgress(String done, String total) {
    return 'Разведка $done/$total…';
  }

  @override
  String get cdnScoutHint =>
      'SNI Discord/Reddit заблокированы в Иране. Разведка найдёт рабочие.';

  @override
  String get cdnScoutButton => 'Разведка';

  @override
  String cdnScanPreview(String lines, String ips) {
    return 'Строк: $lines · будет сканировано IP: $ips';
  }

  @override
  String cdnScanWarningsMore(String count) {
    return '…и ещё $count';
  }

  @override
  String cdnApplyIpsToPsiphon(String count) {
    return 'Применить $count IP к Psiphon';
  }

  @override
  String cdnApplyIpsSnack(String count, String ip, String sni) {
    return '$count IP → Psiphon\nFronting IP: $ip\nSNI: $sni';
  }

  @override
  String get cdnSendToPsiphon => 'Отправить в Psiphon';

  @override
  String get cdnSaveEnteredIps => 'Сохранить введённые IP';

  @override
  String cdnIpsSavedSnack(String count, String total) {
    return 'Сохранено IP: $count (всего в списке: $total)';
  }

  @override
  String cdnCustomIpsSent(String count, String ip) {
    return '$count пользовательских IP → Psiphon (Fronting: $ip)';
  }

  @override
  String cdnResultSubtitle(String score, String reliability, String latency,
      String download, String sni) {
    return 'Оценка $score · Надёжность $reliability/5 · ${latency}ms · загр. ${download}ms · $sni';
  }

  @override
  String get check => 'Проверить';

  @override
  String get checkHealth => 'Проверить здоровье';

  @override
  String get checking => 'Проверка…';

  @override
  String get clear => 'Очистить';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String get clearLog => 'Очистить';

  @override
  String get close => 'Закрыть';

  @override
  String get colorTheme => 'Цветовая тема';

  @override
  String get colorThemeSubtitle =>
      'Выберите цветовую схему для всего приложения.';

  @override
  String get conduitWebrtc => 'Conduit (WebRTC Inproxy)';

  @override
  String get connected => 'Подключено';

  @override
  String get connecting => 'Подключение…';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get copyAllToClipboard => 'Копировать все';

  @override
  String get importFromClipboard => 'Импорт из буфера обмена';

  @override
  String get importedFromClipboard => 'Импортировано из буфера обмена';

  @override
  String get nothingToImport => 'Буфер обмена пуст';

  @override
  String get itemsAddedCount => 'Добавлено элементов';

  @override
  String get copy => 'Копировать';

  @override
  String get copyAllCsv => 'Копировать все (CSV с деталями)';

  @override
  String get copyAllIpPort => 'Копировать все (ip:port)';

  @override
  String get copyLog => 'Копировать';

  @override
  String get coreUpdates => 'Обновления ядер';

  @override
  String get customIps => 'Пользовательские IP';

  @override
  String get delete => 'Удалить';

  @override
  String get directNoProxy => 'Прямое (без прокси)';

  @override
  String get directNoProxyOption => 'Прямое (без прокси)';

  @override
  String get directNoUpstream => 'Прямое (без upstream)';

  @override
  String get disconnected => 'Отключено';

  @override
  String get disconnectingTunnels => 'Отключение активных туннелей…';

  @override
  String get download => 'Скачать';

  @override
  String get downloadVia => 'Скачать через';

  @override
  String get downloadViaSubtitle =>
      'Проверки и загрузки используют выбранный прокси, когда прямой доступ фильтруется.';

  @override
  String get egressRegion => 'Регион выхода';

  @override
  String get enableLogging => 'Включить логирование';

  @override
  String get enableLoggingSubtitle =>
      'Когда выключено, новые логи не собираются';

  @override
  String get exitCountry => 'Страна выхода';

  @override
  String get exitCountryAny => 'Любая (случайно)';

  @override
  String get fetch => 'Получить';

  @override
  String get fetchVia => 'Получить через';

  @override
  String get fetching => 'Получение…';

  @override
  String get fingerprint => 'Отпечаток';

  @override
  String get frontingAdvanced => 'Фронтинг (расширенный, опционально)';

  @override
  String get frontingIp => 'IP фронтинга';

  @override
  String get httpHostHeader =>
      'Заголовок Host (например, aparat.com, snapp.ir)';

  @override
  String get httpPort => 'Порт HTTP';

  @override
  String get installed => 'Установлено';

  @override
  String get ipsCidrRanges => 'IP / CIDR / Диапазоны';

  @override
  String get ipv4Only => 'Только IPv4';

  @override
  String get language => 'Язык';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFarsi => 'فارسی';

  @override
  String get languageRussian => 'Русский';

  @override
  String get latest => 'Последняя';

  @override
  String get lines => 'строк';

  @override
  String get listIsEmpty => 'Список пуст';

  @override
  String get localProxyPorts => 'Локальные порты прокси';

  @override
  String get log => 'Лог';

  @override
  String get logSourceFilter => 'Фильтр источников логов';

  @override
  String get logSourcePsiphon => 'Psiphon';

  @override
  String get logSourceTor => 'Tor';

  @override
  String get logSourceSstp => 'SSTP';

  @override
  String get logSourceApp => 'Приложение';

  @override
  String get logSourceSystem => 'Система';

  @override
  String get manageList => 'Управление списком (Добавить / Удалить)';

  @override
  String get manualProxy => 'Ручной прокси';

  @override
  String get manualProxyOption => 'Ручной прокси';

  @override
  String get muteSounds => 'Отключить звуки';

  @override
  String get muteSoundsSubtitle =>
      'Отключить все звуки пингвина. Визуальные реакции остаются.';

  @override
  String get noCustomIpsSaved => 'Пользовательские IP ещё не сохранены';

  @override
  String get noLogsYet => 'Логов пока нет';

  @override
  String get noUpstreamDirect => 'Без upstream (прямое)';

  @override
  String get notInstalled => 'Не установлено';

  @override
  String get notifications => 'Уведомления';

  @override
  String get obfOff => 'Выкл';

  @override
  String get officialCore => 'официальное ядро Psiphon';

  @override
  String get password => 'Пароль';

  @override
  String get passwordOptional => 'Пароль (опционально)';

  @override
  String get port => 'Порт';

  @override
  String portRangeError(int min, int max) {
    return 'Введите номер порта от $min до $max';
  }

  @override
  String get preset1Subtitle =>
      'Использует ядро SunAndLion Psiphon (неофициальный форк).';

  @override
  String get preset1Title => '1 · Фронтинг (CDN). Лучше для жёсткой цензуры.';

  @override
  String get preset2Subtitle => 'Использует протоколы INPROXY-WEBRTC Psiphon.';

  @override
  String get preset2Title =>
      '2 · Conduit (WebRTC Inproxy). Децентрализованные ретрансляторы.';

  @override
  String get preset3Subtitle => 'Использует официальное ядро Psiphon напрямую.';

  @override
  String get preset3Title =>
      '3 · Прямое подключение. Подходит для мягкой цензуры.';

  @override
  String get profile => 'Профиль';

  @override
  String get protocol => 'Протокол';

  @override
  String get proxyIp => 'IP прокси';

  @override
  String get proxyType => 'Тип прокси';

  @override
  String get psiphonConnectedVia => 'Psiphon подключён через';

  @override
  String get psiphonConnectionMode => 'Режим подключения Psiphon';

  @override
  String get psiphonSettings => 'Настройки Psiphon';

  @override
  String get psiphonUpstream => 'Psiphon (SOCKS upstream)';

  @override
  String get save => 'Сохранить';

  @override
  String get saveFoundIpsSni => 'Авто-сохранение найденных IP и SNI';

  @override
  String get scanMode => 'Режим сканирования';

  @override
  String get select => 'Выбрать…';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get server => 'Сервер';

  @override
  String get serverAddress => 'Адрес сервера';

  @override
  String get shareOnLan => 'Общий доступ в LAN (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphon => 'Общий доступ в LAN (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphonSubtitle =>
      'Перенаправление портов SOCKS и HTTP на всех интерфейсах';

  @override
  String get showLess => 'Показать меньше';

  @override
  String get showLessSubtitle => 'Скрыть расширенные настройки и логи';

  @override
  String get showMore => 'Показать больше';

  @override
  String get showMoreSubtitle =>
      'Appearance, Psiphon, Tor, SSTP, WireGuard, Firefox VPN, Lantern, Scanner, Updates, Log';

  @override
  String get sni => 'SNI';

  @override
  String get sniList => 'Список SNI (по одному на строку, порядок = приоритет)';

  @override
  String get socksPort => 'Порт SOCKS';

  @override
  String get sstpConnected => 'SSTP подключён';

  @override
  String get sstpSettings => 'Настройки SSTP';

  @override
  String get sstpSocksUpstream => 'SSTP (SOCKS upstream)';

  @override
  String get start => 'Запуск';

  @override
  String get startScan => 'Начать сканирование';

  @override
  String get stop => 'Стоп';

  @override
  String get stopHealthCheck => 'Стоп';

  @override
  String get stopScan => 'Стоп';

  @override
  String get sunandlionCore => 'ядро SunAndLion Psiphon';

  @override
  String get threads => 'Потоки';

  @override
  String get tlsSni => 'TLS SNI (например, a248.e.akamai.net)';

  @override
  String get torBridge => 'Мост (obfs4 / snowflake / свой)';

  @override
  String get torConnected => 'Tor подключён';

  @override
  String get torConnection => 'Подключение Tor';

  @override
  String get torDirect => 'Прямое (без моста, без upstream) — по умолчанию';

  @override
  String get torManual => 'Ручной прокси';

  @override
  String get torSettings => 'Настройки Tor';

  @override
  String get torSocksUpstream => 'Tor (SOCKS upstream)';

  @override
  String get torUpstream => 'Tor (SOCKS upstream)';

  @override
  String get torViaPsiphon => 'Через Psiphon (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'Через SSTP (Tor-over-SSTP)';

  @override
  String get tunnelCore => 'Ядро туннеля';

  @override
  String get update => 'Обновить';

  @override
  String get upstream => 'Upstream';

  @override
  String get upstreamType => 'Тип upstream';

  @override
  String get usableIps => 'Рабочие IP (сортировка по оценке)';

  @override
  String get useFronting => 'Использовать фронтинг (CDN)';

  @override
  String get userOptional => 'Пользователь (опционально)';

  @override
  String get username => 'Имя пользователя';

  @override
  String get verboseLogging => 'Подробное логирование';

  @override
  String get verboseLoggingSubtitle =>
      'Включить детальный отладочный вывод из sstp-proxy';

  @override
  String get vpngateServers => 'Серверы SSTP VPN Gate';

  @override
  String get working => 'Работа';

  @override
  String get watchdog => 'Сторожевой таймер';

  @override
  String get watchdogEnabled => 'Включить сторожевой таймер';

  @override
  String get watchdogEnabledSubtitle =>
      'Автоматически перезапускать туннели при отсутствии ответа';

  @override
  String get watchdogSettings => 'Настройки сторожевого таймера';

  @override
  String get backToPresets => 'Вернуться к профилям';

  @override
  String get watchdogNetworkProfile => 'Профиль сети';

  @override
  String get watchdogNetworkProfileSubtitle =>
      'Настраивает агрессивность проверок сторожевого таймера. Выберите под вашу сеть.';

  @override
  String get watchdogProfileStable => 'Стабильно';

  @override
  String get watchdogProfileStableDesc =>
      'Хорошее качество интернета — строгие проверки, быстрое обнаружение сбоев.';

  @override
  String get watchdogProfileNormal => 'Обычный';

  @override
  String get watchdogProfileNormalDesc =>
      'Сбалансированные настройки для большинства сетей (по умолчанию).';

  @override
  String get watchdogProfileHarsh => 'Жёсткая фильтрация';

  @override
  String get watchdogProfileHarshDesc =>
      'Сильная фильтрация или нестабильная сеть — мягкие проверки, меньше ложных перезапусков.';

  @override
  String get appUpdate => 'Обновление приложения';

  @override
  String get appUpdateChecking => 'Проверка обновлений...';

  @override
  String get appUpdateFailed => 'Ошибка проверки обновлений';

  @override
  String get appUpdateSaveDialogTitle =>
      'Выберите папку для сохранения обновления';

  @override
  String get appUpdateDownloading => 'Загрузка обновления...';

  @override
  String get appUpdateDownloaded => 'Обновление успешно загружено';

  @override
  String get appUpdateOpenFolder => 'Открыть папку';

  @override
  String get appUpdateAvailable => 'Доступно обновление';

  @override
  String get appUpdateCurrentVersion => 'Текущая версия';

  @override
  String get appUpdateLatestVersion => 'Последняя версия';

  @override
  String get appUpdateReleaseNotes => 'Примечания к выпуску';

  @override
  String get appUpdateCheck => 'Проверить обновления';

  @override
  String get appUpdateDownload => 'Скачать обновление';

  @override
  String get appUpdateUpToDate => 'У вас последняя версия';

  @override
  String get internetQuality => 'Качество интернета';

  @override
  String get internetQualityAvg => 'Сред';

  @override
  String get internetQualityDeep => 'Глубокий (5м)';

  @override
  String get internetQualityDegraded => 'Ухудшено';

  @override
  String get internetQualityDirectDetails => 'Детали прямого качества';

  @override
  String get internetQualityDns => 'DNS';

  @override
  String get internetQualityDown => 'Отключено';

  @override
  String get internetQualityExcellent => 'Отлично';

  @override
  String get internetQualityGood => 'Хорошо';

  @override
  String get internetQualityHttps => 'HTTPS';

  @override
  String get internetQualityJitter => 'Джиттер';

  @override
  String get internetQualityLastCheck => 'Последняя проверка';

  @override
  String get internetQualityLight => 'Лёгкий (15с)';

  @override
  String get internetQualityMax => 'Макс';

  @override
  String get internetQualityMed => 'Медиана';

  @override
  String get internetQualityMin => 'Мин';

  @override
  String get internetQualityMonitoring => 'Фоновый мониторинг';

  @override
  String get internetQualityNoResult => 'Нет результата';

  @override
  String get internetQualityNormal => 'Обычный (2м)';

  @override
  String get internetQualityNotTested => 'Не тестировано';

  @override
  String get internetQualityOff => 'Выкл';

  @override
  String get internetQualityP95 => 'P95';

  @override
  String get internetQualityQuality => 'Качество';

  @override
  String get internetQualitySnackbar => 'Интернет:';

  @override
  String get internetQualityStatusFailing => 'Сбой';

  @override
  String get internetQualityStatusOk => 'ОК';

  @override
  String get internetQualityStatusPartial => 'Частично';

  @override
  String get internetQualityStatusSlow => 'Медленно';

  @override
  String get internetQualityStatusUnknown => 'Неизвестно';

  @override
  String get internetQualityTcp => 'TCP';

  @override
  String get internetQualityTest => 'Тест';

  @override
  String get internetQualityUnstable => 'Нестабильно';

  @override
  String get wireguardSettings => 'Настройки WireGuard';

  @override
  String get wireguardCoreTitle => 'Ядро WireGuard';

  @override
  String get wireguardCoreDescription =>
      'Выберите реализацию WireGuard. Amnezia добавляет обфускацию для жёсткой цензуры.';

  @override
  String get wireguardCoreStandard => 'Стандартное (wireguard-go)';

  @override
  String get wireguardCoreAmnezia => 'Amnezia (wireguard-awg)';

  @override
  String get tunnelHealth => 'Состояние туннеля';

  @override
  String get tunnelHealthProbeAll => 'Проверить все';

  @override
  String get tunnelHealthProbeAgain => 'Повторить';

  @override
  String tunnelHealthNotRunning(String tunnel) {
    return '$tunnel не запущен';
  }

  @override
  String get tunnelHealthNoTunnelRunning => 'Ни один туннель не запущен';

  @override
  String get tunnelHealthStopped => 'Остановлен';

  @override
  String get tunnelHealthReachable => 'Доступен (проверка ОК)';

  @override
  String get tunnelHealthMeasuring => 'Измерение…';

  @override
  String get tunnelHealthExcellent => 'Отлично';

  @override
  String get tunnelHealthGood => 'Хорошо';

  @override
  String get tunnelHealthFair => 'Средне';

  @override
  String get tunnelHealthDegraded => 'Ухудшено';

  @override
  String get tunnelHealthFailing => 'Сбой';

  @override
  String get tunnelHealthLatency => 'Задержка';

  @override
  String get tunnelHealthLoss => 'Потери';

  @override
  String get tunnelHealthJitter => 'Джиттер';

  @override
  String get tunnelHealthUptime => 'Время работы';

  @override
  String get tunnelHealthReconnects => 'Переподключения';

  @override
  String get tunnelHealthTrend => 'Тренд';

  @override
  String get tunnelHealthProtocol => 'Протокол';

  @override
  String get tunnelHealthThroughput => 'Пропускная способность';

  @override
  String get tunnelHealthCircuits => 'Цепи';

  @override
  String get tunnelHealthIp => 'IP';

  @override
  String tunnelHealthLastProbeOk(int latency) {
    return 'Последняя проверка: ${latency}ms — ОК';
  }

  @override
  String tunnelHealthLastProbeFailed(String error) {
    return 'Последняя проверка не удалась: $error';
  }

  @override
  String get tunnelHealthNoDataWarning =>
      'Туннель поднят, но данные не проходят';

  @override
  String get tunnelHealthMeasuringHealth => 'Измерение состояния…';

  @override
  String tunnelHealthTitle(String tunnel) {
    return 'Состояние $tunnel';
  }

  @override
  String get wireguardConfig => 'Конфигурация WireGuard';

  @override
  String get wireguardConfigHint =>
      'Вставьте стандартный конфиг WireGuard (формат INI) или URI с протоколом wireguard://. Приложение автоматически определит формат.';

  @override
  String get wireguardConfigInvalid =>
      'Неверный конфиг WireGuard — проверьте PrivateKey, PublicKey и Endpoint.';

  @override
  String get wireguardFormatStandard => 'СТАНДАРТ';

  @override
  String get wireguardFormatUri => 'URI';

  @override
  String get wireguardConvertToUri => 'Преобразовать в URI';

  @override
  String get wireguardConvertToStandard => 'Преобразовать в стандарт';

  @override
  String get wireguardLoadConfFile => 'Загрузить файл .conf';

  @override
  String get wireguardConfFileLoaded => 'Конфиг WireGuard загружен из файла';

  @override
  String get wireguardConfFileEmpty => 'Выбранный файл пуст';

  @override
  String get wireguardConfFileReadError =>
      'Не удалось прочитать выбранный файл';

  @override
  String get wireguardConnected => 'WireGuard подключён';

  @override
  String get autoReconnectWireGuard => 'Авто-переподключение WireGuard';

  @override
  String get logSourceWireGuard => 'WireGuard';

  @override
  String get torViaWireGuard => 'Через WireGuard (Tor-over-WireGuard)';

  @override
  String get psiphonWireGuardUpstream => 'WireGuard (SOCKS upstream)';

  @override
  String get sstpWireGuardUpstream => 'WireGuard (SOCKS upstream)';

  @override
  String get diagnosticsReport => 'Диагностический отчёт';

  @override
  String get diagnosticsReportGenerate => 'Создать отчёт';

  @override
  String get diagnosticsReportCopy => 'Копировать';

  @override
  String get diagnosticsReportSave => 'Сохранить';

  @override
  String get diagnosticsReportGenerated => 'Отчёт успешно создан';

  @override
  String get diagnosticsReportCopied => 'Отчёт скопирован';

  @override
  String diagnosticsReportSaved(String path) {
    return 'Отчёт сохранён: $path';
  }

  @override
  String get diagnosticsReportRedacted => 'Конфиденциальные данные удалены';

  @override
  String get diagnosticsReportPreview => 'Предпросмотр';

  @override
  String get diagnosticsReportClose => 'Закрыть';

  @override
  String get diagnosticsReportGenerating => 'Создание отчёта…';

  @override
  String get amneziaLinkDetected => 'Обнаружена ссылка Amnezia VPN';

  @override
  String get amneziaLinkName => 'Название';

  @override
  String get amneziaLinkEndpoint => 'API Endpoint';

  @override
  String get amneziaLinkHint =>
      'Нажмите «Получить конфиг», чтобы получить реальную конфигурацию AmneziaWG из API.';

  @override
  String get amneziaFetch => 'Получить конфиг';

  @override
  String get amneziaFetching => 'Получение…';

  @override
  String get amneziaFetchSuccess => 'Конфигурация AmneziaWG успешно получена';

  @override
  String get amneziaFetchFailed => 'Не удалось получить конфигурацию AmneziaWG';

  @override
  String get amneziaCoreRequired =>
      'Для ссылок vpn:// требуется ядро AmneziaWG. Приложение выберет его автоматически.';

  @override
  String get amneziaApiError => 'Ошибка API Amnezia';

  @override
  String get amneziaInvalidLink => 'Неверный формат ссылки vpn://';

  @override
  String get bridgeScanner => 'Сканер мостов';

  @override
  String get bridgeScannerDescription =>
      'Получение и тестирование мостов Tor (obfs4, webtunnel, snowflake, meek, conjure). Цветовая индикация задержки помогает выбрать те, что реально работают в вашей сети.';

  @override
  String get bridgeLines => 'Строки мостов (по одной на строку)';

  @override
  String get bridgeLinesHint =>
      'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get bridgeThreads => 'Потоки';

  @override
  String get bridgeStartScan => 'Начать сканирование';

  @override
  String get bridgeStopScan => 'Стоп';

  @override
  String get bridgeResults => 'Результаты';

  @override
  String bridgeApplyWorking(int count) {
    return 'Применить рабочие ($count)';
  }

  @override
  String bridgeApplyWorkingSnackbar(int count) {
    return 'Применено $count рабочих мостов к настройкам Tor';
  }

  @override
  String bridgeApplyWorkingRestarting(int count) {
    return 'Применено $count мостов — перезапуск Tor для применения';
  }

  @override
  String bridgeApplyWorkingTorNotRunning(int count) {
    return 'Применено $count мостов — запустите Tor для использования';
  }

  @override
  String bridgeFetch(String transport) {
    return 'Получить $transport';
  }

  @override
  String get bridgeSaveWorking => 'Сохранить рабочие';

  @override
  String get bridgeLoadSaved => 'Загрузить сохранённые';

  @override
  String get bridgeRescanSaved => 'Пересканировать сохранённые';

  @override
  String get bridgeClearSaved => 'Очистить сохранённые';

  @override
  String bridgeSavedCount(int count) {
    return 'Сохранено: $count';
  }

  @override
  String get bridgeNoSaved => 'Нет сохранённых мостов';

  @override
  String get bridgeSavedBridges => 'Сохранённые мосты';

  @override
  String bridgeSaveSuccess(int count) {
    return 'Сохранено мостов: $count';
  }

  @override
  String bridgeLoadedSuccess(int count) {
    return 'Загружено сохранённых мостов: $count';
  }

  @override
  String bridgeRescanStarted(int count) {
    return 'Пересканирование $count сохранённых мостов';
  }

  @override
  String get bridgeClearedSaved => 'Сохранённые мосты очищены';

  @override
  String get bridgeNothingToSave => 'Нет рабочих мостов для сохранения';

  @override
  String get bridgeLoadFromScanner => 'Загрузить из сканера мостов';

  @override
  String get bridgeLoadFromScannerSubtitle =>
      'Загрузить сохранённые рабочие мосты из раздела сканера мостов ниже';

  @override
  String get bridgeNoSavedInScanner =>
      'В сканере мостов пока нет сохранённых мостов';

  @override
  String get logSourceFfvpn => 'Firefox VPN';

  @override
  String get ffvpnSettings => 'Настройки Firefox VPN';

  @override
  String get ffvpnGuideTitle => 'Токен сессии аккаунта Firefox';

  @override
  String get ffvpnGuideIntro =>
      'Этот прокси использует встроенный VPN браузера Firefox (IP Protection на базе Mozilla VPN). Ему нужен токен сессии вашего Firefox Account:';

  @override
  String get ffvpnGuideStep1 =>
      '1. Создайте аккаунт Firefox или войдите в него в самом браузере Firefox, чтобы сессия сохранилась в браузере.';

  @override
  String get ffvpnGuideStep2 =>
      '2. Откройте about:profiles в Firefox, чтобы найти корневую папку профиля по умолчанию.';

  @override
  String get ffvpnGuideStep3 =>
      '3. Откройте signedInUser.json в этой папке, скопируйте значение accountData.sessionToken (шестнадцатеричная строка из 64 символов) и вставьте ниже.';

  @override
  String get ffvpnPathWindows =>
      'Windows: %APPDATA%\\Mozilla\\Firefox\\Profiles\\<profile>\\signedInUser.json';

  @override
  String get ffvpnPathLinux =>
      'Linux: ~/.mozilla/firefox/<profile>/signedInUser.json';

  @override
  String get ffvpnTokenLabel => 'Токен сессии Firefox Account';

  @override
  String get ffvpnTokenHint =>
      '64 шестнадцатеричных символа — accountData.sessionToken из signedInUser.json';

  @override
  String get ffvpnPortSocks => 'Порт SOCKS';

  @override
  String get ffvpnPortHttp => 'Порт HTTP (0 = выкл)';

  @override
  String get ffvpnSniLabel => 'SNI в TLS';

  @override
  String get ffvpnSniHint =>
      'Имя хоста в ClientHello к краю прокси Firefox — оставьте пустым, чтобы использовалось имя края';

  @override
  String get ffvpnUpstreamSection => 'Восходящий SOCKS-прокси';

  @override
  String get ffvpnUpstreamDesc =>
      'Firefox VPN сначала подключается к этому узлу SOCKS5 и только потом к краю прокси Firefox. Используйте, если край заблокирован или недоступен напрямую.';

  @override
  String get ffvpnUpstreamDirect => 'Напрямую (без восходящего узла)';

  @override
  String get ffvpnUpstreamManual => 'Ручной SOCKS5-прокси';

  @override
  String get ffvpnUpstreamPsiphon => 'Psiphon (SOCKS)';

  @override
  String get ffvpnUpstreamTor => 'Tor (SOCKS)';

  @override
  String get ffvpnUpstreamSstp => 'SSTP (SOCKS)';

  @override
  String get ffvpnUpstreamWireguard => 'WireGuard (SOCKS)';

  @override
  String ffvpnUpstreamVia(String name, String port) {
    return '$name используется как восходящий узел (SOCKS на 127.0.0.1:$port) и запускается автоматически, если ещё не работает.';
  }

  @override
  String get ffvpnUpstreamManualNote =>
      'Имя хоста всегда отправляется прокси, чтобы DNS разрешался там.';

  @override
  String get ffvpnCountrySection => 'Страна выхода';

  @override
  String get ffvpnCountryAuto => 'Автоматически (рекомендация сервера)';

  @override
  String get ffvpnLoadCountries => 'Загрузить список стран';

  @override
  String get ffvpnCountriesLoading => 'Загрузка списка стран…';

  @override
  String get ffvpnCountriesEmpty =>
      'Страны ещё не загружены — нажмите «Загрузить список стран».';

  @override
  String get ffvpnShowPremium =>
      'Показывать страны только для премиум-аккаунтов';

  @override
  String get ffvpnShowPremiumDesc =>
      'Страны, заблокированные без подписки Mozilla VPN; по умолчанию скрыты, как в самом Firefox.';

  @override
  String get ffvpnPremiumTag => 'премиум';

  @override
  String get ffvpnQuotaSection => 'Месячная квота трафика';

  @override
  String get ffvpnCheckQuota => 'Проверить квоту';

  @override
  String get ffvpnQuotaLoading => 'Проверка квоты…';

  @override
  String ffvpnQuotaUsedOf(String used, String total, String percent) {
    return 'Использовано $used из $total ($percent%)';
  }

  @override
  String ffvpnQuotaLeft(String remaining) {
    return 'Осталось $remaining';
  }

  @override
  String ffvpnQuotaResets(String date) {
    return 'Сброс $date';
  }

  @override
  String get ffvpnQuotaUnlimited =>
      'Безлимитный трафик — месячная квота не применяется.';

  @override
  String get ffvpnQuotaNoToken =>
      'Введите токен сессии выше, чтобы проверить квоту.';

  @override
  String get ffvpnErrNotEntitled =>
      'У этого аккаунта Firefox нет подписки Mozilla VPN (HTTP 403) — прокси-сервис требует её.';

  @override
  String get ffvpnErrRegion => 'Сервис недоступен в вашем регионе (HTTP 451).';

  @override
  String get ffvpnErrBadToken =>
      'Токен сессии недействителен или истёк. Войдите в Firefox заново и скопируйте свежий токен из signedInUser.json.';

  @override
  String get ffvpnErrQuota =>
      'Месячная квота трафика исчерпана — дождитесь даты сброса.';

  @override
  String get ffvpnErrBinaryMissing =>
      'Бинарный файл ffvpn не найден в папке данных приложения.';

  @override
  String get ffvpnErrNetwork =>
      'Сетевая ошибка при обращении к Mozilla — проверьте соединение (возможно, нужен другой туннель) и повторите.';

  @override
  String get ffvpnErrOther => 'Ошибка ffvpn';

  @override
  String get logSourceLantern => 'Lantern';

  @override
  String get lanternSettings => 'Настройки Lantern';

  @override
  String get lanternConnectionSection => 'Подключение';

  @override
  String get lanternPortSocks => 'Порт SOCKS';

  @override
  String get lanternPortHttp => 'Порт HTTP (0 = выкл.)';

  @override
  String get lanternUpstreamSection => 'Апстрим-прокси';

  @override
  String get lanternUpstreamDirect => 'Нет (напрямую)';

  @override
  String get lanternUpstreamManual => 'Ручной прокси';

  @override
  String get lanternUpstreamPsiphon => 'Psiphon';

  @override
  String get lanternUpstreamTor => 'Tor';

  @override
  String get lanternUpstreamSstp => 'SSTP';

  @override
  String get lanternUpstreamWireguard => 'WireGuard';

  @override
  String get lanternUpstreamDesc =>
      'Соединения с серверами Lantern (а если они недоступны — и ваш трафик) идут через этот прокси; используйте его, когда IP-адреса серверов Lantern заблокированы.';

  @override
  String get lanternUpstreamManualNote =>
      'Допустимые схемы: socks5://, socks5h://, http:// и https://.';

  @override
  String lanternUpstreamVia(String name, String port) {
    return '$name — апстрим-хоп (SOCKS на 127.0.0.1:$port); если он не запущен, будет запущен автоматически.';
  }

  @override
  String get lanternToolsSection => 'Инструменты Lantern';

  @override
  String get lanternToolsServers => 'Серверы';

  @override
  String get lanternToolsRefreshServers => 'Обновить список';

  @override
  String get lanternToolsCheckServers => 'Проверить доступность';

  @override
  String get lanternServerReachable => 'Доступен';

  @override
  String get lanternServerUnreachable => 'Недоступен';

  @override
  String get lanternServerNotChecked => 'Не проверен';

  @override
  String get lanternToolsAuth => 'Аккаунт';

  @override
  String get lanternEmailLabel => 'Эл. почта';

  @override
  String get lanternPasswordLabel => 'Пароль';

  @override
  String get lanternLoginBtn => 'Вход';

  @override
  String get lanternSignupBtn => 'Регистрация';

  @override
  String get lanternLogoutBtn => 'Выход';

  @override
  String get lanternRunning => 'Выполняется';
}
