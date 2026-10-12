// test/screens/ffvpn_upstream_section_test.dart
//
// تست بخش آپ‌استریم SOCKS در تنظیمات Firefox VPN.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/screens/widgets/ffvpn/ffvpn_upstream_section.dart';
import 'package:mischiefpingu/widgets/settings_tile_base.dart';

class _Host extends StatelessWidget {
  final AppSettings s;

  const _Host(this.s);

  @override
  Widget build(BuildContext context) {
    return FfvpnUpstreamSection(
      s: s,
      theme: Theme.of(context),
      l10n: AppLocalizations.of(context),
      onSave: () {},
    );
  }
}

Future<void> pumpSection(WidgetTester tester, AppSettings s) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(child: _Host(s)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('direct shows no proxy fields and no info card', (tester) async {
    await pumpSection(tester, AppSettings());

    expect(find.text('Direct (no upstream)'), findsOneWidget);
    expect(find.text('Proxy IP'), findsNothing);
    expect(find.byType(SettingsInfoCard), findsNothing);
  });

  testWidgets('manual reveals the SOCKS5 fields', (tester) async {
    final s = AppSettings()..ffvpnUpstreamType = 1;
    await pumpSection(tester, s);

    expect(find.text('Manual SOCKS5 proxy'), findsOneWidget);
    expect(find.text('Proxy type'), findsOneWidget);
    expect(find.text('Proxy IP'), findsOneWidget);
    expect(find.byType(SettingsInfoCard), findsNothing);
  });

  testWidgets('built-in upstream shows its SOCKS port', (tester) async {
    for (final entry in <int, String>{
      3: 'Psiphon',
      4: 'Tor',
      5: 'SSTP',
      6: 'WireGuard',
    }.entries) {
      final s = AppSettings()..ffvpnUpstreamType = entry.key;
      await pumpSection(tester, s);

      final card = tester.widget<SettingsInfoCard>(
        find.byType(SettingsInfoCard),
      );
      expect(card.message, contains(entry.value));
      expect(card.message, contains('127.0.0.1:'));
      expect(find.text('Proxy IP'), findsNothing);
    }
  });

  testWidgets('selecting Tor from the dropdown updates the setting',
      (tester) async {
    final s = AppSettings();
    await pumpSection(tester, s);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tor (SOCKS)').last);
    await tester.pumpAndSettle();

    expect(s.ffvpnUpstreamType, 4);
  });
}
