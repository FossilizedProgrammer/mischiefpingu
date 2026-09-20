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
  String get appSubtitle => 'Неофициальный клиент Psiphon, Aether, Tor, SSTP';

  @override
  String get add => 'Добавить';

  @override
  String get addNew => 'Добавить новое';

  @override
  String get aetherConnected => 'Aether подключён';

  @override
  String get aetherSettings => 'Настройки Aether';

  @override
  String get aetherSocksUpstream => 'Aether (SOCKS upstream)';

  @override
  String get aetherUpstream => 'Aether (SOCKS upstream)';

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
  String get autoReconnectAether => 'Авто-переподключение Aether';

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
  String get both => 'Оба';

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
  String get connectionMode => 'Режим подключения';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

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
  String get customEndpoint => 'Пользовательский endpoint (опционально)';

  @override
  String get customEndpointHint => 'Оставьте пустым для авто-сканирования';

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
  String get ipType => 'Тип IP';

  @override
  String get ipsCidrRanges => 'IP / CIDR / Диапазоны';

  @override
  String get ipv4 => 'IPv4';

  @override
  String get ipv4Only => 'Только IPv4';

  @override
  String get ipv6 => 'IPv6';

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
  String get localSocksPort => 'Локальный порт SOCKS';

  @override
  String get log => 'Лог';

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
  String get obfAggressive => 'Агрессивная';

  @override
  String get obfBalanced => 'Сбалансированная';

  @override
  String get obfFirewall => 'Файрвол';

  @override
  String get obfGfw => 'GFW';

  @override
  String get obfLight => 'Лёгкая';

  @override
  String get obfOff => 'Выкл';

  @override
  String get obfuscation => 'Обфускация (--noize)';

  @override
  String get officialCore => 'официальное ядро Psiphon';

  @override
  String get password => 'Пароль';

  @override
  String get passwordOptional => 'Пароль (опционально)';

  @override
  String get port => 'Порт';

  @override
  String get preset1Subtitle =>
      'Использует ядро SunAndLion Psiphon (неофициальный форк).';

  @override
  String get preset1Title => '1 · Фронтинг (CDN). Лучше для жёсткой цензуры.';

  @override
  String get preset2Subtitle =>
      'Использует официальное ядро Psiphon с upstream Aether.';

  @override
  String get preset2Title =>
      '2 · Трафик Aether как upstream. Подходит, когда Aether работает.';

  @override
  String get preset3Subtitle => 'Использует протоколы INPROXY-WEBRTC Psiphon.';

  @override
  String get preset3Title =>
      '3 · Conduit (WebRTC Inproxy). Децентрализованные ретрансляторы.';

  @override
  String get preset4Subtitle => 'Использует официальное ядро Psiphon напрямую.';

  @override
  String get preset4Title =>
      '4 · Прямое подключение. Подходит для мягкой цензуры.';

  @override
  String get profile => 'Профиль';

  @override
  String get profileAdaptive => 'Адаптивный';

  @override
  String get profileAdaptiveDesc =>
      'Баланс скорости и покрытия — подходит для большинства сетей';

  @override
  String get profileManual => 'Ручной';

  @override
  String get profileManualDesc =>
      'Все опции вручную — для продвинутых пользователей';

  @override
  String get profilePatchy => 'Нестабильный сигнал';

  @override
  String get profilePatchyDesc =>
      'Нестабильные мобильные данные — более сложный и устойчивый поиск';

  @override
  String get profileStrict => 'Строгая сеть';

  @override
  String get profileStrictDesc =>
      'Ограниченный Wi-Fi или жёсткая фильтрация — fragment + masque-in-masque + noize gfw';

  @override
  String get protoGool => 'Gool (WARP-in-WARP)';

  @override
  String get protoMasque => 'MASQUE (HTTP/3 или HTTP/2)';

  @override
  String get protoMim => 'MIM (masque-in-masque)';

  @override
  String get protoWireguard => 'WireGuard';

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
  String get scanBalanced => 'Сбалансированный';

  @override
  String get scanIronclad => 'Железный';

  @override
  String get scanMode => 'Режим сканирования';

  @override
  String get scanStealth => 'Скрытный';

  @override
  String get scanThorough => 'Тщательный';

  @override
  String get scanTurbo => 'Турбо';

  @override
  String get select => 'Выбрать…';

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
      'Внешний вид, Aether, Psiphon, Tor, сканер, обновления, лог';

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
  String get torViaAether => 'Через Aether (Tor-over-Aether)';

  @override
  String get torViaPsiphon => 'Через Psiphon (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'Через SSTP (Tor-over-SSTP)';

  @override
  String get tryLastEndpointFirst =>
      'Сначала попробовать последний успешный endpoint';

  @override
  String get tryLastEndpointFirstSubtitle =>
      'Если включено, попробует последний рабочий endpoint перед сканированием';

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
}
