import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/l10n/app_localizations.dart';
import 'package:mischiefpingu/widgets/editable_list/editable_list_dialogs.dart';

void main() {
  // کانال کلیپ‌بورد در محیط تست به‌صورت پیش‌فرض پاسخ نمی‌دهد و
  /// Future آن هرگز کامل نمی‌شود، پس یک mock ساده ثبت می‌کنیم.
  String clipboard = '';

  setUp(() {
    clipboard = '';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String? ?? '';
          } else if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': clipboard};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  // ─── توابع خالص: encode / decode ───

  test('decode keeps order, drops blanks, comments and duplicates', () {
    final result = EditableListClipboard.decode(
      '  1.1.1.1  \n\n# comment\n2.2.2.2\n1.1.1.1\n// note\n3.3.3.3\n',
    );
    expect(result, ['1.1.1.1', '2.2.2.2', '3.3.3.3']);
  });

  test('decode also splits on commas and semicolons', () {
    final result = EditableListClipboard.decode(
      'a.example.com, b.example.com;c.example.com',
    );
    expect(result, ['a.example.com', 'b.example.com', 'c.example.com']);
  });

  test('encode puts one item per line', () {
    expect(EditableListClipboard.encode(['a', 'b']), 'a\nb');
    expect(EditableListClipboard.encode([]), '');
  });

  // ─── رفتار واقعی کلیپ‌بورد در UI ───

  testWidgets('copy all puts the whole list in the clipboard', (tester) async {
    await pumpHost(tester);

    await tester.tap(find.byIcon(Icons.copy_all));
    await tester.pump();

    // mock ثبت‌شده مقدار setData را نگه داشته است
    expect(clipboard, '1.1.1.1\n2.2.2.2\nexample.com');
  });

  testWidgets('import appends only items that are not already present', (
    tester,
  ) async {
    clipboard = '2.2.2.2\n3.3.3.3\n4.4.4.4';
    final host = await pumpHost(tester, initial: ['1.1.1.1', '2.2.2.2']);

    await tester.tap(find.byIcon(Icons.content_paste_go));
    await tester.pump();
    await tester.pump();

    expect(host.items, ['1.1.1.1', '2.2.2.2', '3.3.3.3', '4.4.4.4']);
  });

  testWidgets('clear all asks for confirmation before emptying', (
    tester,
  ) async {
    final host = await pumpHost(tester, initial: ['1.1.1.1', '2.2.2.2']);

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();

    // دیالوگ تأیید باز شده و لیست هنوز دست‌نخورده است
    expect(find.text('Clear all?'), findsOneWidget);
    expect(host.items, ['1.1.1.1', '2.2.2.2']);

    await tester.tap(find.widgetWithText(FilledButton, 'Clear all'));
    await tester.pumpAndSettle();

    expect(host.items, isEmpty);
  });

  testWidgets('clear all can be cancelled', (tester) async {
    final host = await pumpHost(tester, initial: ['1.1.1.1']);

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(host.items, ['1.1.1.1']);
  });
}

/// هاست تست که همان سه اکشن را با EditableListClipboard اجرا می‌کند.
class ListHost {
  List<String> items;
  ListHost(this.items);
}

Future<ListHost> pumpHost(
  WidgetTester tester, {
  List<String> initial = const ['1.1.1.1', '2.2.2.2', 'example.com'],
}) async {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final host = ListHost(List<String>.from(initial));
  late StateSetter setOuter;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return Column(
              children: [
                for (final item in host.items) Text(item),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_all),
                      onPressed: host.items.isEmpty
                          ? null
                          : () => EditableListClipboard.copyAll(
                              context,
                              host.items,
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_paste_go),
                      onPressed: () async {
                        final fresh = await EditableListClipboard.readNew(
                          context,
                          host.items,
                        );
                        if (fresh == null || fresh.isEmpty) return;
                        host.items = [...host.items, ...fresh];
                        setOuter(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      onPressed: host.items.isEmpty
                          ? null
                          : () async {
                              final ok =
                                  await EditableListClipboard.confirmClearAll(
                                    context,
                                    host.items,
                                  );
                              if (!ok) return;
                              host.items = [];
                              setOuter(() {});
                            },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return host;
}