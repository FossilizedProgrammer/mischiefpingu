// lib/models/lantern_engine.dart
//
// موتور اتصال لنترن:
//   • radiance — موتور رسمی نسخهٔ ۱۰ (باینری `lantern-radiance`) که خودش
//     تونل را بدون پروکسی واسط بالا می‌آورد. پیش‌فرض.
//   • classic  — باینری `lantern` (flashlight) با زیرفرمان `start`.

class LanternEngine {
  LanternEngine._();

  /// باینری کلاسیک `lantern` (flashlight) — `lantern start`.
  static const int classic = 0;

  /// موتور رسمی نسخهٔ ۱۰ — باینری `lantern-radiance`.
  static const int radiance = 1;

  /// موتور پیش‌فرض.
  static const int defaultValue = radiance;

  static bool isValid(int value) => value == classic || value == radiance;

  /// نام باینری متناظر با موتور.
  static String binaryName(int engine) =>
      engine == radiance ? 'lantern-radiance' : 'lantern';
}
