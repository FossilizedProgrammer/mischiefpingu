import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/models/settings_model.dart';
import 'package:mischiefpingu/screens/widgets/sstp/sstp_ports_section.dart';

Future<void> pumpSection(
    WidgetTester tester, AppSettings s, void Function() onSave) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Builder(builder: (context) {
            return SstpPortsSection(
              settings: s,
              theme: Theme.of(context),
              onSave: onSave,
            );
          }),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('editing HTTP port mutates settings and calls onSave',
      (tester) async {
    final s = AppSettings();
    var saves = 0;
    await pumpSection(tester, s, () => saves++);
    expect(s.sstpHttpPort, 8082);

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(1), '9999');
    await tester.pump();
    expect(s.sstpHttpPort, 9999);
    expect(saves, greaterThan(0));
  });

  testWidgets('editing SOCKS port mutates settings and calls onSave',
      (tester) async {
    final s = AppSettings();
    var saves = 0;
    await pumpSection(tester, s, () => saves++);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '1111');
    await tester.pump();
    expect(s.sstpSocksPort, 1111);
    expect(saves, greaterThan(0));
  });

  testWidgets('invalid range keeps old value and shows error',
      (tester) async {
    final s = AppSettings();
    var saves = 0;
    await pumpSection(tester, s, () => saves++);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), '99999999');
    await tester.pump();
    expect(s.sstpHttpPort, 8082); // ذخیره نشده
    expect(
      find.text('Enter a port number from 1 to 65535'),
      findsOneWidget,
    );
    expect(saves, 0);
  });
}
