# My Chip

mise run dev
mise run prod

## Project Structure

```
the_king_app/
├── common_packages/    # Shared code (entities, blocs, UI, data)
├── development/        # Development app (com.example.development)
├── production/         # Production app (com.example.production)
└── supabase_setup.sql  # Full Supabase database schema
```

## Setup

```bash
# 1. Clean & install dependencies
cd development && flutter clean && flutter pub get
cd ../production && flutter clean && flutter pub get
cd ../common_packages && flutter pub get

# 2. Generate localization files (run in each app folder)
cd development && flutter gen-l10n
cd ../production && flutter gen-l10n
```

## Run

```bash
# Development
cd development && flutter run

# Production
cd production && flutter run
```

---

## Build APK - Android

### Development

```bash
cd development

# Debug (nhanh, co debug tools, khong can signing)
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Profile (test performance, co profiling tools)
flutter build apk --profile
# Output: build/app/outputs/flutter-apk/app-profile.apk

# Release (toi uu, can signing)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Release App Bundle (de upload len Google Play)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Production

```bash
cd production

# Debug
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Profile
flutter build apk --profile
# Output: build/app/outputs/flutter-apk/app-profile.apk

# Release
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Release App Bundle (Google Play)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Build IPA - iOS

### Development

```bash
cd development

# Debug (chay tren simulator hoac device qua Xcode)
flutter build ios --debug --no-codesign
# Output: build/ios/iphoneos/Runner.app

# Profile
flutter build ios --profile --no-codesign
# Output: build/ios/iphoneos/Runner.app

# Release (can Apple Developer account + signing)
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app

# Build IPA (de upload len App Store / TestFlight)
flutter build ipa --release
# Output: build/ios/ipa/development.ipa
```

### Production

```bash
cd production

# Debug
flutter build ios --debug --no-codesign

# Profile
flutter build ios --profile --no-codesign

# Release
flutter build ios --release

# Build IPA (App Store / TestFlight)
flutter build ipa --release
# Output: build/ios/ipa/production.ipa
```

---

## Build - Other Platforms

### Web

```bash
cd development   # hoac cd production

flutter build web --release
# Output: build/web/
```

### macOS

```bash
cd development   # hoac cd production

flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

### Linux

```bash
cd development   # hoac cd production

flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

### Windows

```bash
cd development   # hoac cd production

flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

---

## So sanh cac che do build

| Che do  | Toc do build | Kich thuoc | Debug tools | Performance | Dung cho                    |
| ------- | ------------ | ---------- | ----------- | ----------- | --------------------------- |
| Debug   | Nhanh        | Lon        | Co          | Cham        | Dev, hot reload             |
| Profile | Trung binh   | Trung binh | Profiling   | Gan release | Test performance            |
| Release | Cham         | Nho        | Khong       | Tot nhat    | Phat hanh, chia se cho user |

## Luu y

- **Debug APK** co the cai truc tiep tren thiet bi Android ma khong can signing.
- **Release APK** can cau hinh signing key trong `android/app/build.gradle`. Neu chua co, tao keystore:
  ```bash
  keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
  ```
- **iOS Release/IPA** bat buoc can Apple Developer account va cau hinh signing trong Xcode.
- **App Bundle (.aab)** la dinh dang Google Play yeu cau thay vi APK khi upload.

---

## Doi ten ung dung

### Android

Sua `android:label` trong file `AndroidManifest.xml`:

```
development/android/app/src/main/AndroidManifest.xml
production/android/app/src/main/AndroidManifest.xml
```

```xml
<application
    android:label="Ten App Cua Ban"
    ...>
```

### iOS

Sua trong file `Info.plist`:

```
development/ios/Runner/Info.plist
production/ios/Runner/Info.plist
```

```xml
<key>CFBundleDisplayName</key>
<string>Ten App Cua Ban</string>

<key>CFBundleName</key>
<string>Ten App Cua Ban</string>
```

---

## Doi anh dai dien (App Icon)

### Cach 1: Dung package flutter_launcher_icons (khuyen khich)

```bash
# 1. Them vao common_packages/pubspec.yaml
# dev_dependencies:
#   flutter_launcher_icons: ^0.14.3

# 2. Tao file flutter_launcher_icons.yaml tai root cua development/ hoac production/
```

Noi dung file `flutter_launcher_icons.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"        # Anh 1024x1024
  adaptive_icon_background: "#D32F2F"            # Mau nen Android adaptive icon
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

```bash
# 3. Chay lenh
cd development   # hoac cd production
dart run flutter_launcher_icons
```

### Cach 2: Thay thu cong

**Android** - thay cac file `ic_launcher.png` trong:

```
android/app/src/main/res/mipmap-mdpi/ic_launcher.png       (48x48)
android/app/src/main/res/mipmap-hdpi/ic_launcher.png       (72x72)
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png      (96x96)
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png     (144x144)
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png    (192x192)
```

**iOS** - thay cac file trong:

```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

Hoac mo Xcode → Runner → Assets → AppIcon, keo tha anh vao.
