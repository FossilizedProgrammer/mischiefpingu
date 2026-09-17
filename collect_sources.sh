#!/bin/bash
OUTPUT="flutter_all_source.txt"
> "$OUTPUT"

echo "در حال جمع‌آوری فایل‌ها..."

if [ -f "pubspec.yaml" ]; then
    printf '******************************************************\n' >> "$OUTPUT"
    printf 'pubspec.yaml\n' >> "$OUTPUT"
    printf '******************************************************\n\n' >> "$OUTPUT"
    cat "pubspec.yaml" >> "$OUTPUT"
    printf '\n\n' >> "$OUTPUT"
fi

find lib -type f -name "*.dart" | sort | while read -r file; do
    printf '******************************************************\n' >> "$OUTPUT"
    printf '%s\n' "$file" >> "$OUTPUT"
    printf '******************************************************\n\n' >> "$OUTPUT"
    cat "$file" >> "$OUTPUT"
    printf '\n\n' >> "$OUTPUT"
done

echo "=========================================="
echo "تمام شد!"
echo "فایل خروجی: $OUTPUT"
echo "تعداد فایل‌های دارت: $(find lib -type f -name "*.dart" | wc -l)"
echo "=========================================="
