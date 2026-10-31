// test/screens/tunnel_health_rows_test.dart
//
// فهرست «Tunnel Health» باید هر هسته‌ای که برنامه بالا می‌آورد را نشان
// دهد، نه فقط چهار تای اول.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/providers/app_provider.dart';
import 'package:mischiefpingu/services/health/tunnel_health_models.dart';
import 'package:mischiefpingu/widgets/diagnostics/connection_health/tunnel_state_resolver.dart';
import 'package:mischiefpingu/widgets/diagnostics/connection_health_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppProvider> pumpHealth(WidgetTester tester) async {
    final provider = AppProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: provider),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ConnectionHealthSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final header = find.text('Tunnel Health');
    await tester.ensureVisible(header);
    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return provider;
  }

  testWidgets('every tunnel kind gets a row', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await pumpHealth(tester);

    for (final name in [
      'Aether',
      'Psiphon',
      'Tor',
      'SSTP',
      'WireGuard',
      'Firefox VPN',
      'Lantern',
      'Geph',
      'NPV',
    ]) {
      expect(find.text(name), findsOneWidget, reason: '$name row missing');
    }
    expect(find.text('0 / 9'), findsOneWidget);

    // resolver باید برای هر kind هم port خودش و هم یک کلید داشته باشد.
    final resolver = TunnelStateResolver(provider);
    expect(
      resolver.resolveRunningStates().keys.toSet(),
      TunnelKind.values.toSet(),
    );
    final ports = TunnelKind.values.map(resolver.socksPortFor).toList();
    expect(ports.toSet().length, TunnelKind.values.length, reason: '$ports');
    expect(
      resolver.socksPortFor(TunnelKind.npv),
      provider.settings.npvSocksPort,
    );
    provider.dispose();
  });
}
