// test/screens/scrollbar_clearance_test.dart
//
// اسکرول‌بار عمودی همیشه‌نمایان به‌صورت overlay نقاشی می‌شود: هیچ جایی
// در layout رزرو نمی‌کند. اگر لیست اصلی padding انتهایی نداشته باشد،
// ریل روی حاشیهٔ ۱۲پیکسلی کارت‌ها می‌افتد. این تست همان هندسه را با
// ضخامت واقعی تم می‌سنجد تا هر تغییرِ ضخامت/حاشیهٔ بعدی لو برود.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mischiefpingu/screens/widgets/main_screen_body.dart';
import 'package:mischiefpingu/theme/theme_builder.dart';
import 'package:mischiefpingu/widgets/settings_tile_base.dart';

/// `Card` حاشیهٔ خودش را داخل render objectش نگه می‌دارد، پس مستطیلش
/// لبهٔ بیرونی است؛ لبهٔ دیده‌شدهٔ کارت همان مقدار منهای این عدد است.
const double _cardMargin = 12;

/// پهنای ناحیهٔ راست (یا چپ در RTL) که ریل اسکرول‌بار اشغال می‌کند.
double railFootprint(ThemeData theme) {
  double thickest = 0;
  for (final states in <Set<WidgetState>>[
    {},
    {WidgetState.hovered},
    {WidgetState.dragged},
  ]) {
    final t = theme.scrollbarTheme.thickness?.resolve(states);
    if (t != null) thickest = math.max(thickest, t);
  }
  return thickest + (theme.scrollbarTheme.crossAxisMargin ?? 0);
}

Future<ThemeData> pumpCards(WidgetTester tester, TextDirection dir) async {
  late ThemeData theme;
  await tester.binding.setSurfaceSize(const Size(1400, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme('indigo', Brightness.light),
      home: Directionality(
        textDirection: dir,
        child: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return Scaffold(
              body: ListView(
                padding: const EdgeInsetsDirectional.only(
                  end: kMainListEndPadding,
                  bottom: 24,
                ),
                children: [
                  for (var i = 0; i < 4; i++)
                    SettingsTile(
                      title: 'Tile $i',
                      children: [const SizedBox(height: 60)],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return theme;
}

void main() {
  testWidgets('always-visible scrollbar does not cover the settings cards',
      (tester) async {
    final theme = await pumpCards(tester, TextDirection.ltr);
    final width = tester.getSize(find.byType(Scaffold)).width;
    final cardRight =
        tester.getRect(find.byType(Card).first).right - _cardMargin;
    final railLeft = width - railFootprint(theme);

    expect(railFootprint(theme), greaterThan(0));
    expect(
      cardRight,
      lessThanOrEqualTo(railLeft),
      reason: 'card reaches ${railLeft - cardRight}px into the scrollbar rail',
    );
    // بدون فضای تنفس، هر ضخیم‌تر شدنِ آتی دوباره همپوشانی می‌آورد.
    expect(railLeft - cardRight, greaterThanOrEqualTo(4));
  });

  testWidgets('clearance follows the rail in RTL too', (tester) async {
    final theme = await pumpCards(tester, TextDirection.rtl);
    final cardLeft = tester.getRect(find.byType(Card).first).left + _cardMargin;
    final railRight = railFootprint(theme);
    expect(cardLeft - railRight, greaterThanOrEqualTo(4));
  });
}
