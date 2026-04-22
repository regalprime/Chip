# CI/CD Guide

Project hien tai CHUA co CI/CD. Duoi day la huong dan thiet lap.

## Lua chon 1: GitHub Actions (Mien phi cho public repo)

Tao file `.github/workflows/build.yml`:

```yaml
name: Build & Test

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.x'

      - name: Install dependencies
        run: |
          cd common_packages && flutter pub get
          cd ../development && flutter pub get

      - name: Analyze
        run: cd development && flutter analyze --no-fatal-infos

      - name: Test
        run: cd development && flutter test

  build-android:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.x'

      - name: Install dependencies
        run: |
          cd common_packages && flutter pub get
          cd ../development && flutter pub get

      - name: Build APK (Development)
        run: cd development && flutter build apk --debug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: dev-apk
          path: development/build/app/outputs/flutter-apk/app-debug.apk

  build-ios:
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.x'

      - name: Install dependencies
        run: |
          cd common_packages && flutter pub get
          cd ../development && flutter pub get

      - name: Build iOS (no codesign)
        run: cd development && flutter build ios --debug --no-codesign
```

### Release build voi signing

Them secrets vao GitHub Repository Settings → Secrets:
- `KEYSTORE_BASE64` - base64 cua file .jks
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

```yaml
  build-release:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/master'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2

      - name: Decode keystore
        run: echo ${{ secrets.KEYSTORE_BASE64 }} | base64 -d > android/app/keystore.jks

      - name: Build Release APK
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: cd production && flutter build apk --release
```

## Lua chon 2: Fastlane

### Cai dat

```bash
# macOS
brew install fastlane

# Khoi tao cho Android
cd production/android && fastlane init

# Khoi tao cho iOS
cd production/ios && fastlane init
```

### Fastfile vi du (Android)

```ruby
# production/android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Build debug APK"
  lane :debug do
    Dir.chdir("..") do
      sh("cd .. && flutter build apk --debug")
    end
  end

  desc "Build release va upload len Google Play Internal"
  lane :release do
    Dir.chdir("..") do
      sh("cd .. && flutter build appbundle --release")
    end
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

### Fastfile vi du (iOS)

```ruby
# production/ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build va upload len TestFlight"
  lane :beta do
    Dir.chdir("..") do
      sh("cd .. && flutter build ipa --release")
    end
    upload_to_testflight(
      ipa: '../build/ios/ipa/production.ipa'
    )
  end
end
```

## Lua chon 3: Codemagic (CI/CD cho Flutter)

Dang ky tai codemagic.io, ket noi GitHub repo.
Codemagic tu dong nhan dien Flutter project va tao pipeline.

Uu diem:
- UI de dung, khong can viet YAML phuc tap
- Ho tro iOS build tren macOS (GitHub Actions can macos-latest tot kem)
- Free 500 phut/thang

## Quy trinh khuyen nghi

```
Push code → GitHub Actions chay test + analyze
         → Merge vao master
         → Auto build APK/IPA
         → Upload artifact hoac deploy len store
```
