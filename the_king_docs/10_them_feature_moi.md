# Huong dan them Feature moi

## Checklist tao feature moi (vi du: "Todo")

### 1. Domain Layer

```
domain/entities/todo/todo_entity.dart
domain/repositories/todo_repository.dart          ← abstract
domain/usecases/todo/get_todos_use_case.dart
domain/usecases/todo/add_todo_use_case.dart
```

### 2. Data Layer

```
data/models/todo/todo_model.dart                  ← extend Entity, them fromJson/toJson
data/repositories_impl/todo_repository_impl.dart  ← implement abstract
```

Them vao RemoteDataSource:
```
domain/repositories/remote_data_source.dart       ← them abstract methods
data/data_source/remote_data_source.dart           ← implement Supabase queries
```

### 3. Presentation Layer

```
presentation/blocs/todo/
├── todo_bloc.dart
├── todo_event.dart
└── todo_state.dart

presentation/pages/todo/
├── todo_view.dart              ← Man hinh chinh
├── todo_detail_view.dart       ← Man hinh chi tiet (neu can)
└── add_todo_sheet.dart         ← Bottom sheet them moi (neu can)
```

### 4. Dependency Injection

Trong `di/injection.dart`, them theo thu tu:

```dart
// Repository
sl.registerLazySingleton<TodoRepository>(
  () => TodoRepositoryImpl(remoteDataSource: sl()),
);

// Use Cases
sl.registerLazySingleton(() => GetTodosUseCase(sl()));
sl.registerLazySingleton(() => AddTodoUseCase(sl()));

// BLoC
sl.registerFactory<TodoBloc>(
  () => TodoBloc(getTodosUseCase: sl(), addTodoUseCase: sl()),
);
```

### 5. Supabase (neu can bang moi)

1. Them CREATE TABLE vao `supabase_setup.sql`
2. Them DROP TABLE o dau file
3. Them INDEX
4. Them DISABLE ROW LEVEL SECURITY
5. Cap nhat bang tom tat o cuoi file
6. Chay SQL tren Supabase Dashboard

### 6. Them vao Home Screen

`presentation/home_screen.dart`:
- Them BlocProvider trong MultiBlocProvider
- Them icon vao mang `icons`
- Them View vao IndexedStack `children`

### 7. Localization (neu can)

- Them chuoi vao `app_en.arb` va `app_vn.arb`
- Chay `flutter gen-l10n`

## Template nhanh

### Entity

```dart
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  const TodoEntity({required this.id, required this.title, this.done = false});
  final String id;
  final String title;
  final bool done;
  @override
  List<Object?> get props => [id, title, done];
}
```

### Model

```dart
class TodoModel extends TodoEntity {
  const TodoModel({required super.id, required super.title, super.done});

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'] as String,
    title: json['title'] as String,
    done: json['done'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
}
```

### BLoC State

```dart
enum TodoStatus { initial, loading, loaded, error }

class TodoState extends Equatable {
  const TodoState({this.status = TodoStatus.initial, this.items = const [], this.errorMessage});
  final TodoStatus status;
  final List<TodoEntity> items;
  final String? errorMessage;

  TodoState copyWith({TodoStatus? status, List<TodoEntity>? items, String? errorMessage}) {
    return TodoState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
```
