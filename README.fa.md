<div dir="rtl">

# 🐧 پینگوی شیطون (MischiefPingu)

<div align="center">

**کلاینت چند-هسته‌ای — سایفون • تور • اس‌اس‌تی‌پی • وایرگارد • وی‌پی‌ان فایرفاکس**

یک رابط گرافیکی Flutter برای دسکتاپ (لینوکس و ویندوز) که چند هستهٔ عبور از سانسور را در یک رابط تمیز و یکپارچه جمع می‌کند.

[![GitHub](https://img.shields.io/badge/GitHub-FossilizedProgrammer/mischiefpingu-blue?logo=github)](https://github.com/FossilizedProgrammer/mischiefpingu)
[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x)](https://x.com/tenblockperhour)
[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

</div>

---

## ⚠️ اطلاعیهٔ حقوقی دربارهٔ سایفون

> این یک کلاینت **غیررسمی** سایفون است و هیچ‌گونه وابستگی یا تأییدی از سوی شرکت Psiphon Inc. ندارد.  
> نام «سایفون / Psiphon» و هستهٔ رسمی سایفون، متعلق به شرکت Psiphon Inc. است.

---

## ⚠️ اطلاعیهٔ حقوقی دربارهٔ وی‌پی‌ان فایرفاکس

> این یک کلاینت **غیررسمی** وی‌پی‌ان فایرفاکس است و هیچ‌گونه وابستگی یا تأییدی از سوی فایرفاکس (موزیلا) ندارد.  
> نام‌های «Firefox» و «Mozilla» متعلق به بنیاد Mozilla هستند. این پروژه توسط موزیلا حمایت، پشتیبانی یا تأیید نمی‌شود و یک محصول رسمی موزیلا نیست.

---

## ✨ امکانات

###  هسته‌های قابل اتصال

| هسته | توضیحات |
|------|---------|
| **سایفون** | باینری رسمی `psiphon-tunnel-core` به‌همراه فورک شیر و خورشید (SunAndLion) برای فرانتینگ CDN |
| **تور** | یکپارچه‌سازی expert-bundle با پلاگین‌های obfs4، meek، snowflake، webtunnel و conjure |
| **اس‌اس‌تی‌پی** | کلاینت پروکسی SSTP، توسعه‌داده‌شده توسط سازندهٔ همین برنامه |
| **وایرگارد** | کلاینت userspace مبتنی بر wireproxy با دو هسته: **Standard** (wireguard-go) و **AmneziaWG** (نسخهٔ مبهم‌سازی‌شده برای سانسور سنگین) |
| **وی‌پی‌ان فایرفاکس** | کلاینت داخلی **IP Protection** فایرفاکس (`ffvpn`، مبتنی بر Mozilla VPN) — با حساب Firefox Account وارد می‌شود و یک پروکسی محلی SOCKS5/HTTP در اختیار می‌گذارد |

**ویژگی‌های عمومی:**  
پشتیبانی از پیست کردن کانفیگ یا URI، پورت SOCKS محلی، Share-on-LAN و اتصال مجدد خودکار.

---

### 🧠 حالت‌های هوشمند اتصال (سایفون)

| حالت | توضیحات |
|------|---------|
| **فرانتینگ (CDN)** | فورک شیر و خورشید با تنظیم `FRONTED-MEEK-CDN-OSSH`. بهترین گزینه برای سانسور سنگین |
| **Conduit (WebRTC Inproxy)** | رله‌های غیرمتمرکز همتا |
| **مستقیم** | هستهٔ رسمی سایفون بدون فرانتینگ |

---

### 🔗 تونل‌های زنجیره‌ای

- تور از طریق سایفون / اس‌اس‌تی‌پی
- اس‌اس‌تی‌پی از طریق سایفون / تور
- سایفون از طریق تور / اس‌اس‌تی‌پی / پروکسی دستی

---


### 🛰️ اسکنر آی‌پی CDN

- **پیش‌تنظیم‌های آماده:** Akamai، Cloudflare، Fastly، Google CDN، Amazon CloudFront، Microsoft Azure
- **گسترش CIDR / بازه / آی‌پی تکی** (تا ۲۰٬۰۰۰ ورودی)
- **بررسی موازی TLS handshake** با امتیازدهی تأخیر و پایداری
- **اعمال Top 5 / Top 20** روی تنظیمات فرانتینگ

---

###  دریافت‌کنندهٔ سرورهای VPN Gate

- استخراج از `vpngate.net` (مستقیم یا از طریق هر پروکسی فعال)
- بازخوانی خودکار هر ۱ دقیقه
- بررسی سلامت موازی با TCP + TLS ClientHello
- کپی نتایج به‌صورت لیست ساده یا CSV با جزئیات

---

### 🛠️ آپدیت هسته‌ها

آپدیت‌کنندهٔ داخلی برای همهٔ باینری‌ها (تور، سایفون، شیر و خورشید، SSTP، wireproxy، وی‌پی‌ان فایرفاکس). آپدیت‌ها ذخیره و در استارت بعدی اعمال می‌شوند.

---

###  چندزبانه

ترجمه کامل رابط کاربری به **انگلیسی**، **فارسی** و **روسی** با تغییر آنی.

---

### 🎨 امکانات دیگر

- ۶ تم رنگی با حالت روشن/تیرهٔ خودکار
- ذخیرهٔ تنظیمات با SharedPreferences
- پشتیبانی از اشتراک در شبکهٔ محلی برای همهٔ هسته‌ها (از جمله وایرگارد)
- اتصال مجدد خودکار برای هر هسته
- کنسول لاگ زنده با قابلیت کپی / پاک‌سازی
- Watchdog تونل با بازیابی خودکار
- پنگوئنی که به رویدادهای اتصال واکنش نشان می‌دهد! 🐧

---

## 🚀 نصب و اجرا

### 🐧 لینوکس — پیش‌نیازها

قبل از اجرا یا بیلد روی لینوکس، پکیج‌های توسعهٔ GStreamer را نصب کنید:

**sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev**

### 📦 بیلد

ابتدا دستور زیر را اجرا کنید:

**flutter pub get**

سپس برای لینوکس:

**flutter build linux --release --no-tree-shake-icons**

یا برای ویندوز:

**flutter build windows --release --no-tree-shake-icons**

---

## 🙏 قدردانی

این پروژه بدون تلاش دیگران وجود نداشت. سپاس صمیمانه از:

| پروژه | توضیحات |
|-------|---------|
| [**فورک شیر و خورشید**](https://github.com/shirokhorshid/psiphon-tunnel-core) | حالت فرانتینگ / CDN در این برنامه به‌طور کامل بر این فورک استوار است. توسعهٔ این هسته بر عهدهٔ سازندهٔ شیر و خورشید است |
| [**سایفون رسمی**](https://github.com/Psiphon-Labs/psiphon-tunnel-core-binaries) | هستهٔ رسمی سایفون برای حالت‌های مستقیم، Conduit، آپ‌استریم تور و آپ‌استریم SSTP استفاده می‌شود |
| [**پروژهٔ تور**](https://www.torproject.org/) | برای باندل تخصصی تور و پلاگین‌های ترنسپورت |
| [**wireproxy**](https://github.com/nwtgck/wireproxy) | کلاینت userspace وایرگارد که به‌صورت SOCKS5/HTTP پروکسی در اختیار می‌گذارد |
| [**AmneziaWG**](https://github.com/amnezia-vpn/amneziawg-go) | فورک مبهم‌سازی‌شدهٔ WireGuard برای مقاومت در برابر DPI |
| [**فلاتر (Flutter)**](https://flutter.dev/) | تمام این رابط گرافیکی روی فلاتر ساخته شده است |
| [**sstp-proxy**](https://github.com/FossilizedProgrammer/sstp-proxy) | کلاینت پروکسی SSTP این برنامه توسط سازندهٔ پینگوی شیطون توسعه داده شده است. این پیاده‌سازی پروتکل را به‌صورت پروکسی محلی در اختیار می‌گذارد و زنجیره‌سازی تونل‌ها را ممکن می‌کند |
| [**firefox-vpn-go**](https://github.com/FossilizedProgrammer/firefox-vpn-go) | هستهٔ وی‌پی‌ان فایرفاکس این برنامه — کلاینت Go مستقل برای وی‌پی‌ان داخلی IP Protection فایرفاکس (Mozilla VPN) که به‌صورت باینری آمادهٔ release منتشر می‌شود |

---

### 📝 نکته‌ای دربارهٔ باینری شیر و خورشید

> فایل `psiphon-tunnel-core-sunandlion` داخل برنامه، نام محلی انتخاب‌شده برای فورک شیر و خورشید است. این نام، نام اصلی پروژه نیست. تمام توسعه، نگهداری و رفع اشکال آن هسته در [`shirokhorshid/psiphon-tunnel-core`](https://github.com/shirokhorshid/psiphon-tunnel-core) انجام می‌شود. این مخزن فقط باینری کامپایل‌شده را آینه می‌کند تا برنامه بتواند از طریق آپدیتر داخلی خودش آن را دانلود کند.

---

## 📬 ارتباط با توسعه‌دهنده

سؤال، گزارش باگ، یا بازخورد — از طریق ایکس با توسعه‌دهنده در تماس باشید:

<div align="center">

[![X (formerly Twitter)](https://img.shields.io/badge/X-@tenblockperhour-black?logo=x&style=for-the-badge)](https://x.com/tenblockperhour)

</div>

---

## 📄 مجوز

این پروژه تحت مجوز **GNU General Public License v3.0** منتشر شده است.  
برای جزئیات بیشتر، فایل [`LICENSE`](LICENSE) را مطالعه کنید.

---

<div align="center">

**ساخته شده با ❤️ توسط [FossilizedProgrammer](https://github.com/FossilizedProgrammer)**

</div>

</div>
