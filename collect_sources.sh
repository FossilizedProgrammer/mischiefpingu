#!/bin/bash

OUTPUT="flutter_all_source.txt"
> "$OUTPUT"

echo "در حال جمع‌آوری فایل‌ها..."

# افزودن pubspec.yaml
if [ -f "pubspec.yaml" ]; then
    printf '******************************************************\n' >> "$OUTPUT"
    printf 'pubspec.yaml\n' >> "$OUTPUT"
    printf '******************************************************\n\n' >> "$OUTPUT"
    cat "pubspec.yaml" >> "$OUTPUT"
    printf '\n\n' >> "$OUTPUT"
fi

# جمع‌آوری فایل‌های Dart، YAML و ARB
find lib -type f \( \
    -name "*.dart" -o \
    -name "*.yaml" -o \
    -name "*.arb" \
\) | sort | while read -r file; do

    printf '******************************************************\n' >> "$OUTPUT"
    printf '%s\n' "$file" >> "$OUTPUT"
    printf '******************************************************\n\n' >> "$OUTPUT"

    cat "$file" >> "$OUTPUT"
    printf '\n\n' >> "$OUTPUT"
done

DART_COUNT=$(find lib -type f -name "*.dart" | wc -l)
YAML_COUNT=$(find lib -type f -name "*.yaml" | wc -l)
ARB_COUNT=$(find lib -type f -name "*.arb" | wc -l)
TOTAL_COUNT=$((DART_COUNT + YAML_COUNT + ARB_COUNT))

echo "=========================================="
echo "تمام شد!"
echo "فایل خروجی: $OUTPUT"
echo "تعداد فایل‌های Dart: $DART_COUNT"
echo "تعداد فایل‌های YAML: $YAML_COUNT"
echo "تعداد فایل‌های ARB: $ARB_COUNT"
echo "تعداد کل فایل‌ها: $TOTAL_COUNT"
echo "=========================================="

