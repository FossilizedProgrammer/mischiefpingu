library;

import 'dart:io';

import 'core_update/version_parsers.dart';
import 'core_update/file_finder.dart';

class CoreUpdateUtils {
  CoreUpdateUtils._();

  static bool isMissingVersion(String v) => VersionParsers.isMissing(v);
  static String? parseAetherVersion(String? output) =>
      VersionParsers.parseAether(output);
  static String? parsePsiphonVersion(String? output) =>
      VersionParsers.parsePsiphon(output);
  static String? parseTorVersion(String? output) =>
      VersionParsers.parseTor(output);
  static String? parseSemver(String? output) =>
      VersionParsers.parseSemver(output);
  static bool isNewerVersion(String installed, String latest) =>
      VersionParsers.isNewer(installed, latest);
  static String formatBytes(int bytes) => VersionParsers.formatBytes(bytes);

  static Future<int> fileSize(String path) => FileFinder.fileSize(path);
  static Future<bool> isRealFile(String path) => FileFinder.isRealFile(path);
  static Future<String?> findFile(Directory root, String name) =>
      FileFinder.byName(root, name);
  static Future<String?> findFileByPrefix(Directory root, String prefix) =>
      FileFinder.byPrefix(root, prefix);
  static Future<String?> findFileContaining(Directory root, String pattern) =>
      FileFinder.byContaining(root, pattern);
}
