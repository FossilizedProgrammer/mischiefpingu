// تست PortTextField: ممانعت از کاراکتر غیررقم + اطلاع‌رسانی بازه نامعتبر
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/widgets/settings/port_text_field.dart';

Widget host({
  required ValueChanged<String> onChanged,
  int min = 1,
  int max = 65535,
  String initialValue = '8082',
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: PortTextField(
        labelText: 'Port',
        initialValue: initialValue,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    ),
  );
}

const err1 = 'Enter a port number from 1 to 65535';

void main() {
  testWidgets('out-of-range port shows localized error', (tester) async {
    String? got;
    await tester.pumpWidget(host(onChanged: (v) => got = v));

    await tester.enterText(find.byType(TextFormField), '70000');
    await tester.pump();
    expect(find.text(err1), findsOneWidget);
    expect(got, '70000'); // onChanged متن خام رو می‌ده؛ گاردِ تایل جلوی ذخیره رو می‌گیره

    await tester.enterText(find.byType(TextFormField), '9090');
    await tester.pump();
    expect(find.text(err1), findsNothing);
  });

  testWidgets('empty value shows error too', (tester) async {
    await tester.pumpWidget(host(onChanged: (_) {}));
    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    // کاراکترهای غیررقم حذف می‌شوند → خالی → خطا
    expect(find.widgetWithText(TextFormField, ''), findsOneWidget);
    expect(find.text(err1), findsOneWidget);
  });

  testWidgets('non-digit chars are stripped, digits kept', (tester) async {
    String? got;
    await tester.pumpWidget(host(onChanged: (v) => got = v));

    await tester.enterText(find.byType(TextFormField), 'ab12x9');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '129'), findsOneWidget);
    expect(got, '129');
    expect(find.text(err1), findsNothing);
  });

  testWidgets('persian digits convert to ascii', (tester) async {
    String? got;
    await tester.pumpWidget(host(onChanged: (v) => got = v));

    await tester.enterText(find.byType(TextFormField), '۸۰۸۵');
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '8085'), findsOneWidget);
    expect(got, '8085');
    expect(find.text(err1), findsNothing);
  });

  testWidgets('min:0 allows zero (ffvpn http disable)', (tester) async {
    String? got;
    await tester.pumpWidget(host(onChanged: (v) => got = v, min: 0));

    await tester.enterText(find.byType(TextFormField), '0');
    await tester.pump();
    expect(find.text('Enter a port number from 0 to 65535'), findsNothing);
    expect(got, '0');
  });
}
