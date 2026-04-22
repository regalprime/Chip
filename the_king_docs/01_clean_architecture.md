# Clean Architecture trong Project

## Tong quan

Project su dung Clean Architecture chia thanh 3 layer chinh,
giup tach biet logic, de test va de bao tri.

```
common_packages/lib/
├── domain/          ← Business logic (khong phu thuoc gi)
├── data/            ← Giao tiep voi ben ngoai (API, DB, Storage)
└── presentation/    ← UI + State management
```

## 1. Domain Layer (Loi cua ung dung)

Khong import bat ky package nao ngoai Dart core.
Day la noi dinh nghia "ung dung lam gi".

```
domain/
├── entities/           # Data classes thuan tuy
│   ├── user/user_entity.dart
│   ├── note/note_entity.dart
│   └── ...
├── repositories/       # Abstract classes (interface)
│   ├── auth_repository.dart
│   ├── note_repository.dart
│   └── remote_data_source.dart
└── usecases/           # 1 class = 1 hanh dong
    ├── auth/sign_in_with_google_use_case.dart
    ├── note/add_note_use_case.dart
    └── ...
```

### Entity
- La data class thuan tuy, khong co logic luu tru
- Dung `Equatable` de so sanh
- Vi du: `UserEntity(uid, email, displayName, photoUrl, bio)`

### Repository (Abstract)
- Dinh nghia "can lam gi" nhung KHONG dinh nghia "lam nhu the nao"
- Vi du: `Future<UserEntity?> signInWithGoogle()`

### UseCase
- 1 class = 1 chuc nang duy nhat
- Goi repository de thuc thi
- Co 2 loai:
  - `UseCase<Type, Params>` - co tham so
  - `UseCaseNoParams<Type>` - khong tham so

```dart
class GetNotesUseCase extends UseCaseNoParams<List<NoteEntity>> {
  final NoteRepository _repository;
  GetNotesUseCase(this._repository);

  @override
  Future<Result<List<NoteEntity>>> call() {
    return _repository.getNotes();
  }
}
```

## 2. Data Layer (Giao tiep ben ngoai)

Implement cac abstract class tu Domain layer.

```
data/
├── models/             # Entity + JSON serialization
│   ├── user/user_model.dart
│   └── ...
├── data_source/        # Giao tiep truc tiep voi API/DB
│   └── remote_data_source.dart   # Impl: Firebase + Supabase
└── repositories_impl/  # Implement abstract repository
    ├── auth_repository_impl.dart
    └── ...
```

### Model
- Extend tu Entity, them `fromJson()` va `toJson()`
- Vi du: `UserModel extends UserEntity`

### RemoteDataSourceImpl
- Truc tiep goi Firebase Auth, Supabase Client
- Day la noi duy nhat chua code giao tiep voi server

### RepositoryImpl
- Implement abstract Repository
- Goi DataSource, xu ly loi, chuyen Model → Entity

## 3. Presentation Layer (UI)

```
presentation/
├── blocs/              # State management (BLoC pattern)
│   ├── auth/auth_bloc.dart
│   └── ...
├── pages/              # Man hinh
│   ├── sign_in.dart
│   ├── note/note_view.dart
│   └── ...
└── home_screen.dart    # Man hinh chinh voi bottom nav
```

## Luong du lieu (Data Flow)

```
UI (Widget)
  → BLoC.add(Event)
    → UseCase.call()
      → Repository (abstract)
        → RepositoryImpl
          → RemoteDataSourceImpl
            → Firebase / Supabase
          ← Model (fromJson)
        ← Entity
      ← Result<Entity>
    ← emit(State)
  ← BlocBuilder rebuild UI
```

## Result Pattern

Dung `sealed class Result<T>` thay vi try-catch o moi noi:

```dart
sealed class Result<T> {}
class Success<T> extends Result<T> { final T data; }
class Failure<T> extends Result<T> { final AppFailure failure; }

// Su dung:
result.when(
  success: (data) { ... },
  failure: (error) { ... },
);
```
