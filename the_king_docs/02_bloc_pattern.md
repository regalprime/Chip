# BLoC Pattern trong Project

## BLoC la gi?

BLoC (Business Logic Component) tach UI ra khoi logic xu ly.
UI chi gui Event va lang nghe State.

```
UI ──(Event)──→ BLoC ──(State)──→ UI
```

## Cau truc 1 BLoC

Moi feature co 3 file:

```
blocs/
└── note/
    ├── note_bloc.dart      # Logic xu ly
    ├── note_event.dart     # Cac hanh dong (input)
    └── note_state.dart     # Trang thai (output)
```

### Event (Input)

```dart
part of 'note_bloc.dart';

sealed class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {
  const LoadNotesEvent();
}

class AddNoteEvent extends NoteEvent {
  const AddNoteEvent({required this.title, required this.content});
  final String title;
  final String content;
  @override
  List<Object?> get props => [title, content];
}
```

### State (Output)

```dart
part of 'note_bloc.dart';

enum NoteStatus { initial, loading, loaded, error }

class NoteState extends Equatable {
  const NoteState({
    this.status = NoteStatus.initial,
    this.notes = const [],
    this.errorMessage,
  });

  final NoteStatus status;
  final List<NoteEntity> notes;
  final String? errorMessage;

  NoteState copyWith({ ... }) { ... }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
```

### BLoC (Logic)

```dart
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc({required GetNotesUseCase getNotesUseCase, ...})
    : _getNotesUseCase = getNotesUseCase,
      super(const NoteState()) {
    on<LoadNotesEvent>(_onLoad);
    on<AddNoteEvent>(_onAdd);
  }

  Future<void> _onLoad(LoadNotesEvent event, Emitter<NoteState> emit) async {
    emit(state.copyWith(status: NoteStatus.loading));
    try {
      final notes = await _getNotesUseCase();
      emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
    } catch (e) {
      emit(state.copyWith(status: NoteStatus.error, errorMessage: '$e'));
    }
  }
}
```

## Su dung trong UI

### Cung cap BLoC

```dart
// Cach 1: Trong MultiBlocProvider (thuong o HomeScreen)
BlocProvider<NoteBloc>(create: (_) => sl<NoteBloc>()),

// Cach 2: Khi navigate sang man hinh moi
Navigator.push(context, MaterialPageRoute(
  builder: (_) => BlocProvider.value(
    value: context.read<NoteBloc>(),
    child: const NoteDetailScreen(),
  ),
));
```

### Gui Event

```dart
context.read<NoteBloc>().add(const LoadNotesEvent());
context.read<NoteBloc>().add(AddNoteEvent(title: 'Hi', content: '...'));
```

### Lang nghe State

```dart
// BlocBuilder - rebuild UI khi state thay doi
BlocBuilder<NoteBloc, NoteState>(
  builder: (context, state) {
    if (state.status == NoteStatus.loading) {
      return CircularProgressIndicator();
    }
    return ListView(...);
  },
)

// BlocListener - xu ly side effect (snackbar, navigate, ...)
BlocListener<NoteBloc, NoteState>(
  listener: (context, state) {
    if (state.status == NoteStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: ...,
)

// BlocConsumer = BlocBuilder + BlocListener
BlocConsumer<NoteBloc, NoteState>(
  listener: (context, state) { ... },
  builder: (context, state) { ... },
)
```

## Cac BLoC hien co trong project

| BLoC              | Chuc nang                    |
|-------------------|------------------------------|
| AuthBloc          | Dang nhap, dang ky, dang xuat |
| DayCounterBloc    | Dem ngay (CRUD, Supabase)    |
| PhotoBloc         | Upload, xem, xoa anh        |
| NoteBloc          | CRUD ghi chu                 |
| FinanceBloc       | Thu chi, ngan sach           |
| FriendBloc        | Ket ban, tim kiem            |
| MomentBloc        | Chia se tam trang            |
| FeedBloc          | Feed chia se                 |
| ProfileBloc       | Cap nhat profile             |
| DocumentReaderBloc| Doc tai lieu PDF/Word/TXT    |
| ThemeBloc         | Chuyen dark/light mode       |
| AppLanguageBloc   | Chuyen ngon ngu EN/VN       |
| BottomNavBloc     | Dieu khien tab hien tai      |
