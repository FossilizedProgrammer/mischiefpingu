// lib/services/tor/tor_types.dart
//
// ═══════════════════════════════════════════════════════════════
//  Type definitions مشترک بین TorBundleDiscovery و TorBundleInstaller
//  (جلوگیری از تکرار typedef در دو فایل)
// ═══════════════════════════════════════════════════════════════
library;

typedef TorLogFn = void Function(String message);

typedef TorGetTextFn = Future<String> Function(
  String url,
  String? proxy, {
  String accept,
  String userAgent,
});

typedef TorHeadFn = Future<({int status, int length})?> Function(
  String url,
  String? proxy, {
  int timeoutSec,
});

typedef TorArchFn = Future<String> Function();
