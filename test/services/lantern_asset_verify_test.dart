library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mischiefpingu/services/core_update/core_update_process_utils.dart';
import 'package:mischiefpingu/services/core_update/shared/archive_extractor.dart';
import 'package:mischiefpingu/services/core_update/shared/asset_picker.dart';

void main() {
  // Asset list copied verbatim from the real latest release (v1.2.7) of
  // FossilizedProgrammer/lantern-headless-iran.
  final assets = [
    {
      'name': 'lantern-headless-linux-amd64',
      'size': 42316512,
      'browser_download_url':
          'https://github.com/FossilizedProgrammer/lantern-headless-iran/'
              'releases/download/v1.2.7/lantern-headless-linux-amd64',
    },
    {
      'name': 'lantern-headless-windows-amd64.exe',
      'size': 43372544,
      'browser_download_url':
          'https://github.com/FossilizedProgrammer/lantern-headless-iran/'
              'releases/download/v1.2.7/lantern-headless-windows-amd64.exe',
    },
  ];

  test('AssetPicker selects the linux raw binary on this (linux) host', () {
    final picked = AssetPicker.pick(assets, 'x86_64');
    expect(picked?['name'], 'lantern-headless-linux-amd64');
  });

  test('AssetPicker selects the linux binary for arm64 too (fallback)', () {
    final picked = AssetPicker.pick(assets, 'aarch64');
    expect(picked?['name'], 'lantern-headless-linux-amd64');
  });

  test('classifyArchive marks lantern release URLs as raw binaries', () {
    final extractor = ArchiveExtractor(processUtils: _noopUtils());
    const linuxUrl =
        'https://github.com/FossilizedProgrammer/lantern-headless-iran/'
        'releases/download/v1.2.7/lantern-headless-linux-amd64';
    const winUrl =
        'https://github.com/FossilizedProgrammer/lantern-headless-iran/'
        'releases/download/v1.2.7/lantern-headless-windows-amd64.exe';

    final linux = extractor.classifyArchive(linuxUrl, 'lantern');
    expect(linux.isRawBinary, isTrue);
    expect(linux.isArchive, isFalse);

    final win = extractor.classifyArchive(winUrl, 'lantern');
    expect(win.isRawBinary, isTrue);
  });
}

CoreUpdateProcessUtilsStub _noopUtils() => CoreUpdateProcessUtilsStub();

class CoreUpdateProcessUtilsStub implements CoreUpdateProcessUtils {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
