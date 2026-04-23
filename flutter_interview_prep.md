# Flutter Interview Prep — 2+ năm kinh nghiệm

> Tài liệu ôn phỏng vấn Flutter tổng hợp, bao gồm:
> - **Phần 1**: 15 câu cơ bản (từ file `pv.txt`) — có câu trả lời đầy đủ + code ví dụ
> - **Phần 2**: Bộ câu hỏi mid-level theo chủ đề (A–M)
> - **Phần 3**: Chiến lược & tips trả lời phỏng vấn

---

## 📑 Mục lục

**[PHẦN 1 — 15 CÂU CƠ BẢN](#phần-1--15-câu-cơ-bản)**
1. [Vòng đời App](#1-vòng-đời-app)
2. [Vòng đời Widget](#2-vòng-đời-widget)
3. [State Management — so sánh](#3-state-management--so-sánh)
4. [Bloc hoạt động thế nào](#4-bloc-hoạt-động-thế-nào)
5. [Widget tree](#5-widget-tree)
6. [BuildContext](#6-buildcontext)
7. [Performance Optimization](#7-performance-optimization)
8. [Dependency Injection (DI)](#8-dependency-injection-di)
9. [Design Pattern](#9-design-pattern)
10. [Cấu trúc folder tối ưu](#10-cấu-trúc-folder-tối-ưu)
11. [Điều hướng màn hình](#11-điều-hướng-màn-hình)
12. [Lập trình hướng đối tượng (OOP)](#12-lập-trình-hướng-đối-tượng-oop)
13. [Lập trình bất đồng bộ (Async)](#13-lập-trình-bất-đồng-bộ-async)
14. [Stream](#14-stream)
15. [SOLID](#15-solid)

**[PHẦN 2 — CÂU HỎI MID-LEVEL](#phần-2--câu-hỏi-mid-level)**
- [A. Dart nâng cao](#a-dart-nâng-cao)
- [B. Flutter internals](#b-flutter-internals)
- [C. State management (sâu)](#c-state-management-sâu)
- [D. Performance](#d-performance)
- [E. Async & Concurrency](#e-async--concurrency)
- [F. Testing](#f-testing)
- [G. Architecture & Design](#g-architecture--design)
- [H. Native integration](#h-native-integration)
- [I. CI/CD & Release](#i-cicd--release)
- [J. Security](#j-security)
- [K. Tình huống thực tế](#k-tình-huống-thực-tế)
- [L. Coding exercise](#l-coding-exercise)
- [M. Câu mở rộng khó](#m-câu-mở-rộng-khó)
- [N. Custom Widget](#n-custom-widget)
- [O. Web Service & API (REST, JSON, Dio, Retrofit, SOAP/XML)](#o-web-service--api-rest-json-dio-retrofit-soapxml)
- [P. SQL & SQLite](#p-sql--sqlite)
- [Q. Git workflow](#q-git-workflow)
- [R. MVP / MVC / MVVM](#r-mvp--mvc--mvvm)

**[PHẦN 3 — CHIẾN LƯỢC PHỎNG VẤN](#phần-3--chiến-lược-phỏng-vấn)**

---
---

# PHẦN 1 — 15 CÂU CƠ BẢN

## 1. Vòng đời App

**Trả lời ngắn:**
App Flutter có 4 state quản lý bởi `WidgetsBindingObserver`:
- **`resumed`**: foreground, user đang tương tác
- **`inactive`**: mất focus tạm thời (cuộc gọi đến, kéo notification panel)
- **`paused`**: background, không chạy UI nhưng process còn sống
- **`detached`**: UI bị gỡ, engine còn chạy (hiếm gặp trên mobile)

**Code ví dụ:**
```dart
class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // user chuyển app sang background → save draft, pause video, close socket
    }
    if (state == AppLifecycleState.resumed) {
      // → refresh token, reload data
    }
  }
}
```

**Follow-up:**
- Khi app vào `paused` có nên gọi API không? → **KHÔNG**, network request có thể bị OS kill.
- Phân biệt `inactive` vs `paused`? → `inactive` là **tạm thời**, `paused` mới là background thực sự.

---

## 2. Vòng đời Widget

**Trả lời ngắn:** Chỉ `StatefulWidget` mới có lifecycle:

```
createState() → initState() → didChangeDependencies() → build()
  ↓ (khi parent rebuild)
didUpdateWidget() → build()
  ↓ (khi bị gỡ)
deactivate() → dispose()
```

**Khi nào gọi hàm nào:**

| Hàm | Khi nào | Dùng để |
|---|---|---|
| `initState` | 1 lần đầu | Khởi tạo controller, subscribe stream |
| `didChangeDependencies` | Sau initState + khi `InheritedWidget` đổi | Đọc `Theme.of(context)`, `MediaQuery` |
| `build` | Mỗi khi setState/rebuild | Chỉ trả widget, KHÔNG có side effect |
| `didUpdateWidget` | Parent truyền prop mới | So sánh `oldWidget.id != widget.id` để reset |
| `dispose` | Widget bị gỡ | Cancel subscription, dispose controller |

**Ví dụ cẩn thận:**
```dart
@override
void initState() {
  super.initState();
  _controller = TextEditingController();
  // ❌ KHÔNG dùng context ở đây
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _theme = Theme.of(context); // ✅ context sẵn sàng
}

@override
void dispose() {
  _controller.dispose();       // ✅ tránh memory leak
  _subscription?.cancel();
  super.dispose();
}
```

**Follow-up:**
- `initState` có được `async` không? → **Không** (nhưng bên trong có thể gọi hàm async, không await).
- Tại sao không dùng `context` trong `initState`? → Vì widget chưa mount vào tree.

---

## 3. State Management — so sánh

|  | `setState` | Provider | Riverpod | Bloc |
|---|---|---|---|---|
| Độ phức tạp | Thấp | Thấp | Trung bình | Cao |
| Khi nào dùng | State nội bộ 1 widget | App nhỏ/vừa | App vừa/lớn, compile-time safe | Project team lớn, cần test/tách logic |
| Testable | Khó | OK | Tốt | Rất tốt |
| Boilerplate | Ít | Vừa | Vừa | Nhiều |

**Tip phỏng vấn:** Đừng nói "cái nào cũng được". Nói rõ:
> *"Project cá nhân em dùng Bloc vì tách UI/logic rõ ràng, dễ test, team mới dễ theo pattern. Nhược điểm là boilerplate, nên feature đơn giản em vẫn dùng setState để tránh over-engineer."*

---

## 4. Bloc hoạt động thế nào

**Flow:** `UI → Event → Bloc → emit(State) → UI rebuild`

**Nguyên tắc cốt lõi:**
- **Event** = ý định của user ("tôi muốn login")
- **State** = kết quả / trạng thái UI ("đang loading" / "thành công")
- Bloc = pure function `(Event, currentState) → new State`

**Ví dụ:**
```dart
// Events
sealed class AuthEvent {}
class SignInRequested extends AuthEvent {
  final String email, password;
  SignInRequested(this.email, this.password);
}

// States
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState { final User user; AuthSuccess(this.user); }
class AuthFailure extends AuthState { final String error; AuthFailure(this.error); }

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  AuthBloc(this.repo) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repo.signIn(event.email, event.password);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}

// UI
BlocBuilder<AuthBloc, AuthState>(
  builder: (ctx, state) => switch (state) {
    AuthLoading() => CircularProgressIndicator(),
    AuthFailure(:final error) => Text(error),
    _ => SignInForm(),
  },
);
```

**Follow-up:**
- Khác gì Cubit? → Cubit không có Event, gọi method trực tiếp — đơn giản hơn, nhưng mất khả năng log/replay event.
- Khi nào dùng `BlocListener` vs `BlocBuilder`? → Builder rebuild UI; Listener cho side-effect (navigate, show snackbar).

---

## 5. Widget tree

**Trả lời ngắn:**
UI Flutter là cây widget lồng nhau. Flutter có **3 tree song song**:
- **Widget tree** — blueprint bất biến (immutable), mô tả UI nên trông như thế nào
- **Element tree** — instance runtime, giữ liên kết với BuildContext và widget hiện tại
- **RenderObject tree** — tree thực sự vẽ pixel lên màn hình

Khi `setState`, Flutter chỉ rebuild nhánh widget cần thiết, sau đó **diff** với element tree cũ để reuse RenderObject → đó là lý do Flutter nhanh.

**Follow-up:** Tại sao dùng `const` lại nhanh hơn? → `const` widget không cần rebuild vì Flutter biết chúng giống nhau về tham chiếu.

---

## 6. BuildContext

**Trả lời ngắn:**
`BuildContext` là handle trỏ tới vị trí của widget trong element tree. Dùng để:
- Tra cứu ancestor: `Theme.of(context)`, `MediaQuery.of(context)`, `Navigator.of(context)`, `context.read<MyBloc>()`
- Mỗi widget có context riêng, không share được giữa các widget khác nhau trong tree

**Bẫy thường gặp:**
```dart
// ❌ SAI — dùng context sau async gap, widget có thể đã unmounted
onPressed: () async {
  final data = await api.fetch();
  Navigator.push(context, ...); // có thể crash
}

// ✅ ĐÚNG
onPressed: () async {
  final data = await api.fetch();
  if (!context.mounted) return;
  Navigator.push(context, ...);
}
```

---

## 7. Performance Optimization

**Checklist trả lời:**
1. Dùng **`const`** cho widget tĩnh → tránh rebuild
2. **Tách widget nhỏ** để giới hạn scope `setState`
3. Dùng `ListView.builder` thay vì `ListView(children: [...])` cho list dài
4. **`RepaintBoundary`** cho vùng hay đổi (animation) → tách layer vẽ
5. Dùng **`cached_network_image`** cho ảnh remote
6. **`compute()` / `Isolate`** cho xử lý nặng (parse JSON lớn, decrypt)
7. **Defer heavy work** bằng `WidgetsBinding.instance.addPostFrameCallback`

**Load ảnh nặng:**
```dart
Image.network(
  url,
  cacheWidth: 300,                        // giảm kích thước decode — quan trọng nhất
  cacheHeight: 300,
  loadingBuilder: (ctx, child, progress) =>
    progress == null ? child : ShimmerPlaceholder(),
)
```
- Flutter decode ảnh trên **engine background thread**, không block main isolate
- Nhưng ảnh quá to (4K) → memory leak. Luôn dùng `cacheWidth/cacheHeight`
- Xử lý ảnh custom (blur, filter) → dùng `compute()` chạy trên isolate khác

**Follow-up:** Làm sao đo performance? → **DevTools → Performance**, bật "Track widget builds", check frame dropped. 60fps = mỗi frame < 16ms.

---

## 8. Dependency Injection (DI)

**Trả lời ngắn:** DI là pattern **tách việc tạo dependency ra khỏi class sử dụng nó**. Thay vì class tự `new` dependency, nó nhận từ ngoài truyền vào → dễ test (mock), dễ swap implementation.

**Ví dụ:**
```dart
// ❌ TỆ: tight coupling, không mock được
class AuthService {
  final api = HttpClient();
}

// ✅ TỐT: inject qua constructor
class AuthService {
  final HttpClient api;
  AuthService(this.api);
}

// Test dễ dàng:
final mockApi = MockHttpClient();
final service = AuthService(mockApi);
```

**Trong Flutter dùng gì:**
- `get_it` — service locator, đơn giản
- `provider` / `riverpod` — DI + state management
- `injectable` + `get_it` — tự generate code DI

**Follow-up:**
- 3 kiểu DI? → Constructor injection (phổ biến nhất), setter injection, interface injection.
- Singleton có phải DI không? → Không trực tiếp, nhưng `get_it` thường dùng singleton để cache instance.

---

## 9. Design Pattern

**Trả lời ngắn:** Là giải pháp **đã được chuẩn hoá** cho các vấn đề lặp lại trong thiết kế phần mềm. Chia 3 nhóm:
- **Creational**: Singleton, Factory, Builder
- **Structural**: Adapter, Decorator, Facade
- **Behavioral**: Observer, Strategy, State

**Ví dụ Singleton** (chỉ 1 instance toàn app):
```dart
class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  final data = <String, dynamic>{};
}
```

**Ví dụ Factory** (trả object dựa vào điều kiện):
```dart
abstract class Notification {
  factory Notification(String type) => switch (type) {
    'email' => EmailNotification(),
    'sms'   => SmsNotification(),
    _       => throw ArgumentError(),
  };
  void send();
}
```

**Observer** trong Flutter → chính là `ChangeNotifier` + `ValueListenable`.

**Follow-up:** Singleton có nhược điểm gì? → Global state, khó test, lifecycle khó quản lý. Đừng lạm dụng.

---

## 10. Cấu trúc folder tối ưu

**Trả lời ngắn:** Em dùng **Clean Architecture + Feature-first**:

```
lib/
├── core/                  # Shared toàn app
│   ├── di/                # get_it setup
│   ├── network/           # HTTP client, interceptors
│   ├── theme/
│   └── utils/
└── features/
    ├── auth/
    │   ├── data/          # API calls, repository impl, DTO
    │   │   ├── data_sources/
    │   │   ├── models/
    │   │   └── repositories_impl/
    │   ├── domain/        # Business rules, pure Dart
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── use_cases/
    │   └── presentation/  # UI
    │       ├── blocs/
    │       ├── pages/
    │       └── widgets/
    └── finance/
        └── (tương tự)
```

**Tại sao tốt:**
- **Feature-first**: muốn xóa/thêm feature chỉ xóa/thêm 1 folder
- **3 layer** (data/domain/presentation): test được từng layer độc lập
- **Domain** không biết gì về Flutter/HTTP → tái sử dụng cho backend Dart, CLI

**Follow-up:** Khi nào KHÔNG dùng Clean Architecture? → App nhỏ (<5 screen), prototype, hackathon → over-engineer.

---

## 11. Điều hướng màn hình

### Imperative (Navigator 1.0)
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage()));
Navigator.pop(context, resultData);
Navigator.pushNamed(context, '/detail', arguments: id);
```
Đơn giản, nhưng khó deeplink, khó test.

### Declarative (Navigator 2.0 / **go_router**)
```dart
final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => HomePage()),
  GoRoute(
    path: '/product/:id',
    builder: (_, state) => ProductPage(id: state.pathParameters['id']!),
  ),
  GoRoute(
    path: '/settings',
    redirect: (_, __) => isAuth ? null : '/login',
  ),
]);
```
- Hỗ trợ deeplink (URL → screen)
- Dễ authorize/guard
- Test routing dễ

**Trả lời phỏng vấn:** *"Em dùng `go_router` vì declarative, hỗ trợ URL trên web, dễ viết auth guard. Navigator 1.0 em vẫn dùng cho dialog/modal pop nhanh."*

---

## 12. Lập trình hướng đối tượng (OOP)

**4 trụ cột:**

| Pillar | Giải thích | Ví dụ Dart |
|---|---|---|
| **Encapsulation** | Ẩn chi tiết, expose API | Dùng `_` prefix: `_password` private |
| **Inheritance** | Class con kế thừa class cha | `class Dog extends Animal` |
| **Polymorphism** | 1 interface, nhiều implementation | Override method, `@override` |
| **Abstraction** | Tách "cái gì" ra khỏi "như thế nào" | `abstract class Repository` |

**Ví dụ kết hợp:**
```dart
abstract class PaymentMethod {
  Future<bool> pay(double amount);  // abstraction
}

class CreditCard implements PaymentMethod {
  final String _cardNumber;         // encapsulation
  CreditCard(this._cardNumber);
  @override
  Future<bool> pay(double amount) => processCard(_cardNumber, amount);
}

class Momo implements PaymentMethod {
  @override
  Future<bool> pay(double amount) => momoApi.charge(amount);
}

// Polymorphism — dùng qua abstraction, không biết là loại nào
void checkout(PaymentMethod method) => method.pay(100);
```

**Follow-up:** `extends` vs `implements` vs `with`?
- `extends` kế thừa (1 class), `implements` ràng buộc contract (nhiều), `with` mixin để share behavior.

---

## 13. Lập trình bất đồng bộ (Async)

**Core concept:** Dart single-threaded nhưng có **event loop** — khi gặp `await`, task bị pause, control quay lại event loop, task khác chạy tiếp.

**Các tool:**

| Tool | Khi nào dùng |
|---|---|
| `Future<T>` | Kết quả duy nhất trong tương lai (API call) |
| `async`/`await` | Viết code bất đồng bộ như đồng bộ |
| `Stream<T>` | Dãy giá trị theo thời gian (websocket, typing input) |
| `Isolate` | Thread thật sự, cho task CPU-nặng |

**Ví dụ Future:**
```dart
Future<User> fetchUser(int id) async {
  try {
    final res = await http.get(Uri.parse('/user/$id'));
    return User.fromJson(jsonDecode(res.body));
  } on SocketException {
    throw NetworkException();
  }
}

// Chạy song song
final results = await Future.wait([fetchUser(1), fetchUser(2), fetchUser(3)]);
```

**Bẫy phổ biến:**
```dart
// ❌ SAI: không await → execute fire-and-forget
Future onTap() {
  doSomething();
}

// ❌ SAI trong loop: chạy tuần tự, chậm
for (final id in ids) {
  await fetch(id);
}
// ✅ ĐÚNG: chạy song song
await Future.wait(ids.map(fetch));
```

**Follow-up:**
- `compute()` khác `Future.delayed` thế nào? → `compute` chạy trên isolate khác (thread thật), `Future.delayed` vẫn ở main isolate.
- `async*` là gì? → function trả `Stream`, dùng `yield` để emit value.

---

## 14. Stream

**Trả lời ngắn:** `Stream<T>` = sequence of async events. Khác `Future` (1 giá trị) ở chỗ Stream có thể emit **nhiều giá trị**.

**2 loại:**
- **Single-subscription** (mặc định): chỉ 1 listener, như đọc file
- **Broadcast**: nhiều listener, như sự kiện UI

**Ví dụ:**
```dart
// Tạo stream từ async*
Stream<int> countdown(int from) async* {
  for (int i = from; i >= 0; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Listen
final sub = countdown(5).listen((n) => print(n));

// Transform
countdown(5)
  .where((n) => n.isEven)
  .map((n) => 'Số $n')
  .listen(print);

// Dispose
await sub.cancel();
```

**Trong Flutter dùng khi nào:**
- `StreamBuilder` — lắng nghe Firebase/Supabase realtime
- Typing search với `debounce` (rxdart)
- Bloc thực chất là wrapper của Stream

**Bẫy:** luôn `cancel()` subscription trong `dispose()` → nếu không sẽ leak + crash "setState after dispose".

**Follow-up:**
- `Stream` vs `Iterable`? → `Iterable` là sync (có sẵn ngay), `Stream` là async.
- `StreamController` để làm gì? → Tạo stream thủ công, push event khi cần.

---

## 15. SOLID

5 nguyên tắc thiết kế OOP:

### **S — Single Responsibility**
1 class = 1 lý do để thay đổi.
```dart
// ❌ class làm quá nhiều
class User {
  void save() {...}      // DB logic
  void sendEmail() {...} // Email logic
  String toJson() {...}  // Serialization
}

// ✅ tách ra
class User { /* chỉ data */ }
class UserRepository { void save(User u); }
class EmailService { void send(User u); }
```

### **O — Open/Closed**
Mở rộng (extend) được, nhưng không sửa code cũ.
```dart
abstract class PaymentMethod { Future pay(double a); }
class Momo implements PaymentMethod {...}
class ZaloPay implements PaymentMethod {...}
// Thêm payment mới chỉ cần implements, không sửa checkout()
```

### **L — Liskov Substitution**
Class con phải dùng thay được class cha mà không phá logic.
```dart
// ❌ VI PHẠM: Square extends Rectangle nhưng setWidth của Square cũng set height
//    → code expect Rectangle sẽ break
```

### **I — Interface Segregation**
Nhiều interface nhỏ > 1 interface to.
```dart
// ❌ tệ
abstract class Worker { void work(); void eat(); }
class Robot implements Worker { void eat() => throw UnsupportedError(); }

// ✅ tách
abstract class Workable { void work(); }
abstract class Eatable { void eat(); }
class Human implements Workable, Eatable {...}
class Robot implements Workable {...}
```

### **D — Dependency Inversion**
High-level module không phụ thuộc low-level module, cả 2 phụ thuộc abstraction.
```dart
// ❌ depend vào implementation
class LoginBloc {
  final FirebaseAuth auth = FirebaseAuth.instance;
}

// ✅ depend vào abstraction
class LoginBloc {
  final AuthRepository auth;
  LoginBloc(this.auth);
}
// → đổi sang Supabase chỉ cần swap implementation
```

**Trả lời phỏng vấn ngắn gọn:**
> *"SOLID là bộ 5 nguyên tắc giúp code dễ maintain, test, mở rộng. Trong project em áp dụng rõ nhất là **S** (tách data/domain/presentation), **D** (Bloc depend interface AuthRepository, test mock dễ), và **O** (thêm payment method chỉ implement interface)."*

---
---

# PHẦN 2 — CÂU HỎI MID-LEVEL

## A. Dart nâng cao

### A1. `const`, `final`, `var` khác nhau?
- `const`: compile-time constant, immutable
- `final`: runtime constant, gán 1 lần
- `var`: mutable, type inferred
- **Bẫy**: `const` list không thể add; `final` list `[]` vẫn add được

### A2. `late` dùng khi nào? Rủi ro?
- Defer khởi tạo → dùng khi chắc chắn có giá trị trước khi đọc
- `late final` = lazy init, chỉ tính 1 lần khi đọc lần đầu
- **Rủi ro**: access trước khi gán → `LateInitializationError`

### A3. Factory constructor khác gì constructor thường?
- Constructor thường **luôn tạo instance mới**
- Factory **có thể trả instance cũ** (cache), hoặc trả subclass
- Ví dụ: Singleton, `Logger()` cached, `Uri.parse()` trả subclass khác nhau

### A4. `extends` vs `implements` vs `with` vs `on`?
- `extends`: kế thừa class (chỉ 1), dùng lại code
- `implements`: implement interface (nhiều), bắt buộc override tất cả
- `with`: mixin, share behavior ngang hàng
- `on`: constraint mixin — mixin chỉ dùng được với class có base nhất định

### A5. Null safety — `?`, `!`, `??`, `??=`, `?.` khác gì?
- `T?`: nullable type
- `!`: force non-null (nguy hiểm)
- `??`: default nếu null (`name ?? 'Guest'`)
- `??=`: assign if null (`list ??= []`)
- `?.`: null-safe access (`user?.name`)

### A6. Generic và covariance trong Dart?
- `List<Animal> = List<Dog>` ❌ — List invariant
- Muốn accept subtype → dùng `covariant` keyword
- Thường gặp khi override method với type hẹp hơn

### A7. Extension method là gì, khi nào KHÔNG nên dùng?
- Thêm method cho class có sẵn mà không cần subclass
- **Không nên**: shadow method cũ (confusing), extension quá nhiều gây khó đọc
```dart
extension StringX on String {
  bool get isValidEmail => RegExp(r'^[^@]+@[^@]+').hasMatch(this);
}
```

### A8. Sealed class (Dart 3) giải quyết vấn đề gì?
- Exhaustive pattern matching với `switch`
- Compiler báo lỗi nếu thiếu case
- Thay thế `abstract class + subclass` pattern cho Event/State Bloc

---

## B. Flutter internals

### B1. Widget, Element, RenderObject khác nhau ra sao?
- **Widget**: immutable blueprint, rẻ tạo/huỷ
- **Element**: mutable, giữ state, link giữa widget và render object
- **RenderObject**: object thật sự layout + paint, đắt khởi tạo
- → tách để: widget rebuild nhiều không tốn kém, render object reuse

### B2. Flutter render 1 frame thế nào?
Pipeline: **Build → Layout → Paint → Composite → Raster → GPU**
- Build: rebuild widget tree bị dirty
- Layout: mỗi RenderObject tính size/position
- Paint: vẽ lên layer
- Composite: ghép layer
- Raster: chuyển sang GPU
- Target: **16ms/frame** cho 60fps

### B3. Key để làm gì? Khi nào bắt buộc?
- Giúp Flutter **match widget cũ và mới** khi rebuild
- Bắt buộc khi: list có thể reorder/add/remove ở giữa, state cần preserve
- `ValueKey`, `ObjectKey`, `GlobalKey` (đắt, dùng ít)
```dart
ListView(children: items.map((i) => ItemWidget(item: i, key: ValueKey(i.id))).toList())
```

### B4. `InheritedWidget` hoạt động thế nào?
- Provide data xuống descendant tree, O(1) lookup
- `context.dependOnInheritedWidgetOfExactType<T>()` → subscribe + rebuild khi data đổi
- Nền tảng của Provider, MediaQuery, Theme

### B5. `StatefulWidget` và `State` — tại sao phải tách?
- Widget immutable → rẻ, có thể rebuild liên tục
- State giữ dữ liệu mutable, tồn tại xuyên suốt widget lifecycle
- Khi parent rebuild tạo widget mới, State cũ vẫn được tái dùng

### B6. `BuildContext.mounted` giải quyết vấn đề gì?
- Check widget còn trong tree không sau `await`
- Tránh lỗi `setState after dispose`

### B7. `RepaintBoundary` dùng khi nào?
- Tách subtree thành layer riêng để không repaint lại khi parent repaint
- Dùng khi: animation phức tạp, chart, video thumbnail trong list

---

## C. State management (sâu)

### C1. Bloc vs Cubit vs Riverpod vs GetX — chọn gì?
- **Bloc**: event-driven, predictable, log/replay — project lớn
- **Cubit**: Bloc simplified, không có Event — logic đơn giản
- **Riverpod**: compile-time safe, no BuildContext dependency
- **GetX**: all-in-one (DI + nav + state) — dễ học nhưng gây lock-in

### C2. Làm sao test 1 Bloc?
```dart
blocTest<AuthBloc, AuthState>(
  'emits [Loading, Success] when sign in ok',
  build: () => AuthBloc(mockRepo),
  act: (bloc) => bloc.add(SignInRequested('a', 'b')),
  expect: () => [AuthLoading(), isA<AuthSuccess>()],
);
```

### C3. Khi nào KHÔNG nên dùng Bloc?
- Form đơn giản: `TextEditingController` + setState đủ
- Animation state: `AnimationController`
- Over-engineer cho feature nhỏ

### C4. Xử lý side-effect với Bloc?
- **`BlocListener`** → side-effect
- **`BlocBuilder`** → rebuild UI
- **`BlocConsumer`** → cả 2
- Đừng `Navigator.push` trong bloc — bloc không được biết về UI

### C5. Share state giữa 2 bloc?
- Cách 1: 1 bloc listen bloc kia (`BlocA.stream.listen`)
- Cách 2: Shared repository — 2 bloc cùng inject repository
- **Cách 2 tốt hơn** vì bloc độc lập, dễ test

---

## D. Performance

### D1. App đang lag, debug thế nào?
1. DevTools → Performance → bật "Track widget builds"
2. Xem frame nào > 16ms
3. Tìm widget rebuild nhiều
4. Check "Jank" trong Timeline

### D2. Vì sao dùng `const` widget lại nhanh hơn?
- Flutter cache instance, không rebuild
- `oldWidget == newWidget` (tham chiếu) → skip rebuild nhánh

### D3. `ListView` vs `.builder` vs `.separated`?
- `ListView`: render tất cả children 1 lần — list ngắn
- `.builder`: lazy, chỉ render item visible — list dài, infinite
- `.separated`: giống builder + separator

### D4. Scroll mượt **10.000 item** thế nào?
- `ListView.builder` bắt buộc
- `itemExtent`: cùng chiều cao → tăng tốc layout
- `const` cho item widget
- `cacheExtent`: tinh chỉnh pre-render offscreen
- Pagination thay vì load all

### D5. Khi nào dùng `Isolate`?
- Task CPU-heavy **đồng bộ** nặng: parse JSON 10MB, decrypt, image processing
- **Không** dùng cho I/O (đã async sẵn)
- `compute(expensiveFn, data)` = shortcut tạo isolate 1 lần

### D6. Memory leak trong Flutter do đâu?
- Không `dispose()` controller
- Không `cancel()` StreamSubscription
- Closure giữ reference tới context/widget
- Ảnh không dùng `cacheWidth/cacheHeight`

### D7. Debug vs Release khác gì về performance?
- Debug: JIT, dev tool hook, hot reload → chậm 2-5x
- Release: **AOT compile**, tree-shake, obfuscate → performance thật
- **Luôn test perf trên release build**

---

## E. Async & Concurrency

### E1. Event loop trong Dart?
- 2 queue: **Microtask queue** (ưu tiên cao) và **Event queue**
- Main isolate chạy 1 task mỗi lần
- `Future.microtask` → microtask queue; timer/IO → event queue

### E2. `Future.wait` vs chuỗi `await`?
```dart
await Future.wait([a(), b(), c()]); // song song
for (final f in [a, b, c]) await f(); // tuần tự, chậm
```

### E3. `async/await` và `.then()` khác gì?
- Chức năng như nhau, `async/await` dễ đọc hơn
- `.then()` hữu dụng khi chain transform không cần sync
- Với try-catch, `async/await` sạch hơn

### E4. Quên `cancel()` StreamSubscription có sao?
- Memory leak
- Callback vẫn gọi dù widget đã dispose → crash
- Luôn cancel trong `dispose()`

### E5. `BroadcastStream` vs `SingleSubscriptionStream`?
- Single: chỉ 1 listener, replay từ đầu
- Broadcast: nhiều listener, không replay cho listener mới

---

## F. Testing

### F1. 3 loại test trong Flutter?
- **Unit test**: 1 function/class — nhanh, Dart VM
- **Widget test**: 1 widget, không cần emulator — `pumpWidget`, `find`, `tap`
- **Integration test**: chạy app thật trên device, E2E — chậm

### F2. Test Bloc có side-effect gọi API?
- Mock repository bằng `mocktail` / `mockito`
```dart
when(() => repo.signIn(any(), any())).thenAnswer((_) async => fakeUser);
```

### F3. Test widget có dependency?
```dart
await tester.pumpWidget(
  BlocProvider.value(value: mockBloc, child: MaterialApp(home: LoginPage())),
);
```

### F4. Golden test là gì?
- Snapshot UI thành ảnh, test sau so pixel với ảnh gốc
- Phát hiện UI regression
- Bẫy: font khác giữa máy → fix font explicit

### F5. Code coverage bao nhiêu là đủ?
- **80% logic quan trọng** là tốt
- Domain/business logic: >90%
- UI: 50-70%
- Đừng test getter/setter đơn giản

---

## G. Architecture & Design

### G1. Clean Architecture có những layer nào?
- **Presentation** (UI + Bloc/Cubit)
- **Domain** (Entity + UseCase + Repository interface) — pure Dart
- **Data** (Repository impl + DataSource + Model/DTO)
- Flow: UI → Bloc → UseCase → Repository (interface) → Data

### G2. Tại sao cần UseCase?
- UseCase chứa **business logic** spanning nhiều repository
- Ví dụ: `CheckoutUseCase` = validate cart + call payment + update order + notify
- Feature đơn giản, gọi thẳng repository cũng OK

### G3. DTO vs Entity?
- **DTO/Model** (data layer): map API response, có `fromJson`/`toJson`
- **Entity** (domain layer): business object, không biết JSON
- Repository chuyển DTO → Entity trước khi trả domain

### G4. Feature-first vs Layer-first?
- **Feature-first**: `features/auth/`, `features/finance/` — mỗi feature đầy đủ layer
- **Layer-first**: `models/`, `services/`, `screens/` — gom theo layer
- **Feature-first** tốt hơn cho project lớn

### G5. Xử lý error trong Clean Architecture?
- Data layer throw `Exception`
- Repository catch → trả `Either<Failure, T>` (dartz) hoặc `Result<T>` sealed class
- Bloc match trên Result → emit state tương ứng
- **Không** throw xuyên layer

### G6. Modular architecture — khi nào cần?
- Project **rất lớn**: tách package (`common_packages`, `feature_auth`)
- Lợi: build nhanh hơn, team làm song song
- Hại: setup phức tạp

---

## H. Native integration

### H1. Platform Channel — MethodChannel vs EventChannel?
- Cầu nối Flutter ↔ native (Kotlin/Swift)
- **MethodChannel**: gọi 1 chiều, trả 1 giá trị (RPC)
- **EventChannel**: stream liên tục từ native → Flutter (sensor, location)
- **BasicMessageChannel**: hai chiều liên tục

### H2. Khi nào phải viết native code?
- Flutter plugin chưa hỗ trợ
- Performance critical (camera frame, bluetooth)
- Integrate SDK native (banking, hãng riêng)

### H3. `pigeon` package giải quyết gì?
- Generate code platform channel **type-safe**
- Tránh typo, đổi API là compile error ngay

### H4. FFI là gì?
- Foreign Function Interface — gọi thẳng C/C++ từ Dart
- Nhanh hơn platform channel
- Dùng cho: crypto, image processing, library C sẵn có

### H5. Plugin vs Package?
- **Package**: pure Dart (logic, utility)
- **Plugin**: có code native (Android + iOS + ...)

---

## I. CI/CD & Release

### I1. Flavor trong Flutter?
- Build cùng source nhưng config khác (dev/staging/prod)
- Android: `productFlavors` trong `build.gradle`
- iOS: Xcode Schemes + xcconfig
- Run: `flutter run --flavor dev -t lib/main_dev.dart`

### I2. Obfuscate app khi release?
```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```
- Giữ file symbol để decode stack trace từ Crashlytics

### I3. Code signing iOS/Android khác nhau?
- **Android**: `keystore.jks` + `key.properties` → `build.gradle`
- **iOS**: Apple Developer cert + provisioning profile → Xcode / fastlane match
- Keystore/cert phải được **backup an toàn**

### I4. CI/CD nào cho Flutter?
- GitHub Actions, Codemagic, Bitrise, Fastlane
- Workflow: lint → test → build → deploy (Firebase App Distribution / TestFlight / Play Console)

### I5. Rollout feature từ từ?
- Feature flag (Firebase Remote Config, LaunchDarkly)
- A/B test qua remote config
- Play Console Staged Rollout: 1% → 10% → 50% → 100%

---

## J. Security

### J1. App bị decompile được không?
- Android APK decompile dễ (dex2jar, jadx)
- iOS IPA khó hơn nhưng vẫn làm được
- **Bảo vệ**: obfuscate, không hardcode secret, validate server-side, SSL pinning

### J2. Lưu token thế nào cho an toàn?
- **KHÔNG** dùng `SharedPreferences`
- Dùng `flutter_secure_storage` → iOS Keychain, Android Keystore
- Access token ngắn hạn, refresh token dài hạn

### J3. SSL Pinning là gì?
- App chỉ accept cert public key cụ thể của server
- Chống MITM (Charles, mitmproxy)
- Dùng `dio` + `http_certificate_pinning`

### J4. Bảo vệ API key trong code?
- Sự thật: **không thể** hoàn toàn
- Giải pháp:
  - Restrict key theo package name + SHA-1 (Firebase/Google Cloud)
  - Rotate key định kỳ
  - Proxy qua backend cho key nhạy cảm

### J5. Deeplink bảo mật?
- Android: App Links (verify qua `assetlinks.json`)
- iOS: Universal Links (verify qua `apple-app-site-association`)
- Luôn validate param, không trust blindly

---

## K. Tình huống thực tế

### K1. App crash production, xử lý thế nào?
- Setup Crashlytics từ đầu → có stack trace
- Repro local với stack trace
- Hotfix branch → release nhanh
- **Post-mortem**: viết lý do, ngăn ngừa — không tìm người có lỗi

### K2. Build iOS fail sau khi thêm plugin?
1. `flutter clean`
2. `cd ios && pod deintegrate && pod install --repo-update`
3. Đóng Xcode, xoá `~/Library/Developer/Xcode/DerivedData`
4. Check min iOS version plugin có phù hợp Podfile không
5. M1 Mac: check arch `excluded_architectures`

### K3. Team 5 dev, đảm bảo code quality?
- Lint strict (analyzer_options.yaml) — block CI nếu fail
- Code review: checklist (test? gitignore? secret leak?)
- Convention: naming, folder structure có guideline
- Pre-commit hook: format + analyze

### K4. App dùng battery nhiều, tối ưu?
- Giảm polling → push notification / websocket
- Location: chỉ khi cần, accuracy phù hợp
- Background task: giới hạn thời gian (WorkManager / BGTaskScheduler)
- Tránh infinite animation khi không nhìn thấy

### K5. Cold start chậm, tối ưu?
- Splash screen native (Android 12+ SplashScreen API, iOS LaunchScreen)
- Lazy init service trong `get_it`
- Deferred components (Android dynamic feature)
- Precompile: `flutter build --tree-shake-icons`

### K6. Xử lý offline mode?
- Local DB (Isar, Drift, Hive) cache API response
- Queue mutation khi offline → sync khi online
- UI state: offline/syncing/synced
- `connectivity_plus` để detect network change

### K7. Khi nào dùng `dynamic`?
- **Hầu như không**. Type `Object?` an toàn hơn
- Chỉ dùng khi: parse JSON trung gian, interop platform channel

---

## L. Coding exercise

Chuẩn bị viết nhanh các bài sau trong 10-15 phút:

1. **Infinite scroll list** với pagination (ListView.builder + ScrollController)
2. **Debounced search**: typing 500ms mới call API (rxdart hoặc Timer)
3. **Custom painter**: vẽ progress circle / chart đơn giản
4. **Bloc flow login** đầy đủ (event, state, bloc, repository, UI)
5. **Offline-first TODO app** (local DB + sync)
6. **Animation nâng cao**: hero transition, implicit animation
7. **Dark mode toggle** lưu persistent (SharedPreferences + Bloc)
8. **Implement Timer** (Bloc + Stream.periodic)
9. **Parse JSON lồng nhau**: viết `fromJson`/`toJson` cho model có list con
10. **State restoration**: app bị kill ở background, mở lại vẫn ở screen cũ

---

## M. Câu mở rộng khó

Những câu này thường hỏi senior (3-5 năm), mid-level biết thì ấn tượng mạnh:

- **M1.** Flutter so với React Native / native — khi nào chọn cái nào?
- **M2.** Impeller engine (thay Skia) cải tiến gì?
- **M3.** Tree shaking hoạt động thế nào với Dart?
- **M4.** `setState` trong `InheritedWidget` rebuild widget nào?
- **M5.** Viết custom `RenderObject` cần gì?
- **M6.** Làm sao implement gesture custom?
- **M7.** State restoration của Flutter vs Android `onSaveInstanceState`?
- **M8.** `Ticker` vs `Timer` khác nhau thế nào?
- **M9.** Build system Flutter: Dart → APK có bao nhiêu step?
- **M10.** Khi nào có ý nghĩa viết app Flutter thuần (không plugin)?

---

## N. Custom Widget

### N1. Khi nào nên tạo custom widget?
- UI element lặp lại ≥ 3 lần → tách thành widget
- Cần design system riêng (button, input, card)
- Cần behavior không có sẵn trong framework

### N2. 3 cách tạo custom widget (từ dễ → khó)

**Cách 1 — Composition** (dùng nhất, 90% trường hợp):
```dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      minimumSize: const Size(double.infinity, 48),
    ),
    onPressed: loading ? null : onPressed,
    child: loading
      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
      : Text(label),
  );
}
```

**Cách 2 — CustomPainter** (vẽ tự do: chart, progress ring, watermark):
```dart
class CircleProgressPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;

    // vòng nền
    canvas.drawCircle(center, radius, Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8);

    // vòng progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,                  // bắt đầu từ 12h
      2 * pi * progress,        // quét theo progress
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter old) =>
      old.progress != progress || old.color != color;
}

// Dùng:
CustomPaint(
  size: const Size(100, 100),
  painter: CircleProgressPainter(progress: 0.7, color: Colors.blue),
)
```

**Cách 3 — Custom RenderObject** (hiếm, chỉ khi cần layout đặc biệt như flow layout, waterfall):
- Subclass `RenderBox` hoặc `MultiChildRenderObjectWidget`
- Override `performLayout`, `paint`, `hitTest`
- Interview hiếm hỏi sâu, biết concept là đủ

### N3. Làm sao widget responsive theo kích thước màn hình?
- **`LayoutBuilder`**: biết constraints từ parent
- **`MediaQuery`**: biết kích thước màn hình + orientation
- **`Flexible` / `Expanded`**: phân phối space trong Row/Column
```dart
LayoutBuilder(builder: (ctx, constraints) {
  if (constraints.maxWidth > 600) return TabletLayout();
  return MobileLayout();
});
```

### N4. Best practice cho design system?
- Centralize theme: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`
- Theme extension (Flutter 3+) cho color/size custom
- Prefix convention: `DSButton`, `DSTextField`, `DSCard` (DS = Design System)
- Mỗi component nhận prop rõ ràng, không phụ thuộc BuildContext cho logic

### N5. Animation trong custom widget?
- **Implicit animation** (dễ): `AnimatedContainer`, `AnimatedOpacity`, `TweenAnimationBuilder`
- **Explicit animation** (control rõ): `AnimationController` + `AnimatedBuilder`
- **Hero** cho transition giữa screen (shared element)
```dart
class FadeBox extends StatefulWidget {...}

class _FadeBoxState extends State<FadeBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _c,
    child: const Text('Hello'),
  );

  @override
  void dispose() { _c.dispose(); super.dispose(); }
}
```

### N6. `SingleTickerProviderStateMixin` vs `TickerProviderStateMixin`?
- Single: 1 AnimationController
- Multi: nhiều AnimationController — tốn resource hơn một chút, chỉ dùng khi cần

---

## O. Web Service & API (REST, JSON, Dio, Retrofit, SOAP/XML)

### O1. REST API — nguyên tắc cốt lõi
- **Stateless**: mỗi request tự đủ, server không nhớ client
- **Resource-based**: URL là danh từ (`/users/1` không phải `/getUser?id=1`)
- **HTTP verbs**: GET (đọc), POST (tạo), PUT (replace toàn bộ), PATCH (update 1 phần), DELETE
- **Status code**: 2xx OK, 3xx redirect, 4xx client error, 5xx server error

**Status code hay hỏi:**
| Code | Ý nghĩa |
|---|---|
| 200 | OK |
| 201 | Created |
| 204 | No Content (DELETE thành công) |
| 400 | Bad Request (sai format) |
| 401 | Unauthorized (chưa login / token sai) |
| 403 | Forbidden (đã login nhưng không có quyền) |
| 404 | Not Found |
| 409 | Conflict (vd: email đã tồn tại) |
| 422 | Unprocessable (validation fail) |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

### O2. Parse JSON — 2 cách

**Manual** (dự án nhỏ):
```dart
class User {
  final int id;
  final String name;
  final String? avatar;
  User({required this.id, required this.name, this.avatar});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatar != null) 'avatar': avatar,
  };
}
```

**json_serializable** (dự án lớn, dùng code generation):
```dart
@JsonSerializable()
class User {
  final int id;
  final String name;
  @JsonKey(defaultValue: null) final String? avatar;

  User({required this.id, required this.name, this.avatar});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```
Chạy `dart run build_runner build` để generate file `.g.dart`.

**Bẫy hay gặp:**
- API trả `null` cho field expect non-null → crash. Luôn dùng `?` nếu không chắc
- Field `int` có thể là `double` đôi khi → dùng `num` rồi cast
- Nested list: `List<Item>.from(json['items'].map((e) => Item.fromJson(e)))`

### O3. Dio vs http package?

| | `http` | `dio` |
|---|---|---|
| Basic request | ✅ | ✅ |
| Interceptor | ❌ | ✅ |
| Cancel request | ❌ | ✅ |
| Progress upload/download | ❌ | ✅ |
| FormData / multipart | Khó | ✅ |
| Transform request/response | ❌ | ✅ |
| Timeout config | Manual | Built-in |

**Trả lời phỏng vấn**: *"Project production em dùng Dio vì có interceptor (auth + logging + retry), support cancel request khi navigate, multipart upload file tiện. http chỉ đủ cho demo."*

### O4. Dio setup production-ready
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com/v1',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Content-Type': 'application/json'},
));

dio.interceptors.addAll([
  // Auth — gắn token mọi request
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await secureStorage.read(key: 'access_token');
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
    onError: (error, handler) async {
      // 401 → refresh token → retry
      if (error.response?.statusCode == 401) {
        final newToken = await refreshToken();
        if (newToken != null) {
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retry = await dio.fetch(error.requestOptions);
          return handler.resolve(retry);
        }
      }
      handler.next(error);
    },
  ),
  // Logging (chỉ debug)
  if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
]);
```

### O5. Retrofit là gì?
Package generate code API client từ annotation (giống Retrofit Android). Dùng Dio bên dưới.

```dart
@RestApi(baseUrl: 'https://api.example.com/v1')
abstract class UserApi {
  factory UserApi(Dio dio) = _UserApi;

  @GET('/users/{id}')
  Future<User> getUser(@Path('id') int id);

  @GET('/users')
  Future<List<User>> listUsers(@Query('page') int page);

  @POST('/users')
  Future<User> createUser(@Body() User user);

  @MultiPart()
  @POST('/users/{id}/avatar')
  Future<String> uploadAvatar(
    @Path('id') int id,
    @Part() File file,
  );
}
```
Chạy build_runner → tự generate class `_UserApi`.

**Lợi**: type-safe, ít boilerplate, dễ read.
**Hại**: thêm bước codegen, phải chạy lại khi đổi API.

### O6. SOAP/XML xử lý thế nào?
Hiếm dùng trong mobile hiện đại — thường là legacy backend (banking, telecom).

```dart
// POST XML envelope
final envelope = '''<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetUser xmlns="http://example.com/">
      <id>42</id>
    </GetUser>
  </soap:Body>
</soap:Envelope>''';

final response = await dio.post(
  'https://legacy.example.com/service.asmx',
  data: envelope,
  options: Options(headers: {'Content-Type': 'text/xml; charset=utf-8'}),
);

// Parse bằng package `xml`
import 'package:xml/xml.dart';
final doc = XmlDocument.parse(response.data);
final name = doc.findAllElements('Name').first.innerText;
```

**Interview tip**: *"Em chưa dùng nhiều SOAP vì backend em làm đều REST. Nhưng em biết concept là XML-based RPC, response envelope format, parse bằng package `xml` là được."*

### O7. Xử lý error network thế nào?
```dart
Future<Result<User>> fetchUser(int id) async {
  try {
    final user = await api.getUser(id);
    return Result.success(user);
  } on DioException catch (e) {
    return Result.failure(_mapDioError(e));
  } catch (_) {
    return Result.failure(Failure.unknown());
  }
}

Failure _mapDioError(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.receiveTimeout => Failure.timeout(),
  DioExceptionType.connectionError => Failure.noInternet(),
  DioExceptionType.badResponse => switch (e.response?.statusCode) {
    401 => Failure.unauthorized(),
    404 => Failure.notFound(),
    _ => Failure.server(e.response?.data?['message']),
  },
  DioExceptionType.cancel => Failure.cancelled(),
  _ => Failure.unknown(),
};
```

### O8. Cancel request khi user rời màn hình?
```dart
class _ProductPageState extends State<ProductPage> {
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    api.getProduct(widget.id, cancelToken: _cancelToken);
  }

  @override
  void dispose() {
    _cancelToken.cancel('User left page');
    super.dispose();
  }
}
```

### O9. Upload progress?
```dart
await dio.post(
  '/upload',
  data: FormData.fromMap({'file': await MultipartFile.fromFile(path)}),
  onSendProgress: (sent, total) {
    final percent = (sent / total * 100).toStringAsFixed(1);
    setState(() => _progress = percent);
  },
);
```

---

## P. SQL & SQLite

### P1. Local DB trong Flutter dùng gì?
| Package | Loại | Dùng khi |
|---|---|---|
| `sqflite` | Raw SQL | Dự án nhỏ, cần full control |
| `drift` (moor) | ORM + type-safe + reactive | Dự án vừa/lớn, muốn compile-time safety |
| `floor` | ORM theo kiểu Android Room | Team từ Android quen Room |
| `isar` | NoSQL, rất nhanh | Dự án cần performance cao, no-SQL |
| `hive` | Key-value, đơn giản | Cache đơn giản, settings |
| `shared_preferences` | Key-value nhỏ | Chỉ config đơn giản (bool, string ngắn) |

### P2. Setup sqflite cơ bản
```dart
Future<Database> _openDb() async {
  final path = join(await getDatabasesPath(), 'app.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date INTEGER NOT NULL,
          note TEXT
        )
      ''');
      await db.execute('CREATE INDEX idx_expenses_date ON expenses(date DESC)');
    },
    onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) await db.execute('ALTER TABLE expenses ADD COLUMN tags TEXT');
    },
  );
}
```

### P3. SQL cơ bản cần thuộc

**CRUD:**
```sql
-- CREATE
INSERT INTO expenses (amount, category, date) VALUES (100.5, 'food', 1714000000);

-- READ
SELECT * FROM expenses WHERE category = 'food' ORDER BY date DESC LIMIT 10 OFFSET 0;

-- UPDATE
UPDATE expenses SET amount = 150 WHERE id = 1;

-- DELETE
DELETE FROM expenses WHERE date < 1700000000;
```

**JOIN** (khi có nhiều table):
```sql
SELECT e.id, e.amount, c.name AS category_name
FROM expenses e
INNER JOIN categories c ON e.category_id = c.id
WHERE e.date BETWEEN ? AND ?;
```
- **INNER JOIN**: chỉ lấy row có match ở cả 2 table
- **LEFT JOIN**: lấy toàn bộ table trái + match phải (null nếu không có)
- **RIGHT JOIN** / **FULL OUTER JOIN**: ngược lại / cả 2

**Aggregation:**
```sql
SELECT category, SUM(amount) AS total, COUNT(*) AS count
FROM expenses
WHERE date > ?
GROUP BY category
HAVING total > 100
ORDER BY total DESC;
```

### P4. Index — khi nào cần, khi nào KHÔNG?
**Dùng**: cột hay filter/sort (`WHERE`, `ORDER BY`, `JOIN ON`). Ví dụ: `date`, `user_id`, `category`.

**KHÔNG dùng**:
- Table nhỏ (<1000 row) — không đáng
- Cột ít unique (vd: `is_deleted BOOLEAN`)
- Mọi cột — làm chậm INSERT/UPDATE, tốn space

```sql
CREATE INDEX idx_expenses_user_date ON expenses(user_id, date DESC);
-- Composite index: tối ưu query WHERE user_id=? ORDER BY date DESC
```

**Lưu ý thứ tự composite index**: cột equality trước, range/sort sau.

### P5. Transaction — đảm bảo atomic
```dart
await db.transaction((txn) async {
  final orderId = await txn.insert('orders', {'total': 500});
  for (final item in items) {
    await txn.insert('order_items', {
      'order_id': orderId,
      'product_id': item.id,
      'quantity': item.qty,
    });
  }
  // Nếu có lỗi bất kỳ → rollback tất cả, orders + order_items đều không tạo
});
```

### P6. Migration khi đổi schema?
```dart
openDatabase(
  path,
  version: 3,  // bump version
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE expenses ADD COLUMN note TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('CREATE TABLE tags (id INTEGER PRIMARY KEY, name TEXT)');
    }
  },
);
```
**SQLite hạn chế**: không `DROP COLUMN` trực tiếp (phải recreate table + copy data).

### P7. Normalization — 1NF, 2NF, 3NF
- **1NF**: mỗi cell 1 giá trị nguyên tử (không `tags: "red,blue,green"` — phải tách table)
- **2NF**: 1NF + không partial dependency (không cột phụ thuộc 1 phần composite key)
- **3NF**: 2NF + không transitive dependency (không cột phụ thuộc cột non-key khác)

**Khi nào denormalize (chấp nhận duplicate)?**
- Read nhiều hơn write rất nhiều
- Cần performance query cao (tránh JOIN)
- Data analytics / reporting

**Trả lời interview**: *"Em normalize tới 3NF cho data core, nhưng denormalize (vd: cache `user_name` vào bảng `post`) cho case read-heavy để tránh JOIN mỗi lần load feed."*

### P8. Query chậm → tối ưu?
1. `EXPLAIN QUERY PLAN SELECT ...` xem SQLite làm gì
2. Add index vào cột filter/sort
3. Tránh `SELECT *` — chỉ lấy cột cần
4. Pagination: `LIMIT / OFFSET` cho page nhỏ, **keyset pagination** cho lớn:
   ```sql
   -- Thay vì OFFSET 10000 (chậm)
   SELECT * FROM posts WHERE id < ? ORDER BY id DESC LIMIT 20;
   ```
5. Dùng `IN (?, ?, ?)` thay cho nhiều query riêng

### P9. SQL injection — có xảy ra trong Flutter không?
**Có** nếu viết raw query concat string:
```dart
// ❌ CỰC KỲ NGUY HIỂM
db.rawQuery("SELECT * FROM users WHERE name = '$userInput'");

// ✅ ĐÚNG: dùng placeholder
db.rawQuery("SELECT * FROM users WHERE name = ?", [userInput]);
// Hoặc
db.query('users', where: 'name = ?', whereArgs: [userInput]);
```

### P10. SQLite vs SharedPreferences vs Hive — chọn cái nào?
- **SharedPreferences**: <10 key-value đơn giản (dark mode, language)
- **Hive**: object nhỏ cache, không query phức tạp
- **Isar**: object nhiều, query phức tạp, **cần tốc độ**
- **SQLite**: dữ liệu quan hệ, JOIN, aggregate, query SQL

---

## Q. Git workflow

### Q1. Flow cơ bản hàng ngày
```bash
git clone <url>
git checkout -b feature/login
# ... sửa code
git add src/login_page.dart
git commit -m "feat(auth): add login screen with email validation"
git push -u origin feature/login
# Tạo PR trên GitHub → reviewer xem → merge
```

### Q2. Merge vs Rebase

| | Merge | Rebase |
|---|---|---|
| History | Giữ nguyên, có commit merge | Linear, viết lại history |
| An toàn | An toàn | Nguy hiểm nếu branch đã share |
| Dùng khi | Integrate feature vào main | Update feature branch với main mới nhất |

**Rule phổ biến**: *"Rebase branch riêng của mình trước khi push. Merge khi tích hợp vào shared branch (main/develop)."*

```bash
# Rebase feature branch với master
git checkout feature/login
git fetch origin
git rebase origin/master
# Fix conflict nếu có → git add → git rebase --continue
git push --force-with-lease  # safer than --force
```

### Q3. Conflict — xử lý thế nào?
```bash
git pull origin master   # hoặc git rebase
# File có conflict sẽ có marker:
#   <<<<<<< HEAD
#   code của mình
#   =======
#   code từ branch kia
#   >>>>>>> origin/master
# Sửa file, giữ phần đúng, xóa marker
git add <file>
git commit                # nếu đang merge
git rebase --continue     # nếu đang rebase
```
**Tip**: dùng VS Code / IDE có UI để resolve conflict dễ hơn.

### Q4. Branching strategy phổ biến

**Git Flow** (formal, phù hợp release theo version):
```
main ← release/* ← develop ← feature/*
       hotfix/* → main + develop
```

**GitHub Flow** (đơn giản, CI/CD continuous):
```
main ← feature/*
```
Mỗi PR = deploy được ngay. Phù hợp web app, SaaS.

**Trunk-based** (Google, Facebook):
- Chỉ main branch, dùng feature flag ẩn feature chưa sẵn sàng
- Commit trực tiếp lên main, không có long-lived branch
- Yêu cầu test tự động cực tốt

**Trả lời interview**: *"Team em dùng GitHub Flow vì release liên tục. Git Flow hợp cho mobile app release theo version, còn Trunk-based cần infrastructure test rất mạnh."*

### Q5. Lệnh Git ít dùng nhưng hay bị hỏi

| Lệnh | Dùng khi |
|---|---|
| `git stash` / `git stash pop` | Tạm lưu working changes để checkout branch khác |
| `git cherry-pick <sha>` | Lấy 1 commit từ branch khác (hotfix) |
| `git reset --soft HEAD~1` | Hoàn tác commit cuối, giữ changes staged |
| `git reset --hard HEAD~1` | Hoàn tác commit + xóa changes (⚠️ mất work) |
| `git revert <sha>` | Tạo commit mới để undo (an toàn cho shared branch) |
| `git reflog` | Xem mọi HEAD movement — cứu khi lỡ reset --hard |
| `git log --graph --oneline --all` | Xem history dạng đồ thị |
| `git blame <file>` | Xem ai sửa dòng nào, commit nào |
| `git bisect` | Binary search để tìm commit gây bug |

### Q6. Commit message convention
**Conventional Commits** (phổ biến nhất):
```
feat(auth): add biometric login
fix(payment): prevent double charge on retry
refactor(home): extract ProductCard widget
docs(readme): update setup guide
test(bloc): add login bloc test
chore(deps): bump dio to 5.4.0
```
Type: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`.

### Q7. `.gitignore` — quan trọng với Flutter
```gitignore
# Dart/Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
build/
**/ios/Flutter/.last_build_id

# IDE
.idea/
.vscode/
*.iml

# OS
.DS_Store
Thumbs.db

# Secrets (QUAN TRỌNG)
**/google-services.json
**/GoogleService-Info.plist
**/firebase_options.dart
**/.env
**/key.properties
**/*.jks
**/*.keystore
```

### Q8. Lỡ commit secret → xử lý?
**Chưa push**:
```bash
git reset --soft HEAD~1   # bỏ commit, giữ changes
# Thêm file vào .gitignore
# Commit lại
```

**Đã push** (nghiêm trọng):
```bash
# Cách 1: git filter-repo (khuyến nghị)
git filter-repo --invert-paths --path development/lib/config/app_config.dart
git push --force

# Cách 2: BFG Repo-Cleaner (dễ dùng)
bfg --delete-files app_config.dart
```
**Quan trọng**: rotate secret ngay — coi như đã lộ, kể cả khi đã xóa khỏi history.

### Q9. Pull Request / Code Review workflow
1. Tạo feature branch từ main
2. Commit nhỏ, message rõ ràng
3. Push + tạo PR với description đầy đủ (mục đích, screenshot, test plan)
4. CI chạy lint + test → đợi pass
5. Reviewer comment → sửa theo feedback → push update
6. Approve → **squash merge** (prefer) cho clean history
7. Delete branch sau merge

### Q10. Tag + release?
```bash
git tag -a v1.2.3 -m "Release 1.2.3: add biometric login"
git push origin v1.2.3
# GitHub tự tạo release page từ tag
```

---

## R. MVP / MVC / MVVM

### R1. MVP (Model-View-Presenter) là gì?
Pattern tách UI và logic:
- **Model**: data + business rules
- **View**: UI dumb, chỉ hiển thị + forward user event
- **Presenter**: nhận event từ View → gọi Model → update View qua interface

```dart
// View interface
abstract class LoginView {
  void showLoading();
  void showSuccess(User user);
  void showError(String message);
}

// Presenter
class LoginPresenter {
  final LoginView view;
  final AuthRepository repo;
  LoginPresenter(this.view, this.repo);

  Future<void> login(String email, String password) async {
    view.showLoading();
    try {
      final user = await repo.signIn(email, password);
      view.showSuccess(user);
    } catch (e) {
      view.showError(e.toString());
    }
  }
}

// View (implement interface)
class LoginPage extends StatefulWidget { ... }
class _LoginPageState extends State<LoginPage> implements LoginView {
  late final _presenter = LoginPresenter(this, getIt<AuthRepository>());

  @override
  void showLoading() => setState(() => _loading = true);

  @override
  void showSuccess(User user) => Navigator.pushReplacement(...);

  @override
  void showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(...);
}
```

### R2. MVC vs MVP vs MVVM

| | Communication | Testable | Flutter fit |
|---|---|---|---|
| **MVC** | View ↔ Controller ↔ Model (cả 2 chiều) | Khó | Ít dùng |
| **MVP** | View → Presenter → Model; Presenter update View qua interface | Tốt | Android era |
| **MVVM** | View bind ViewModel qua observable (stream/listener) | Rất tốt | **Hợp Flutter** |

### R3. MVVM trong Flutter trông thế nào?
Riverpod/Provider/ChangeNotifier là implementation của MVVM:

```dart
// ViewModel
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  LoginViewModel(this._repo);

  bool loading = false;
  String? error;
  User? user;

  Future<void> login(String email, String password) async {
    loading = true; notifyListeners();
    try {
      user = await _repo.signIn(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }
}

// View tự động bind qua Consumer
Consumer<LoginViewModel>(
  builder: (_, vm, __) => vm.loading
    ? CircularProgressIndicator()
    : LoginForm(onSubmit: vm.login),
)
```

### R4. Bloc vs MVP vs MVVM — chọn gì?

- **Bloc**: variant của MVVM, giao tiếp qua Stream Event/State
- **MVVM**: giao tiếp qua observable (ChangeNotifier, Riverpod)
- **MVP**: giao tiếp qua interface callback — **cũ nhất, verbose nhất**

**Ưu thế của Bloc/MVVM trong Flutter**:
- Declarative, hợp với `StreamBuilder`/`ConsumerWidget`
- View không cần implement interface — cleaner
- Dễ test vì state là stream/object

**Khi nào MVP còn ý nghĩa?**
- Team chuyển từ Android sang, đã quen MVP
- Project legacy code Android, port Flutter
- App simple, không cần state management phức tạp

### R5. Trả lời phỏng vấn tổng hợp
> *"MVP/MVC là pattern truyền thống tách UI và logic, nhưng trong Flutter hiện đại thường dùng biến thể MVVM qua Bloc hoặc Riverpod vì:
> (1) Bind View ↔ ViewModel tự nhiên với declarative UI của Flutter,
> (2) Không cần View implement interface như MVP,
> (3) State là stream/object dễ test.
> Em dùng Bloc cho project chính, biết cách implement MVP nếu team cần convert code từ Android."*

### R6. Dependency Inversion trong các pattern này
Điểm chung: **View/Presenter/ViewModel không depend vào implementation**, chỉ depend vào abstraction (interface Repository). Xem lại [Phần 1 #15 — SOLID](#15-solid).

---
---

# PHẦN 3 — CHIẾN LƯỢC PHỎNG VẤN

## 🎯 Công thức trả lời chuẩn

**Định nghĩa ngắn → Ví dụ cụ thể trong project → Trade-off / khi nào KHÔNG dùng**

Interviewer thích ứng viên biết **nhược điểm** của tool mình dùng, không chỉ biết ưu điểm.

## 🎯 Dẫn bằng ví dụ thật

❌ *"Em biết Bloc"*

✅ *"Ở màn hình Finance em dùng Bloc quản lý state vì có nhiều event (add/delete/filter expense) và logic phức tạp. Khi test em mock `FinanceRepository` và verify bloc emit đúng state."*

## 🎯 Khi không biết

*"Em chưa dùng trong production nhưng em hiểu concept là X, và em sẽ học bằng cách Y"*

→ trung thực hơn là bịa. Interviewer có kinh nghiệm dễ phát hiện bịa.

## 🎯 Chủ động đào sâu

Sau khi trả lời, hỏi ngược:
*"Anh/chị muốn em đi sâu vào phần nào không?"*

→ cho thấy bạn muốn communicate, không chỉ trả bài.

## 🎯 Ôn code

Luôn chuẩn bị sẵn trong đầu code snippet cho:
- `setState` flow cơ bản
- Bloc đầy đủ (Event + State + Bloc class)
- `Future.wait`, async/await with try-catch
- `ListView.builder` + ScrollController
- DI via constructor

→ câu *"Em viết code demo thử"* rất hay gặp.

## 🎯 Chuẩn bị war stories

Chuẩn bị **1-2 tình huống khó** đã xử lý (bug tricky, perf issue, team conflict...).
Kể theo format **STAR**: Situation → Task → Action → Result.

Interviewer cực kỳ thích nghe war story, nó cho thấy experience thật.

## 🎯 Review project hiện tại

Trước phỏng vấn, review lại project đang làm. Trả lời được:
- *"Tại sao em chọn state management X (thay vì Y)?"*
- *"Tại sao em dùng architecture này?"*
- *"Khó khăn lớn nhất là gì?"*
- *"Nếu làm lại, em sẽ đổi cái gì?"* ← câu này CHẮC CHẮN bị hỏi

## 🎯 Lộ trình ôn 4 tuần

| Tuần | Focus |
|---|---|
| **1** | Phần A (Dart), B (Internals), C (State) — nền tảng |
| **2** | Phần D (Perf), E (Async), F (Test) — thực chiến |
| **3** | Phần G (Architecture), H (Native), I (CI/CD) — chuyên sâu |
| **4** | Phần J (Security), K (Tình huống), L (Coding) — tổng hợp + mock interview |

## 🎯 Checklist trước ngày phỏng vấn

- [ ] Review project hiện tại, trả lời được "tại sao" cho mọi quyết định kỹ thuật
- [ ] Chuẩn bị 1-2 war story
- [ ] Viết tay code Bloc basic, Future.wait, ListView.builder
- [ ] Ngủ đủ, uống đủ nước
- [ ] Chuẩn bị câu hỏi hỏi lại interviewer (về team, tech stack, roadmap)

---

**Chúc bạn phỏng vấn thành công!** 🚀
