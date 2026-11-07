// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mischief Pingu';

  @override
  String get appSubtitle =>
      'Cliente no oficial de Psiphon, clientes de Tor, SSTP y WireGuard';

  @override
  String get appSubtitle2 =>
      'Firefox VPN, cliente no oficial de Lantern, cliente no oficial de Geph, NPV (napsternetV)';

  @override
  String get add => 'Añadir';

  @override
  String get addNew => 'Añadir nuevo';

  @override
  String get allServers => 'Todos los servidores';

  @override
  String get any => 'Cualquiera';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appliedTop20Ips => 'Se aplicaron los 20 mejores IP';

  @override
  String get appliedTop5Ips => 'Se aplicaron los 5 mejores IP + SNI';

  @override
  String get applyTop20 => 'Aplicar Top 20';

  @override
  String get applyTop5 => 'Aplicar Top 5';

  @override
  String get authenticationOptional => 'Autenticación (opcional)';

  @override
  String get autoFindIpSni => 'Buscar IP y SNI automáticamente';

  @override
  String get autoFirstProxy => 'Auto (primer proxy activo)';

  @override
  String get autoFirstRunningProxy => 'Auto (primer proxy activo)';

  @override
  String get autoReconnectPsiphon => 'Reconexión automática de Psiphon';

  @override
  String get autoReconnectSstp => 'Reconexión automática de SSTP';

  @override
  String get autoReconnectTor => 'Reconexión automática de Tor';

  @override
  String get autoRefresh15Min => 'Actualizar cada 15 minutos automáticamente';

  @override
  String get autoRefreshSubtitle =>
      'Obtiene servidores nuevos y revisa su estado de salud de forma automática';

  @override
  String get binaryNotFound => 'Binario no encontrado';

  @override
  String get bridgePresets => 'Presets de puentes (opcional)';

  @override
  String get bridges =>
      'Puentes (uno por línea, se admiten personalizados — incl. webtunnel)';

  @override
  String get bridgesHint => 'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelBtn => 'Cancelar';

  @override
  String get cdnPreset => 'Preset de CDN';

  @override
  String get cdnScanner => 'Escáner de IP de CDN';

  @override
  String get cdnScanModeQuick => 'Rápido';

  @override
  String get cdnScanModeBalanced => 'Equilibrado';

  @override
  String get cdnScanModeDeep => 'Profundo';

  @override
  String cdnScanModeQuickDesc(String samples, String max) {
    return 'Rápido · $samples IP por CIDR · hasta $max en total · ~1-2 min';
  }

  @override
  String cdnScanModeBalancedDesc(String samples, String max) {
    return 'Equilibrado · $samples IP por CIDR · hasta $max en total · ~5-10 min';
  }

  @override
  String cdnScanModeDeepDesc(String max) {
    return 'Profundo · expansión completa · hasta $max en total · ~30-60 min';
  }

  @override
  String get cdnScoutTitle => 'Encontrar SNI que funcionan (recomendado)';

  @override
  String cdnScoutProgress(String done, String total) {
    return 'Explorando $done/$total…';
  }

  @override
  String get cdnScoutHint =>
      'Los SNI de Discord/Reddit están bloqueados en Irán. El explorador encuentra los que funcionan.';

  @override
  String get cdnScoutButton => 'Explorar';

  @override
  String cdnScanPreview(String lines, String ips) {
    return '$lines líneas · se escanearán $ips IP';
  }

  @override
  String cdnScanWarningsMore(String count) {
    return '…y $count más';
  }

  @override
  String cdnApplyIpsToPsiphon(String count) {
    return 'Aplicar $count IP a Psiphon';
  }

  @override
  String cdnApplyIpsSnack(String count, String ip, String sni) {
    return '$count IP → Psiphon\nIP de fronting: $ip\nSNI: $sni';
  }

  @override
  String get cdnSendToPsiphon => 'Enviar a Psiphon';

  @override
  String get cdnSaveEnteredIps => 'Guardar las IP introducidas';

  @override
  String cdnIpsSavedSnack(String count, String total) {
    return '$count IP guardadas ($total en la lista)';
  }

  @override
  String cdnCustomIpsSent(String count, String ip) {
    return '$count IP personalizadas → Psiphon (fronting: $ip)';
  }

  @override
  String cdnResultSubtitle(String score, String reliability, String latency,
      String download, String sni) {
    return 'Puntuación $score · Fiab $reliability/5 · ${latency}ms · desc ${download}ms · $sni';
  }

  @override
  String get check => 'Comprobar';

  @override
  String get checkHealth => 'Comprobar estado';

  @override
  String get checking => 'Comprobando…';

  @override
  String get clear => 'Limpiar';

  @override
  String get clearAll => 'Limpiar todo';

  @override
  String get clearLog => 'Limpiar';

  @override
  String get close => 'Cerrar';

  @override
  String get colorTheme => 'Tema de color';

  @override
  String get colorThemeSubtitle =>
      'Elige una combinación de colores para toda la aplicación.';

  @override
  String get conduitWebrtc => 'Conduit (WebRTC Inproxy)';

  @override
  String get connected => 'Conectado';

  @override
  String get connecting => 'Conectando…';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get copyAllToClipboard => 'Copiar todo';

  @override
  String get importFromClipboard => 'Importar del portapapeles';

  @override
  String get importedFromClipboard => 'Importado del portapapeles';

  @override
  String get nothingToImport => 'El portapapeles está vacío';

  @override
  String get itemsAddedCount => 'Elementos añadidos';

  @override
  String get copy => 'Copiar';

  @override
  String get copyAllCsv => 'Copiar todo (CSV con detalles)';

  @override
  String get copyAllIpPort => 'Copiar todo (ip:puerto)';

  @override
  String get copyLog => 'Copiar';

  @override
  String get coreUpdates => 'Actualizaciones de núcleos';

  @override
  String get customIps => 'IP personalizadas';

  @override
  String get delete => 'Eliminar';

  @override
  String get directNoProxy => 'Directo (sin proxy)';

  @override
  String get directNoProxyOption => 'Directo (sin proxy)';

  @override
  String get directNoUpstream => 'Directo (sin upstream)';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get disconnectingTunnels => 'Desconectando los túneles activos…';

  @override
  String get download => 'Descarga';

  @override
  String get downloadVia => 'Descargar a través de';

  @override
  String get downloadViaSubtitle =>
      'Las comprobaciones y descargas usan el proxy seleccionado cuando el acceso directo está filtrado.';

  @override
  String get egressRegion => 'Región de salida';

  @override
  String get enableLogging => 'Activar el registro';

  @override
  String get enableLoggingSubtitle =>
      'Cuando está apagado no se recogen registros nuevos';

  @override
  String get exitCountry => 'País de salida';

  @override
  String get exitCountryAny => 'Cualquiera (aleatorio)';

  @override
  String get fetch => 'Obtener';

  @override
  String get fetchVia => 'Obtener a través de';

  @override
  String get fetching => 'Obteniendo…';

  @override
  String get fingerprint => 'Huella digital';

  @override
  String get frontingAdvanced => 'Fronting (avanzado, opcional)';

  @override
  String get frontingIp => 'IP de fronting';

  @override
  String get httpHostHeader =>
      'Encabezado HTTP Host (p. ej. aparat.com, snapp.ir)';

  @override
  String get httpPort => 'Puerto HTTP';

  @override
  String get installed => 'Instalado';

  @override
  String get ipsCidrRanges => 'IP / CIDR / Rangos';

  @override
  String get ipv4Only => 'Solo IPv4';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFarsi => 'فارسی';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSpanish => 'Español';

  @override
  String get latest => 'Última';

  @override
  String get lines => 'líneas';

  @override
  String get listIsEmpty => 'La lista está vacía';

  @override
  String get localProxyPorts => 'Puertos de proxy locales';

  @override
  String get log => 'Registro';

  @override
  String get logSourceFilter => 'Filtrar fuentes de registro';

  @override
  String get logSourcePsiphon => 'Psiphon';

  @override
  String get logSourceTor => 'Tor';

  @override
  String get logSourceSstp => 'SSTP';

  @override
  String get logSourceApp => 'Aplicación';

  @override
  String get logSourceSystem => 'Sistema';

  @override
  String get manageList => 'Gestionar lista (añadir / eliminar)';

  @override
  String get manualProxy => 'Proxy manual';

  @override
  String get manualProxyOption => 'Proxy manual';

  @override
  String get muteSounds => 'Silenciar sonidos';

  @override
  String get muteSoundsSubtitle =>
      'Desactiva todos los sonidos del pingüino (ay / suspiro / feliz). Las reacciones visuales se siguen mostrando.';

  @override
  String get noCustomIpsSaved => 'Aún no hay IP personalizadas guardadas';

  @override
  String get noLogsYet => 'Aún no hay registros';

  @override
  String get noUpstreamDirect => 'Sin upstream (directo)';

  @override
  String get notInstalled => 'No instalado';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get obfOff => 'Desactivado';

  @override
  String get officialCore => 'núcleo oficial de Psiphon Tunnel';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordOptional => 'Contraseña (opcional)';

  @override
  String get port => 'Puerto';

  @override
  String portRangeError(int min, int max) {
    return 'Introduce un número de puerto entre $min y $max';
  }

  @override
  String get preset1Subtitle =>
      'Usa el núcleo SunAndLion Psiphon Tunnel (bifurcación no oficial del núcleo de Psiphon).';

  @override
  String get preset1Title => '1 · Fronting (CDN). Ideal para censura intensa.';

  @override
  String get preset2Subtitle =>
      'Usa los protocolos INPROXY-WEBRTC de Psiphon a través de estaciones de voluntarios.';

  @override
  String get preset2Title =>
      '2 · Conduit (WebRTC Inproxy). Relés descentralizados entre pares.';

  @override
  String get preset3Subtitle =>
      'Usa directamente el núcleo oficial de Psiphon Tunnel.';

  @override
  String get preset3Title =>
      '3 · Conexión directa. Adecuada para censura ligera.';

  @override
  String get profile => 'Perfil';

  @override
  String get aetherPresetControlsNote =>
      'El protocolo, el modo de escaneo y la ofuscación siguen al preset seleccionado. Elige Manual para editarlos.';

  @override
  String get protocol => 'Protocolo';

  @override
  String get proxyIp => 'IP del proxy';

  @override
  String get proxyType => 'Tipo de proxy';

  @override
  String get psiphonConnectedVia => 'Psiphon conectado a través de';

  @override
  String get psiphonConnectionMode => 'Modo de conexión de Psiphon';

  @override
  String get psiphonSettings => 'Ajustes de Psiphon';

  @override
  String get psiphonUpstream => 'Psiphon';

  @override
  String get save => 'Guardar';

  @override
  String get saveFoundIpsSni =>
      'Guardar automáticamente las IP y el SNI encontrados';

  @override
  String get scanMode => 'Modo de escaneo';

  @override
  String get select => 'Seleccionar...';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get server => 'Servidor';

  @override
  String get serverAddress => 'Dirección del servidor';

  @override
  String get shareOnLan => 'Compartir en la red local (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphon => 'Compartir en la red local (bind 0.0.0.0)';

  @override
  String get shareOnLanPsiphonSubtitle =>
      'Reenvía los puertos SOCKS y HTTP en todas las interfaces mediante Dart';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get showLessSubtitle => 'Ocultar ajustes avanzados y registros';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get showMoreSubtitle =>
      'Apariencia, Psiphon, Tor, SSTP, WireGuard, Firefox VPN, Lantern, Geph, Escáner, Actualizaciones, Registro';

  @override
  String get sni => 'SNI';

  @override
  String get sniList => 'Lista de SNI (uno por línea, el orden es prioridad)';

  @override
  String get socksPort => 'Puerto SOCKS';

  @override
  String get sstpConnected => 'SSTP conectado';

  @override
  String get sstpSettings => 'Ajustes de SSTP';

  @override
  String get sstpSocksUpstream => 'SSTP';

  @override
  String get start => 'Iniciar';

  @override
  String get startScan => 'Iniciar escaneo';

  @override
  String get stop => 'Detener';

  @override
  String get stopHealthCheck => 'Detener';

  @override
  String get stopScan => 'Detener';

  @override
  String get sunandlionCore => 'núcleo sunandlion de Psiphon Tunnel';

  @override
  String get threads => 'Subprocesos';

  @override
  String get tlsSni => 'SNI de TLS (p. ej. a248.e.akamai.net)';

  @override
  String get torBridge => 'Puente (obfs4 / snowflake / personalizado)';

  @override
  String get torConnected => 'Tor conectado';

  @override
  String get torConnection => 'Conexión de Tor';

  @override
  String get torDirect => 'Directo (sin puente, sin upstream) — predeterminado';

  @override
  String get torManual => 'Proxy manual';

  @override
  String get torSettings => 'Ajustes de Tor';

  @override
  String get torSocksUpstream => 'Tor';

  @override
  String get torUpstream => 'Tor';

  @override
  String get torViaPsiphon => 'A través de Psiphon (Tor-over-Psiphon)';

  @override
  String get torViaSstp => 'A través de SSTP (Tor-over-SSTP)';

  @override
  String get torViaFfvpn => 'A través de Firefox VPN (Tor-over-Firefox VPN)';

  @override
  String get torViaLantern => 'A través de Lantern (Tor-over-Lantern)';

  @override
  String get torViaGeph => 'A través de Geph (Tor-over-Geph)';

  @override
  String get torUpstreamNpv => 'A través de NPV (Tor-over-NPV)';

  @override
  String get tunnelCore => 'Núcleo del túnel';

  @override
  String get update => 'Actualizar';

  @override
  String get upstream => 'Upstream';

  @override
  String get upstreamType => 'Tipo de upstream';

  @override
  String get usableIps => 'IP utilizables (ordenadas por puntuación)';

  @override
  String get useFronting => 'Usar fronting (CDN)';

  @override
  String get userOptional => 'Usuario (opcional)';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get verboseLogging => 'Registro detallado';

  @override
  String get verboseLoggingSubtitle =>
      'Activa la salida de depuración detallada de sstp-proxy';

  @override
  String get vpngateServers => 'Servidores SSTP de VPN Gate';

  @override
  String get working => 'Funcionando';

  @override
  String get watchdog => 'Watchdog';

  @override
  String get watchdogEnabled => 'Activar el watchdog';

  @override
  String get watchdogEnabledSubtitle =>
      'Reinicia automáticamente los túneles cuando dejan de responder';

  @override
  String get watchdogSettings => 'Ajustes del watchdog';

  @override
  String get backToPresets => 'Volver a los presets';

  @override
  String get watchdogNetworkProfile => 'Perfil de red';

  @override
  String get watchdogNetworkProfileSubtitle =>
      'Ajusta la agresividad con la que el watchdog sondea. Elígelo según las condiciones de tu red.';

  @override
  String get watchdogProfileStable => 'Estable';

  @override
  String get watchdogProfileStableDesc =>
      'Buena calidad de internet — sondeo estricto, detección más rápida de fallos.';

  @override
  String get watchdogProfileNormal => 'Normal';

  @override
  String get watchdogProfileNormalDesc =>
      'Ajuste equilibrado para la mayoría de las redes (predeterminado).';

  @override
  String get watchdogProfileHarsh => 'Filtrado severo';

  @override
  String get watchdogProfileHarshDesc =>
      'Filtrado intenso o red inestable — sondeo tolerante, menos reinicios falsos.';

  @override
  String get appUpdate => 'Actualización de la aplicación';

  @override
  String get appUpdateChecking => 'Buscando actualizaciones...';

  @override
  String get appUpdateFailed => 'La comprobación de actualizaciones falló';

  @override
  String get appUpdateSaveDialogTitle => 'Elige dónde guardar la actualización';

  @override
  String get appUpdateDownloading => 'Descargando la actualización...';

  @override
  String get appUpdateDownloaded => 'Actualización descargada correctamente';

  @override
  String get appUpdateOpenFolder => 'Abrir carpeta';

  @override
  String get appUpdateAvailable => 'Actualización disponible';

  @override
  String get appUpdateCurrentVersion => 'Versión actual';

  @override
  String get appUpdateLatestVersion => 'Última versión';

  @override
  String get appUpdateReleaseNotes => 'Notas de la versión';

  @override
  String get appUpdateCheck => 'Comprobar actualizaciones';

  @override
  String get appUpdateDownload => 'Descargar actualización';

  @override
  String get appUpdateUpToDate => 'Ya estás al día';

  @override
  String get internetQuality => 'Calidad de internet';

  @override
  String get internetQualityAvg => 'Media';

  @override
  String get internetQualityDeep => 'Profunda (5 min)';

  @override
  String get internetQualityDegraded => 'Degradada';

  @override
  String get internetQualityDirectDetails => 'Detalles de calidad directa';

  @override
  String get internetQualityDns => 'DNS';

  @override
  String get internetQualityDown => 'Descarga';

  @override
  String get internetQualityExcellent => 'Excelente';

  @override
  String get internetQualityGood => 'Buena';

  @override
  String get internetQualityHttps => 'HTTPS';

  @override
  String get internetQualityJitter => 'Fluctuación';

  @override
  String get internetQualityLastCheck => 'Última comprobación';

  @override
  String get internetQualityLight => 'Ligera (15 s)';

  @override
  String get internetQualityMax => 'Máx';

  @override
  String get internetQualityMed => 'Media';

  @override
  String get internetQualityMin => 'Mín';

  @override
  String get internetQualityMonitoring => 'Supervisión en segundo plano';

  @override
  String get internetQualityNoResult => 'Sin resultado';

  @override
  String get internetQualityNormal => 'Normal (2 min)';

  @override
  String get internetQualityNotTested => 'Sin probar';

  @override
  String get internetQualityOff => 'Desactivado';

  @override
  String get internetQualityP95 => 'P95';

  @override
  String get internetQualityQuality => 'Calidad';

  @override
  String get internetQualitySnackbar => 'Internet:';

  @override
  String get internetQualityStatusFailing => 'Fallando';

  @override
  String get internetQualityStatusOk => 'Correcto';

  @override
  String get internetQualityStatusPartial => 'Parcial';

  @override
  String get internetQualityStatusSlow => 'Lento';

  @override
  String get internetQualityStatusUnknown => 'Desconocido';

  @override
  String get internetQualityTcp => 'TCP';

  @override
  String get internetQualityTest => 'Probar';

  @override
  String get internetQualityUnstable => 'Inestable';

  @override
  String get wireguardSettings => 'Ajustes de WireGuard';

  @override
  String get wireguardCoreTitle => 'Núcleo de WireGuard';

  @override
  String get wireguardCoreDescription =>
      'Elige la implementación de WireGuard. Amnezia añade ofuscación para censura intensa.';

  @override
  String get wireguardCoreStandard => 'Estándar (wireguard-go)';

  @override
  String get wireguardCoreAmnezia => 'Amnezia (wireguard-awg)';

  @override
  String get tunnelHealth => 'Estado del túnel';

  @override
  String get tunnelHealthProbeAll => 'Probar todos';

  @override
  String get tunnelHealthProbeAgain => 'Volver a probar';

  @override
  String tunnelHealthNotRunning(String tunnel) {
    return '$tunnel no está en ejecución';
  }

  @override
  String get tunnelHealthNoTunnelRunning => 'Ningún túnel está en ejecución';

  @override
  String get tunnelHealthStopped => 'Detenido';

  @override
  String get tunnelHealthReachable => 'Alcanzable (sondeo correcto)';

  @override
  String get tunnelHealthMeasuring => 'Midiendo…';

  @override
  String get tunnelHealthExcellent => 'Excelente';

  @override
  String get tunnelHealthGood => 'Buena';

  @override
  String get tunnelHealthFair => 'Aceptable';

  @override
  String get tunnelHealthDegraded => 'Degradada';

  @override
  String get tunnelHealthFailing => 'Fallando';

  @override
  String get tunnelHealthLatency => 'Latencia';

  @override
  String get tunnelHealthLoss => 'Pérdida';

  @override
  String get tunnelHealthJitter => 'Fluctuación';

  @override
  String get tunnelHealthUptime => 'Tiempo activo';

  @override
  String get tunnelHealthReconnects => 'Reconexiones';

  @override
  String get tunnelHealthTrend => 'Tendencia';

  @override
  String get tunnelHealthProtocol => 'Protocolo';

  @override
  String get tunnelHealthThroughput => 'Rendimiento';

  @override
  String get tunnelHealthCircuits => 'Circuitos';

  @override
  String get tunnelHealthIp => 'IP';

  @override
  String tunnelHealthLastProbeOk(int latency) {
    return 'Último sondeo: ${latency}ms — correcto';
  }

  @override
  String tunnelHealthLastProbeFailed(String error) {
    return 'El último sondeo falló: $error';
  }

  @override
  String get tunnelHealthNoDataWarning =>
      'El túnel está activo pero no circulan datos';

  @override
  String get tunnelHealthMeasuringHealth => 'Midiendo el estado…';

  @override
  String tunnelHealthTitle(String tunnel) {
    return 'Estado de $tunnel';
  }

  @override
  String get wireguardConfig => 'Configuración de WireGuard';

  @override
  String get wireguardConfigHint =>
      'Pega una configuración estándar de WireGuard (formato INI) o una URI wireguard://. La aplicación detecta el formato automáticamente.';

  @override
  String get wireguardConfigInvalid =>
      'Configuración de WireGuard no válida — revisa PrivateKey, PublicKey y Endpoint.';

  @override
  String get wireguardFormatStandard => 'ESTÁNDAR';

  @override
  String get wireguardFormatUri => 'URI';

  @override
  String get wireguardConvertToUri => 'Convertir a URI';

  @override
  String get wireguardConvertToStandard => 'Convertir a estándar';

  @override
  String get wireguardLoadConfFile => 'Cargar archivo .conf';

  @override
  String get wireguardConfFileLoaded =>
      'Configuración de WireGuard cargada desde el archivo';

  @override
  String get wireguardConfFileEmpty => 'El archivo seleccionado está vacío';

  @override
  String get wireguardConfFileReadError =>
      'No se pudo leer el archivo seleccionado';

  @override
  String get wireguardConnected => 'WireGuard conectado';

  @override
  String get autoReconnectWireGuard => 'Reconexión automática de WireGuard';

  @override
  String get logSourceWireGuard => 'WireGuard';

  @override
  String get torViaWireGuard => 'A través de WireGuard (Tor-over-WireGuard)';

  @override
  String get psiphonWireGuardUpstream => 'WireGuard';

  @override
  String get sstpWireGuardUpstream => 'WireGuard';

  @override
  String get upstreamViaFfvpn => 'Firefox VPN';

  @override
  String get upstreamViaLantern => 'Lantern';

  @override
  String get upstreamViaGeph => 'Geph';

  @override
  String get psiphonUpstreamNpv => 'NPV';

  @override
  String get sstpUpstreamNpv => 'NPV';

  @override
  String get diagnosticsReport => 'Informe de diagnóstico';

  @override
  String get diagnosticsReportGenerate => 'Generar informe';

  @override
  String get diagnosticsReportCopy => 'Copiar informe';

  @override
  String get diagnosticsReportSave => 'Guardar informe';

  @override
  String get diagnosticsReportGenerated => 'Informe generado correctamente';

  @override
  String get diagnosticsReportCopied => 'Informe copiado al portapapeles';

  @override
  String diagnosticsReportSaved(String path) {
    return 'Informe guardado en: $path';
  }

  @override
  String get diagnosticsReportRedacted => 'Se han ocultado los datos sensibles';

  @override
  String get diagnosticsReportPreview => 'Vista previa';

  @override
  String get diagnosticsReportClose => 'Cerrar';

  @override
  String get diagnosticsReportGenerating => 'Generando informe…';

  @override
  String get amneziaLinkDetected => 'Enlace de Amnezia VPN detectado';

  @override
  String get amneziaLinkName => 'Nombre';

  @override
  String get amneziaLinkEndpoint => 'Endpoint de la API';

  @override
  String get amneziaLinkHint =>
      'Pulsa «Obtener configuración» para recuperar la configuración real de AmneziaWG desde la API.';

  @override
  String get amneziaFetch => 'Obtener configuración';

  @override
  String get amneziaFetching => 'Obteniendo…';

  @override
  String get amneziaFetchSuccess =>
      'Configuración de AmneziaWG obtenida correctamente';

  @override
  String get amneziaFetchFailed =>
      'No se pudo obtener la configuración de AmneziaWG';

  @override
  String get amneziaCoreRequired =>
      'Los enlaces vpn:// requieren el núcleo AmneziaWG. La aplicación lo seleccionará automáticamente.';

  @override
  String get amneziaApiError => 'Error de la API de Amnezia';

  @override
  String get amneziaInvalidLink => 'Formato de enlace vpn:// no válido';

  @override
  String get bridgeScanner => 'Escáner de puentes';

  @override
  String get bridgeScannerDescription =>
      'Obtén y prueba puentes de Tor (obfs4, webtunnel, snowflake, meek, conjure). La latencia con códigos de color te ayuda a elegir los que realmente funcionan en tu red.';

  @override
  String get bridgeLines => 'Líneas de puentes (uno por línea)';

  @override
  String get bridgeLinesHint =>
      'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0';

  @override
  String get bridgeThreads => 'Subprocesos';

  @override
  String get bridgeStartScan => 'Iniciar escaneo';

  @override
  String get bridgeStopScan => 'Detener';

  @override
  String get bridgeResults => 'Resultados';

  @override
  String bridgeApplyWorking(int count) {
    return 'Aplicar los que funcionan ($count)';
  }

  @override
  String bridgeApplyWorkingSnackbar(int count) {
    return 'Se aplicaron $count puentes funcionales a los ajustes de Tor';
  }

  @override
  String bridgeApplyWorkingRestarting(int count) {
    return 'Se aplicaron $count puentes — reiniciando Tor para aplicarlos';
  }

  @override
  String bridgeApplyWorkingTorNotRunning(int count) {
    return 'Se aplicaron $count puentes — inicia Tor para usarlos';
  }

  @override
  String bridgeFetch(String transport) {
    return 'Obtener $transport';
  }

  @override
  String get bridgeSaveWorking => 'Guardar los funcionales';

  @override
  String get bridgeLoadSaved => 'Cargar guardados';

  @override
  String get bridgeRescanSaved => 'Reescanear guardados';

  @override
  String get bridgeClearSaved => 'Borrar guardados';

  @override
  String bridgeSavedCount(int count) {
    return 'Guardados: $count';
  }

  @override
  String get bridgeNoSaved => 'Aún no hay puentes guardados';

  @override
  String get bridgeSavedBridges => 'Puentes guardados';

  @override
  String bridgeSaveSuccess(int count) {
    return '$count puentes guardados';
  }

  @override
  String bridgeLoadedSuccess(int count) {
    return 'Se cargaron $count puentes guardados';
  }

  @override
  String bridgeRescanStarted(int count) {
    return 'Reescaneando $count puentes guardados';
  }

  @override
  String get bridgeClearedSaved => 'Se borraron los puentes guardados';

  @override
  String get bridgeNothingToSave => 'No hay puentes funcionales que guardar';

  @override
  String get bridgeLoadFromScanner => 'Cargar desde el escáner de puentes';

  @override
  String get bridgeLoadFromScannerSubtitle =>
      'Carga los puentes funcionales guardados en la sección del escáner de puentes de abajo';

  @override
  String get bridgeNoSavedInScanner =>
      'Aún no hay puentes guardados en el escáner de puentes';

  @override
  String get logSourceFfvpn => 'Firefox VPN';

  @override
  String get ffvpnSettings => 'Ajustes de Firefox VPN';

  @override
  String get ffvpnLoginSection => 'Iniciar sesión con correo y contraseña';

  @override
  String get ffvpnLoginHint =>
      'Inicia sesión directamente en tu cuenta de Firefox y guarda abajo el token de sesión resultante — sin necesidad de rebuscar en signedInUser.json.';

  @override
  String get ffvpnEmailLabel => 'Correo de la cuenta de Firefox';

  @override
  String get ffvpnPasswordLabel => 'Contraseña';

  @override
  String get ffvpnSignIn => 'Iniciar sesión';

  @override
  String get ffvpnSigningIn => 'Iniciando sesión…';

  @override
  String get ffvpnSignedIn => 'Sesión iniciada — token guardado.';

  @override
  String get ffvpnGuideTitle => 'Token de sesión de la cuenta de Firefox';

  @override
  String get ffvpnGuideIntro =>
      'Este proxy usa la VPN de protección de IP integrada en el navegador Firefox (impulsada por Mozilla VPN). Necesita el token de sesión de tu cuenta de Firefox:';

  @override
  String get ffvpnGuideStep1 =>
      '1. Crea una cuenta de Firefox o inicia sesión dentro del propio navegador Firefox, para que el navegador guarde tu sesión.';

  @override
  String get ffvpnGuideStep2 =>
      '2. Abre about:profiles en Firefox para encontrar la carpeta raíz de tu perfil predeterminado.';

  @override
  String get ffvpnGuideStep3 =>
      '3. Abre signedInUser.json en esa carpeta y copia el valor de accountData.sessionToken (una cadena hexadecimal de 64 caracteres), luego pégalo abajo.';

  @override
  String get ffvpnPathWindows =>
      'Windows: %APPDATA%\\Mozilla\\Firefox\\Profiles\\<perfil>\\signedInUser.json';

  @override
  String get ffvpnPathLinux =>
      'Linux: ~/.mozilla/firefox/<perfil>/signedInUser.json';

  @override
  String get ffvpnTokenLabel => 'Token de sesión de la cuenta de Firefox';

  @override
  String get ffvpnTokenHint =>
      '64 caracteres hexadecimales — accountData.sessionToken de signedInUser.json';

  @override
  String get ffvpnPortSocks => 'Puerto SOCKS';

  @override
  String get ffvpnPortHttp => 'Puerto HTTP (0 = apagado)';

  @override
  String get ffvpnSniLabel => 'SNI de TLS';

  @override
  String get ffvpnSniHint =>
      'Nombre de host enviado en el ClientHello de TLS al borde del proxy de Firefox — déjalo vacío para usar el host del borde';

  @override
  String get ffvpnUpstreamSection => 'Proxy SOCKS de upstream';

  @override
  String get ffvpnUpstreamDesc =>
      'Firefox VPN se conecta primero a este salto SOCKS5 y solo después al borde del proxy de Firefox. Úsalo cuando el borde esté bloqueado o no sea alcanzable directamente.';

  @override
  String get ffvpnUpstreamDirect => 'Directo (sin upstream)';

  @override
  String get ffvpnUpstreamManual => 'Proxy SOCKS5 manual';

  @override
  String get ffvpnUpstreamPsiphon => 'Psiphon';

  @override
  String get ffvpnUpstreamTor => 'Tor';

  @override
  String get ffvpnUpstreamSstp => 'SSTP';

  @override
  String get ffvpnUpstreamWireguard => 'WireGuard';

  @override
  String get ffvpnUpstreamLantern => 'Lantern';

  @override
  String get ffvpnUpstreamGeph => 'Geph';

  @override
  String get ffvpnUpstreamNpv => 'NPV';

  @override
  String ffvpnUpstreamVia(String name, String port) {
    return '$name es el salto de upstream (SOCKS en 127.0.0.1:$port) y se inicia automáticamente si aún no está en ejecución.';
  }

  @override
  String get ffvpnUpstreamManualNote =>
      'El nombre de host siempre se envía al proxy, por lo que el DNS se resuelve allí.';

  @override
  String get ffvpnCountrySection => 'País de salida';

  @override
  String get ffvpnCountryAuto => 'Automático (recomendado por el servidor)';

  @override
  String get ffvpnLoadCountries => 'Cargar lista de países';

  @override
  String get ffvpnCountriesLoading => 'Cargando lista de países…';

  @override
  String get ffvpnCountriesEmpty =>
      'No hay países cargados todavía — pulsa \"Cargar lista de países\".';

  @override
  String get ffvpnCountriesFilteredOut =>
      'Ningún país coincide con el filtro seleccionado.';

  @override
  String get ffvpnCountryFilter => 'Mostrar';

  @override
  String get ffvpnCountryFilterAll => 'Todos los países';

  @override
  String get ffvpnCountryFilterFree => 'Solo gratuitos';

  @override
  String get ffvpnCountryFilterPlus => 'Solo premium';

  @override
  String get ffvpnCountryFilterHint =>
      'Los países que requieren una suscripción a Mozilla VPN se ocultan por defecto, igual que en Firefox.';

  @override
  String get ffvpnPremiumTag => 'premium';

  @override
  String get ffvpnQuotaSection => 'Cuota mensual de ancho de banda';

  @override
  String get ffvpnCheckQuota => 'Comprobar cuota';

  @override
  String get ffvpnQuotaLoading => 'Comprobando cuota…';

  @override
  String ffvpnQuotaUsedOf(String used, String total, String percent) {
    return '$used de $total usados ($percent%)';
  }

  @override
  String ffvpnQuotaLeft(String remaining) {
    return 'Quedan $remaining';
  }

  @override
  String ffvpnQuotaResets(String date) {
    return 'Se reinicia el $date';
  }

  @override
  String get ffvpnQuotaUnlimited =>
      'Ancho de banda ilimitado — esta cuenta no tiene cuota mensual.';

  @override
  String get ffvpnQuotaNoToken =>
      'Introduce arriba el token de sesión para comprobar la cuota.';

  @override
  String get ffvpnErrNotEntitled =>
      'Esta cuenta de Firefox no tiene suscripción a Mozilla VPN (HTTP 403) — el servicio de proxy la requiere.';

  @override
  String get ffvpnErrRegion =>
      'El servicio no está disponible en tu región (HTTP 451).';

  @override
  String get ffvpnErrBadToken =>
      'El token de sesión no es válido o ha expirado. Inicia sesión de nuevo en Firefox y copia un token fresco de signedInUser.json.';

  @override
  String get ffvpnErrQuota =>
      'La cuota mensual de ancho de banda está agotada — espera a la fecha de reinicio.';

  @override
  String get ffvpnErrBinaryMissing =>
      'No se encontró el binario ffvpn en la carpeta de datos de la aplicación.';

  @override
  String get ffvpnErrNetwork =>
      'Error de red al conectar con Mozilla — revisa tu conexión (puede hacer falta un túnel) e inténtalo de nuevo.';

  @override
  String get ffvpnErrBadCredentials =>
      'El correo o la contraseña son incorrectos (o el inicio de sesión está bloqueado) — revisa las credenciales de tu cuenta de Firefox.';

  @override
  String get ffvpnErrSignInUnsupported =>
      'El núcleo ffvpn instalado no admite inicio de sesión con correo/contraseña. Actualiza el núcleo en Actualizaciones de núcleos, o pega un token de sesión.';

  @override
  String get ffvpnErrBlocked =>
      'El borde de Mozilla bloqueó la solicitud de inicio de sesión desde esta red (HTTP 406). Inicia sesión a través de un túnel o de otra red y vuelve a intentarlo.';

  @override
  String get ffvpnErrOther => 'error de ffvpn';

  @override
  String get logSourceLantern => 'Lantern';

  @override
  String get lanternSettings => 'Ajustes de Lantern';

  @override
  String get lanternConnectionSection => 'Conexión';

  @override
  String get lanternEngine => 'Motor de conexión';

  @override
  String get lanternEngineRadiance => 'Radiance (v10 oficial, recomendado)';

  @override
  String get lanternEngineClassic => 'Clásico (flashlight)';

  @override
  String get lanternEngineDesc =>
      'Radiance ejecuta el mismo motor que el cliente oficial de Lantern v10 y sortea el bloqueo por sí solo. Clásico es el cliente headless anterior.';

  @override
  String get lanternPortSocks => 'Puerto SOCKS';

  @override
  String get lanternPortHttp => 'Puerto HTTP (0 = apagado)';

  @override
  String get lanternUpstreamSection => 'Proxy de upstream';

  @override
  String get lanternUpstreamDirect => 'Ninguno (directo)';

  @override
  String get lanternUpstreamManual => 'Proxy manual';

  @override
  String get lanternUpstreamPsiphon => 'Psiphon';

  @override
  String get lanternUpstreamTor => 'Tor';

  @override
  String get lanternUpstreamSstp => 'SSTP';

  @override
  String get lanternUpstreamWireguard => 'WireGuard';

  @override
  String get lanternUpstreamFfvpn => 'Firefox VPN';

  @override
  String get lanternUpstreamGeph => 'Geph';

  @override
  String get lanternUpstreamNpv => 'NPV';

  @override
  String get lanternUpstreamDesc =>
      'Las conexiones a los servidores de Lantern (y, si ninguno es alcanzable, también tu tráfico) pasan por este proxy — úsalo cuando las IP de los servidores de Lantern estén bloqueadas.';

  @override
  String get lanternUpstreamManualNote =>
      'Esquemas admitidos: socks5://, socks5h://, http:// y https://.';

  @override
  String lanternUpstreamVia(String name, String port) {
    return '$name es el salto de upstream (SOCKS en 127.0.0.1:$port) y se inicia automáticamente si aún no está en ejecución.';
  }

  @override
  String get lanternToolsSection => 'Herramientas de Lantern';

  @override
  String get lanternToolsServers => 'Servidores';

  @override
  String get lanternToolsCheckServers => 'Comprobar servidores';

  @override
  String get lanternServerReachable => 'Alcanzable';

  @override
  String get lanternServerUnreachable => 'No alcanzable';

  @override
  String get lanternServerNotChecked => 'Sin comprobar';

  @override
  String get lanternToolsAuth => 'Cuenta';

  @override
  String get lanternEmailLabel => 'Correo';

  @override
  String get lanternPasswordLabel => 'Contraseña';

  @override
  String get lanternLoginBtn => 'Iniciar sesión';

  @override
  String get lanternSignupBtn => 'Registrarse';

  @override
  String get lanternLogoutBtn => 'Cerrar sesión';

  @override
  String get lanternRunning => 'En ejecución';

  @override
  String get gephSettings => 'Ajustes de Geph';

  @override
  String get gephConnectionSection => 'Conexión';

  @override
  String get gephPortSocks => 'Puerto SOCKS';

  @override
  String get gephPortHttp => 'Puerto HTTP (0 = apagado)';

  @override
  String get gephCountry => 'País de salida';

  @override
  String get gephCountryAuto => 'Automático (cualquier país)';

  @override
  String get gephCountryRefresh => 'Actualizar lista';

  @override
  String get gephCountryFilter => 'Mostrar';

  @override
  String get gephCountryFilterAll => 'Todos los países';

  @override
  String get gephCountryFilterFree => 'Solo gratuitos';

  @override
  String get gephCountryFilterPlus => 'Solo premium';

  @override
  String get gephAccountSection => 'Cuenta de Geph';

  @override
  String get gephAccountReady => 'Hay un código de cuenta guardado.';

  @override
  String get gephAccountMissing =>
      'Aún no hay cuenta — pulsa \"Crear cuenta\", o introduce arriba un código de acceso o un archivo de cuenta.';

  @override
  String gephAccountPath(String path) {
    return 'Archivo de código de cuenta: $path';
  }

  @override
  String get gephSignupBtn => 'Crear cuenta';

  @override
  String get gephIHaveAccount => 'Ya tengo cuenta';

  @override
  String get gephRunning => 'En ejecución';

  @override
  String get logSourceGeph => 'Geph';

  @override
  String get gephUpstreamSection => 'Proxy de upstream';

  @override
  String get gephUpstreamDirect => 'Ninguno (directo)';

  @override
  String get gephUpstreamManual => 'Proxy manual';

  @override
  String get gephUpstreamPsiphon => 'Psiphon';

  @override
  String get gephUpstreamTor => 'Tor';

  @override
  String get gephUpstreamSstp => 'SSTP';

  @override
  String get gephUpstreamWireguard => 'WireGuard';

  @override
  String get gephUpstreamFfvpn => 'Firefox VPN';

  @override
  String get gephUpstreamLantern => 'Lantern';

  @override
  String get gephUpstreamNpv => 'NPV';

  @override
  String get gephUpstreamDesc =>
      'Geph llega a su broker y sale primero a través de este proxy — úsalo cuando tu conexión directa esté bloqueada. Crear o comprobar la cuenta también pasa por él.';

  @override
  String get gephUpstreamManualNote =>
      'Esquemas admitidos: socks5://, socks5h://, http:// y https://.';

  @override
  String gephUpstreamVia(String name, String port) {
    return '$name es el salto de upstream (SOCKS en 127.0.0.1:$port) y se inicia automáticamente si aún no está en ejecución.';
  }

  @override
  String get gephAccountSource => 'Origen del código de cuenta';

  @override
  String get gephAccountSourceFile => 'Archivo';

  @override
  String get gephAccountSourceCode => 'Código de acceso';

  @override
  String get gephAccountFilePath => 'Archivo de código de cuenta';

  @override
  String get gephAccountFileHint =>
      'Déjalo vacío para usar el archivo de cuenta en la carpeta de datos de la aplicación.';

  @override
  String get gephLoginCodeLabel => 'Código de acceso';

  @override
  String get gephLoginCodeHint =>
      'Tu código de acceso de Geph — se guarda en los ajustes de la aplicación.';

  @override
  String gephAccountSavedTo(String path) {
    return 'Código de acceso guardado en $path';
  }

  @override
  String get npvSettings => 'Ajustes de NPV Tunnel';

  @override
  String get npvEngineName => 'NPV';

  @override
  String get npvConfigSection => 'Archivo de configuración de NPV';

  @override
  String get npvConfigDesc =>
      'El archivo .npvs con el que se conecta NPV. Elige uno de tu ordenador.';

  @override
  String get npvPickConfigFile => 'Elegir archivo';

  @override
  String get npvChangeConfigFile => 'Cambiar archivo';

  @override
  String get npvClearConfigFile => 'Quitar';

  @override
  String get npvNoConfigFile => 'Aún no se ha elegido ningún archivo';

  @override
  String npvConfigLoaded(String name) {
    return 'Seleccionado: $name';
  }

  @override
  String get npvConfigReadError => 'No se pudo leer el archivo seleccionado';

  @override
  String get npvConfigLockedWhileRunning =>
      'Detén el túnel para cambiar este archivo.';

  @override
  String get npvConnectionSection => 'Proxy local y sondeo';

  @override
  String get npvPortSocks => 'Puerto SOCKS';

  @override
  String get npvPortHttp => 'Puerto HTTP (0 = apagado)';

  @override
  String get npvProbeSection => 'Sondeo de configuraciones';

  @override
  String get npvProbeDesc =>
      'Cada configuración se prueba una vez; se usa la más rápida de las que funcionan.';

  @override
  String get npvProbeTimeout => 'Tiempo de espera por solicitud (s)';

  @override
  String get npvProbeJobs => 'Sondeos en paralelo';

  @override
  String get npvProbeUrl => 'URL de sondeo (opcional)';

  @override
  String get autoReconnectNpv => 'Reconexión automática de NPV';

  @override
  String get npvServersSection => 'Servidores de este archivo';

  @override
  String get npvServersDesc =>
      'Todas las configuraciones del archivo. Comprobar las prueba una a una y muestra cuáles funcionan, de la más rápida primero.';

  @override
  String get npvServersListBtn => 'Mostrar servidores';

  @override
  String get npvServersCheckBtn => 'Comprobar servidores';

  @override
  String get npvServersCancelBtn => 'Cancelar';

  @override
  String get npvServersScanning => 'Sondeando configuraciones…';

  @override
  String npvServersSummary(Object answered, Object total) {
    return '$answered de $total configuraciones funcionan';
  }

  @override
  String npvServersCount(Object total) {
    return '$total configuraciones en este archivo';
  }

  @override
  String get npvServersCreator => 'Nota';

  @override
  String get npvServersNone => 'Este archivo no tiene configuraciones.';

  @override
  String get npvServersNoFile =>
      'Elige primero un archivo .npvs — todavía no hay nada que listar.';

  @override
  String get npvServersInUse => 'en uso';

  @override
  String get npvServersDead => 'No alcanzable';

  @override
  String get npvServersPinHint =>
      'Pulsa una configuración para usar esa; pulsa de nuevo para que la aplicación elija la más rápida.';

  @override
  String get npvServersPinnedChip => 'seleccionada';

  @override
  String get npvServersUnpinHint => 'Seleccionada — pulsa para deshacer';

  @override
  String get npvServersAutoBtn => 'Auto (la más rápida)';

  @override
  String npvServersPinnedTo(Object label) {
    return 'Seleccionada: $label';
  }

  @override
  String npvServersStalePin(Object index) {
    return 'La configuración seleccionada #$index no está en este archivo — elige otra o vuelve a Auto.';
  }

  @override
  String get npvServersPinIgnored =>
      'El núcleo de NPV usó una configuración distinta — actualiza el núcleo para elegir tú una.';

  @override
  String get aetherConnected => 'Aether conectado';

  @override
  String get aetherManualHint =>
      'Modo manual: protocolo, ofuscación, modo de escaneo y endpoint personalizado quedan bajo tu control más abajo. El modo de escaneo solo se aplica mientras el endpoint personalizado esté vacío.';

  @override
  String get aetherSettings => 'Ajustes de Aether';

  @override
  String get autoReconnectAether => 'Reconexión automática de Aether';

  @override
  String get both => 'Ambos';

  @override
  String get connectionMode => 'Modo de conexión';

  @override
  String get customEndpoint => 'Endpoint personalizado (opcional)';

  @override
  String get customEndpointHint => 'Déjalo vacío para escaneo automático';

  @override
  String get endpointPinning => 'Fijado de endpoint';

  @override
  String get endpointPinningAutomatic => 'Auto';

  @override
  String get endpointPinningAutomaticDesc =>
      'Escanea siempre automáticamente el mejor endpoint. Recomendado para la mayoría de los usuarios.';

  @override
  String get endpointPinningCustomFirst => 'Personalizado primero';

  @override
  String get endpointPinningCustomFirstDesc =>
      'Prueba primero tu endpoint personalizado. Si falla, recurre al escaneo automático.';

  @override
  String get endpointPinningCustomOnly => 'Solo personalizado';

  @override
  String get endpointPinningCustomOnlyDesc =>
      'Usa únicamente tu endpoint personalizado, sin recurso al escaneo automático. Sirve para probar un servidor concreto.';

  @override
  String get endpointPinningNeedsCustom =>
      'Define abajo un endpoint personalizado para activar los modos «Personalizado primero» y «Solo personalizado».';

  @override
  String get endpointPinningSubtitle =>
      'Controla cómo elige Aether su endpoint';

  @override
  String get ipType => 'Tipo de IP';

  @override
  String get ipv4 => 'IPv4';

  @override
  String get ipv6 => 'IPv6';

  @override
  String get localSocksPort => 'Puerto SOCKS local';

  @override
  String get logSourceAether => 'Aether';

  @override
  String get obfAggressive => 'Agresiva';

  @override
  String get obfBalanced => 'Equilibrada';

  @override
  String get obfDefaultCore => 'Predeterminada (núcleo)';

  @override
  String get obfFirewall => 'Firewall';

  @override
  String get obfGfw => 'GFW';

  @override
  String get obfLight => 'Ligera';

  @override
  String get obfuscation => 'Ofuscación (--noize)';

  @override
  String get profileAdaptive => 'Adaptativo';

  @override
  String get profileAdaptiveDesc =>
      'Equilibrio entre velocidad y cobertura — adecuado para la mayoría de las redes';

  @override
  String get profileManual => 'Manual';

  @override
  String get profileManualDesc =>
      'Todas las opciones manuales — para usuarios avanzados';

  @override
  String get profilePatchy => 'Señal irregular';

  @override
  String get profilePatchyDesc =>
      'Datos móviles inestables — búsqueda más dura y resistente';

  @override
  String get profileStrict => 'Red estricta';

  @override
  String get profileStrictDesc =>
      'Wi-Fi restringida o filtrado intenso — fragment + masque dentro de masque + noize gfw';

  @override
  String get protoGool => 'Gool (WARP dentro de WARP)';

  @override
  String get protoMasque => 'MASQUE (HTTP/3 o HTTP/2)';

  @override
  String get protoMim => 'MIM (masque dentro de masque)';

  @override
  String get protoWireguard => 'WireGuard';

  @override
  String get scanBalanced => 'Equilibrado';

  @override
  String get scanIronclad => 'Blindado';

  @override
  String get scanStealth => 'Sigiloso';

  @override
  String get scanThorough => 'Exhaustivo';

  @override
  String get scanTurbo => 'Turbo';

  @override
  String get scanVerified => 'Verificado';

  @override
  String get torViaAether => 'A través de Aether (Tor-over-Aether)';

  @override
  String get tryLastEndpointFirst =>
      'Probar primero el último endpoint correcto';

  @override
  String get tryLastEndpointFirstSubtitle =>
      'Si se activa, intentará el último endpoint que funcionó antes de escanear';

  @override
  String get aetherUpstream => 'Aether';
}
