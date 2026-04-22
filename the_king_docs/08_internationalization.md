# Da ngon ngu (i18n / Localization)

## Cau truc

```
common_packages/lib/base/languages/
├── l10n/
│   ├── app_en.arb          ← Tieng Anh
│   ├── app_vn.arb          ← Tieng Viet
│   └── gen/                ← File gen tu dong (KHONG sua tay)
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_vi.dart
└── bloc/
    └── app_language_bloc.dart   ← BLoC quan ly ngon ngu
```

## Them chuoi moi

### Buoc 1: Them vao file .arb

`app_en.arb`:
```json
{
  "welcomeMessage": "Welcome to My Chip!",
  "itemCount": "{count} items",
  "@itemCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

`app_vn.arb`:
```json
{
  "welcomeMessage": "Chao mung den My Chip!",
  "itemCount": "{count} muc"
}
```

### Buoc 2: Gen lai

```bash
cd development && flutter gen-l10n
cd ../production && flutter gen-l10n
```

### Buoc 3: Su dung trong code

```dart
import 'package:common_packages/base/extensions/context_extension.dart';

// Dung context extension
Text(context.l10n.welcomeMessage)
Text(context.l10n.itemCount(5))

// Hoac dung truc tiep
Text(AppLocalizations.of(context)!.welcomeMessage)
```

## Chuyen ngon ngu

```dart
// Trong code
context.read<AppLanguageBloc>().add(
  ChangeAppLanguage(selectedLanguage: AppLanguage.vietnamese),
);

// Ngon ngu ho tro
enum AppLanguage {
  english,     // Locale('en', 'US')
  vietnamese,  // Locale('vi', 'VN')
}
```

## Cau hinh trong MaterialApp (the_king_app.dart)

```dart
MaterialApp(
  locale: languageState.selectedLanguage.value,
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
)
```
