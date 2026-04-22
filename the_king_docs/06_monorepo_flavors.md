# Monorepo va Flavors (Dev/Prod)

## Cau truc

```
the_king_app/
├── common_packages/     ← Toan bo code chia se
│   └── lib/
│       ├── domain/
│       ├── data/
│       ├── presentation/
│       ├── di/injection.dart
│       ├── base/            (theme, i18n, design_system)
│       └── constants/
│
├── development/             ← App flavor Development
│   └── lib/
│       ├── main.dart        ← Entry point (Firebase dev + Supabase dev)
│       └── config/
│           ├── app_config.dart       ← Supabase URL + key (dev)
│           └── backend_config.dart   ← API base URL (dev)
│
└── production/              ← App flavor Production
    └── lib/
        ├── main.dart        ← Entry point (Firebase prod + Supabase prod)
        └── config/
            ├── app_config.dart       ← Supabase URL + key (prod)
            └── backend_config.dart   ← API base URL (prod)
```

## Tai sao dung monorepo?

- **1 codebase** cho logic + UI (trong common_packages)
- **Config rieng** cho moi moi truong (Firebase, Supabase, API URL)
- **Package rieng** (applicationId, bundle ID) → cai song song tren 1 thiet bi
- **Khong can flavor phuc tap** cua Android/iOS

## Cach hoat dong

`development/` va `production/` la 2 Flutter app doc lap.
Ca 2 deu depend vao `common_packages`:

```yaml
# development/pubspec.yaml
dependencies:
  common_packages:
    path: ../common_packages
```

Moi app chi co:
- `main.dart` → khoi tao Firebase + Supabase voi config rieng
- `config/` → URL, key rieng cho moi moi truong

Toan bo logic nam trong `common_packages`.

## Them feature moi

1. Viet code trong `common_packages/`
2. Khong can sua gi trong `development/` hay `production/`
3. Ca 2 flavor tu dong co feature moi

## Package IDs

| Flavor      | Android applicationId     | iOS Bundle ID                |
|-------------|---------------------------|------------------------------|
| Development | com.example.development   | com.example.development      |
| Production  | com.example.production    | com.example.production       |

## Run / Build

```bash
# Luon cd vao dung folder truoc khi run/build
cd development && flutter run
cd production && flutter build apk --release
```
