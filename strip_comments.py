import re
from pathlib import Path

# ═══════════════════════════════════════════════════════════════
#  الگوهایی که باید حتماً حفظ بشن (وگرنه analyzer خطا میده)
# ═══════════════════════════════════════════════════════════════
KEEP_PATTERNS = [
    re.compile(r'^\s*//\s*ignore:'),
    re.compile(r'^\s*//\s*ignore_for_file:'),
    re.compile(r'^\s*//\s*coverage:'),
    re.compile(r'^\s*//ignore:'),
    re.compile(r'^\s*//ignore_for_file:'),
    re.compile(r'^\s*//\s*coverage:ignore'),
    re.compile(r'^\s*///'),          # doc comments (برای lintهای doc)
]


def is_keepable(line: str) -> bool:
    """آیا این خط کامنت باید حفظ بشه؟"""
    return any(p.match(line) for p in KEEP_PATTERNS)


def strip_line_comment(line: str) -> str:
    """
    حذف کامنت انتهای خط (inline) با احتیاط:
    فقط اگه // داخل رشته (single/double/raw) نباشه.
    """
    if '//' not in line:
        return line

    in_string = False
    quote = None
    i = 0
    while i < len(line):
        ch = line[i]

        # تشخیص شروع/پایان رشته
        if ch in ('"', "'"):
            # اگه کاراکتر قبلش backslash باشه، escape شده
            if i == 0 or line[i - 1] != '\\':
                if not in_string:
                    in_string = True
                    quote = ch
                elif quote == ch:
                    in_string = False
                    quote = None

        # اگه // خارج از رشته بود، کامنت رو ببر
        elif not in_string and line[i:i + 2] == '//':
            return line[:i].rstrip()

        i += 1

    return line


def strip_dart_comments(source: str) -> str:
    """
    حذف همه کامنتها به جز:
      • ignore / ignore_for_file / coverage
      • doc comments (///)  ← برای جلوگیری از lint error

    ⚠️ کامنت هدر ابتدای فایل هم حذف میشه.
    """
    lines = source.split('\n')

    # ─── 1. حذف کامنتهای بلوکی /* ... */ ───
    text = '\n'.join(lines)
    # برای امنیت، فقط بلوکهای ساده رو حذف میکنیم (نه تودرتو)
    # تودرتویی /* /* */ */ در Dart نادر است ولی اگه داشتی بگو
    text = re.sub(r'/\*(?!\*).*?\*/', '', text, flags=re.DOTALL)
    # ↑ (?!\*) باعث میشه /** ... */ که doc-style هست حفظ بشه اگه بخوای
    #   ولی اینجا doc-styleها هم میخوان حذف بشن، پس سادهتر:
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)
    lines = text.split('\n')

    # ─── 2. پردازش خط به خط ───
    result = []
    for line in lines:
        stripped = line.strip()

        # خط کاملاً خالیه → نگه دار (برای فاصلهگذاری)
        if stripped == '':
            result.append(line)
            continue

        # خط کامنت کامل
        if stripped.startswith('//'):
            if is_keepable(line):
                result.append(line)
            # در غیر این صورت حذف (append نکن)
            continue

        # خط کد (ممکنه کامنت انتهایی داشته باشه)
        cleaned = strip_line_comment(line)
        if cleaned.strip() == '' and line.strip() != '':
            # اگه خط فقط شامل کامنت بود و کد نداشت، حذف
            continue
        result.append(cleaned)

    # ─── 3. جمع کردن و تمیزکاری نهایی ───
    out = '\n'.join(result)

    # حذف خطوط خالی اضافی (بیشتر از 2 تا پشت سر هم)
    out = re.sub(r'\n{3,}', '\n\n', out)

    # حذف خطوط خالی ابتدای فایل
    out = out.lstrip('\n')

    # اطمینان از newline انتهای فایل
    return out.rstrip() + '\n'


def process_file(path: Path) -> bool:
    src = path.read_text(encoding='utf-8')
    new = strip_dart_comments(src)
    if new != src:
        path.write_text(new, encoding='utf-8')
        return True
    return False


def main():
    lib_dir = Path('lib')
    if not lib_dir.exists():
        print('✗ پوشه lib پیدا نشد. از ریشه پروژه اجرا کن.')
        return

    changed = 0
    total = 0
    for f in sorted(lib_dir.rglob('*.dart')):
        total += 1
        try:
            if process_file(f):
                print(f'✓ {f}')
                changed += 1
        except Exception as e:
            print(f'✗ {f} → {e}')

    print(f'\nDone. {changed}/{total} file(s) modified.')


if __name__ == '__main__':
    main()
