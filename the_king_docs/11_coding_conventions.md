# Coding Conventions

## Quy tac dat ten

### Files & Folders
- `snake_case`: `auth_bloc.dart`, `user_entity.dart`, `remote_data_source.dart`
- Folder cung `snake_case`: `counter_day/`, `document_reader/`

### Classes
- `PascalCase`: `AuthBloc`, `UserEntity`, `RemoteDataSourceImpl`
- Suffix theo vai tro:
  - Entity: `UserEntity`
  - Model: `UserModel`
  - BLoC: `AuthBloc`
  - Event: `SignInWithGoogleEvent`
  - State: `AuthAuthenticated`
  - UseCase: `GetNotesUseCase`
  - Repository: `NoteRepository` (abstract), `NoteRepositoryImpl` (impl)

### Variables & Methods
- `camelCase`: `selectedDate`, `daysDiff`, `onPressed`
- Private: `_repository`, `_onLoad()`

## Cau truc BLoC file

```dart
// 1. Imports
import 'package:...';

// 2. Part declarations
part 'xxx_event.dart';
part 'xxx_state.dart';

// 3. Class
class XxxBloc extends Bloc<XxxEvent, XxxState> {
  // 3a. Dependencies (private final)
  final XxxRepository _repository;

  // 3b. Constructor
  XxxBloc({required XxxRepository repository})
    : _repository = repository,
      super(const XxxState()) {
    on<LoadEvent>(_onLoad);
    on<AddEvent>(_onAdd);
  }

  // 3c. Handlers
  Future<void> _onLoad(...) async { ... }
}
```

## Import conventions

```dart
// Thu tu import:
// 1. Dart SDK
import 'dart:io';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Project packages
import 'package:common_packages/domain/entities/...';

// 5. Relative imports
import '../../blocs/auth/auth_bloc.dart';
```

## Widget conventions

- StatelessWidget khi khong co local state
- StatefulWidget khi co TextEditingController, animation, toggle
- Tach sub-widgets thanh private class `_MySubWidget` trong cung file
- Prefix `_` cho widget chi dung noi bo file

## Error handling

- RemoteDataSourceImpl: throw `ServerException`
- RepositoryImpl: catch va throw lai (hoac tra Result)
- BLoC: catch va emit error state
- UI: BlocListener hien SnackBar khi co error

## Equatable

- Tat ca Entity, Event, State deu extend `Equatable`
- Override `props` de BLoC biet khi nao rebuild

## Khong nen lam

- Khong import `AppColors` truc tiep trong widget → dung `context.appColors`
- Khong hardcode mau sac → dung Theme
- Khong goi truc tiep Supabase/Firebase trong BLoC → di qua UseCase → Repository
- Khong de logic trong UI → chuyen vao BLoC
- Khong tao file moi khi co the sua file cu
