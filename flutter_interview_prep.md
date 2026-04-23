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
