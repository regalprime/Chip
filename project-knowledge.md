# Pancake Work Client - Project Knowledge

## Muc luc

**Phan A: Ly thuyet Flutter (tu goc re)**

*Nen tang Dart:*
1. [A1. Dart Language Fundamentals](#a1-dart-language-fundamentals) — Null safety, cascade, extension, typedef, records, sealed classes
2. [A2. Dart Type System Nang Cao](#a2-dart-type-system-nang-cao) — Generics, covariance, type promotion, interface/base/final class
3. [A3. Dart Event Loop va Memory Model](#a3-dart-event-loop-va-memory-model) — Single-threaded event loop, microtask vs event queue, GC, closures

*Kien truc Flutter:*
4. [A4. Flutter Architecture](#a4-flutter-architecture) — Engine (C++), Framework (Dart), Bindings
5. [A5. Widget/Element/RenderObject Tree](#a5-widget-element-renderobject) — 3 cay, rebuild vs reuse
6. [A6. Widget Lifecycle](#a6-widget-lifecycle-chi-tiet) — initState, dispose, didUpdateWidget, didChangeDependencies

*Core Concepts (voi vi du du an):*
7. [A7. BuildContext](#a7-buildcontext) — read vs watch vs select, anti-patterns
8. [A8. Key System](#a8-key-system) — ValueKey, GlobalKey, UniqueKey, diff algorithm
9. [A9. InheritedWidget](#a9-inheritedwidget) — InheritedModel, AppViewScope
10. [A10. Rendering Pipeline](#a10-rendering-pipeline-chi-tiet) — Isolate, compute(), async/await
11. [A11. Stream](#a11-layout-system) — StreamController, broadcast, socket events
12. [A12. Focus va Keyboard](#a12-paint-va-compositing) — FocusNode, FocusScope, key events
13. [A13. Gesture System](#a13-gesture-system) — Arena, GestureDetector vs Listener, HitTestBehavior
14. [A14. Rendering va Layout](#a14-rendering-layout) — Constraints, BoxConstraints
15. [A15. Mixin va App Lifecycle](#a15-mixin-app-lifecycle) — TickerProvider, WidgetsBindingObserver

*Chuyen sau:*
16. [A16. Isolate va Concurrency](#a16-isolate) — (placeholder, xem A3 va A10)
17. [A17. Stream va Reactive](#a17-stream) — (placeholder, xem A11)
18. [A18. Platform Channels va FFI](#a18-platform-channels) — MethodChannel, EventChannel, FFI
19. [A19. Navigation va Routing](#a19-navigation) — Navigator 1.0 vs 2.0, declarative
20. [A20. State Management](#a20-state-management) — Nguyen ly, Provider, so sanh
21. [A21. Testing](#a21-testing) — Unit, Widget, Integration test
22. [A22. Performance](#a22-performance) — Do luong, giam rebuild, RepaintBoundary, Offstage
23. [A23. Memory Management](#a23-memory) — Leak detection, dispose pattern
24. [A24. Scheduler va Frame Timing](#a24-scheduler) — Frame phases, dirty marking, callback timing
25. [A25. Accessibility](#a25-accessibility) — Semantics tree, screen readers

*Flutter Internals (goc re):*
26. [A26. Flutter Ve Widget Nhu The Nao](#a26-flutter-ve-widget) — Tu runApp() den pixel, 6 buoc, RenderObject categories
27. [A27. Widget Tree Diffing Algorithm](#a27-diffing) — Reconciliation, canUpdate, key matching
28. [A28. Layer Tree va Compositing](#a28-layer-tree) — GPU rendering, Impeller vs Skia, RepaintBoundary
29. [A29. Layout Chi Tiet](#a29-layout) — Constraints, loi thuong gap, IntrinsicDimensions
30. [A30. Hot Reload va Hot Restart](#a30-hot-reload) — Cach Flutter cap nhat code tai runtime
31. [A31. Dart Compilation](#a31-compilation) — JIT vs AOT, debug vs release mode

**Phan B: Kien thuc du an**
1. [Tong quan du an](#1-tong-quan-du-an)
2. [Cau truc thu muc](#2-cau-truc-thu-muc)
3. [Flavor va Environment](#3-flavor-va-environment)
4. [Firebase](#4-firebase)
5. [Ket noi API (SDK)](#5-ket-noi-api-sdk)
6. [Bao mat JWT](#6-bao-mat-jwt)
7. [WebSocket va Real-time](#7-websocket-va-real-time)
8. [State Management](#8-state-management)
9. [Navigation System](#9-navigation-system)
10. [Design System (pancake_work_ui)](#10-design-system)
11. [Internationalization (pancake_work_intl)](#11-internationalization)
12. [Message Kit](#12-message-kit)
13. [CI/CD va Deployment](#13-cicd-va-deployment)
14. [Codegen va SDK Generation](#14-codegen-va-sdk-generation)
15. [Testing](#15-testing)
16. [Cac Pattern Quan Trong](#16-cac-pattern-quan-trong)

---

# PHAN A: LY THUYET FLUTTER (TU GOC RE)

---

## A1. Dart Language Fundamentals

### 1.1 Everything is an Object

Trong Dart, **moi thu deu la Object**, ke ca `int`, `double`, `bool`, `null`.

```dart
// int khong phai primitive — no la object co methods
42.toString()        // "42"
42.isEven            // true
42.compareTo(43)     // -1

// null cung la object (kieu Null)
null.runtimeType     // Null
null.hashCode        // 0
```

### 1.2 Sound Null Safety

Dart co **null safety** tu version 2.12. Compiler dam bao khong bao gio truy cap null tren non-nullable type.

```dart
String name = 'hello';     // KHONG BAO GIO null
String? nickname;           // Co the null

// Compiler bat loi:
print(nickname.length);     // ERROR: nickname co the null
print(nickname?.length);    // OK: tra ve null neu nickname == null
print(nickname!.length);    // OK nhung NGUY HIEM: crash neu null

// Late initialization
late final String config;   // Chua khoi tao, nhung PHAI khoi tao truoc khi dung
                            // Crash neu doc truoc khi gan
```

### 1.3 Cascade Notation

```dart
// Thay vi:
var button = Button();
button.text = 'Click';
button.color = Colors.blue;
button.onTap = handleTap;

// Dung cascade:
var button = Button()
  ..text = 'Click'
  ..color = Colors.blue
  ..onTap = handleTap;

// Du an dung cho:
appTypos.body1.semibold.textColor(appColors.primary1)  // Fluent API (khong phai cascade)
```

### 1.4 Extension Methods

```dart
// Them method vao class co san ma KHONG can sua class do
extension StringX on String {
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

'test@gmail.com'.isEmail  // true
'hello'.isEmail           // false

// Du an dung nhieu:
// .showError() extension tren Future<Response> de hien snackbar
// .textColor() extension tren TextStyle
// appTypos.body1.semibold — moi phan la getter/extension
```

### 1.5 Typedef va Function Types

```dart
// Function la first-class object trong Dart
typedef CommandAction0<T> = Future<T> Function();
typedef CommandAction1<T, A> = Future<T> Function(A);
typedef EventHandler<T> = void Function(T event);

// Du an: Command pattern
class Command0<T> {
  final CommandAction0<T> _action;  // Luu function nhu variable
  Future<void> execute() => _execute(_action);
}
```

### 1.6 Records va Pattern Matching (Dart 3)

```dart
// Record — lightweight tuple
(String, int) userInfo = ('Alice', 25);
print(userInfo.$1);  // 'Alice'
print(userInfo.$2);  // 25

// Named fields
({String name, int age}) user = (name: 'Alice', age: 25);

// Pattern matching voi switch expression
final result = switch (status) {
  Status.idle    => 'Waiting...',
  Status.running => 'Processing...',
  Status.success => 'Done!',
  Status.error   => 'Failed!',
};

// Destructuring trong switch
switch (item) {
  case ValidInviteIdentifier(identifier: final id, userBasicInfo: final info):
    print('Valid: $id, name: ${info.fullName}');
  case ErroredInviteIdentifier(reason: final reason):
    print('Error: $reason');
}
```

### 1.7 Sealed Classes (Dart 3)

```dart
// sealed = abstract + compiler-enforced exhaustiveness
sealed class Shape {}
class Circle extends Shape { final double radius; }
class Square extends Shape { final double side; }

// Compiler BAT BUOC xu ly TAT CA subtypes
double area(Shape shape) => switch (shape) {
  Circle(radius: final r) => 3.14 * r * r,
  Square(side: final s)   => s * s,
  // Neu thieu 1 case → COMPILE ERROR
};

// Du an dung nhieu: InviteIdentifierInputItem, AppView, AuthenticationState, ...
```

---

## A2. Dart Type System Nang Cao

### 2.1 Generics

```dart
// Generics cho phep viet code TYPE-SAFE ma khong lap lai
class Command0<T> extends Command<T> {
  final CommandAction0<T> _action;
  Future<void> execute() => _execute(_action);
}

// Su dung:
Command0<void> validateUsers = Command0<void>(_validate);  // T = void
Command0<String> fetchName = Command0<String>(_fetchName);  // T = String

// Generic constraints
class SocketHandler<T extends ReceiveEvent> {
  // T PHAI la subclass cua ReceiveEvent
  void handle(T event) { }
}
```

### 2.2 Covariance va Contravariance

```dart
// Dart generics la COVARIANT (khong nhu Java)
List<Cat> cats = [Cat()];
List<Animal> animals = cats;  // OK trong Dart (covariant)
// NHUNG: animals.add(Dog()) → Runtime error! (vi thuc chat la List<Cat>)

// An toan hon:
List<Animal> animals = List<Animal>.from(cats);  // Copy sang list moi
```

### 2.3 Type Promotion (Flow Analysis)

```dart
// Dart tu dong "promote" type sau khi check
Object value = 'hello';
if (value is String) {
  // Trong block nay, value TU DONG la String (khong can cast)
  print(value.length);  // OK — da duoc promote
}

// Voi null check
String? name;
if (name != null) {
  print(name.length);  // OK — promote tu String? thanh String
}

// KHONG hoat dong voi field (vi co the thay doi giua check va su dung)
class MyClass {
  String? name;
  void test() {
    if (name != null) {
      print(name.length);  // ERROR! name co the bi set lai boi thread khac
      print(name!.length);  // Phai dung ! hoac local variable
    }
  }
}
```

### 2.4 Abstract Interface Class (Dart 3)

```dart
// interface class — chi duoc implement, KHONG duoc extend
interface class Authenticator {
  Future<String> getToken();
}

// abstract interface class — interface THUAN (khong co implementation)
abstract interface class Repository {
  Future<List<User>> getUsers();
  Future<void> saveUser(User user);
}

// base class — chi duoc extend, KHONG duoc implement
base class BaseProvider extends ChangeNotifier {
  void refresh() { notifyListeners(); }
}

// final class — KHONG duoc extend hoac implement
final class Config {
  final String env;
  Config(this.env);
}
```

---

## A3. Dart Event Loop va Memory Model

### 3.1 Single-Threaded Event Loop

```
Dart Main Isolate chay tren 1 THREAD duy nhat.
Async/await KHONG tao thread moi — chi scheduling tren event loop.

┌─────────────────────────────────────────────┐
│              Main Isolate                    │
│                                             │
│  ┌─── Microtask Queue ───┐                  │
│  │ Future.then()         │ ← Uu tien cao    │
│  │ scheduleMicrotask()   │   (chay het       │
│  │ Completer.complete()  │    truoc khi      │
│  └───────────────────────┘    event queue)   │
│                                             │
│  ┌─── Event Queue ───────┐                  │
│  │ Timer callbacks       │ ← Uu tien thap   │
│  │ I/O callbacks         │                  │
│  │ UI events (tap, etc.) │                  │
│  │ Future (root)         │                  │
│  └───────────────────────┘                  │
│                                             │
│  Event Loop:                                │
│  while (true) {                             │
│    while (microtaskQueue.isNotEmpty)        │
│      microtaskQueue.removeFirst().run();    │
│    if (eventQueue.isNotEmpty)               │
│      eventQueue.removeFirst().run();        │
│  }                                          │
└─────────────────────────────────────────────┘
```

### 3.2 Future Execution Order

```dart
print('1. Synchronous');

Future(() => print('5. Event queue'));

Future.microtask(() => print('3. Microtask 1'));

scheduleMicrotask(() => print('4. Microtask 2'));

print('2. Synchronous (tiep)');

// Output:
// 1. Synchronous
// 2. Synchronous (tiep)
// 3. Microtask 1
// 4. Microtask 2
// 5. Event queue
```

### 3.3 async/await — Chi la syntax sugar

```dart
// HAI DOAN CODE NAY TUONG DUONG:

// Dung async/await:
Future<String> fetchUser() async {
  final response = await dio.get('/user');
  final name = response.data['name'];
  return name;
}

// Dung Future chain:
Future<String> fetchUser() {
  return dio.get('/user').then((response) {
    final name = response.data['name'];
    return name;
  });
}

// QUAN TRONG: await KHONG block thread!
// No "dang ky callback" roi TRA QUYEN cho event loop
// Khi I/O xong → event loop goi callback → tiep tuc sau await
```

### 3.4 Memory Model — Garbage Collection

```dart
// Dart dung Generational Garbage Collection:
//
// Young Space (nursery):
//   - Object moi tao
//   - GC thuong xuyen (minor GC, nhanh)
//   - Object song sot → chuyen qua Old Space
//
// Old Space:
//   - Object ton tai lau
//   - GC it hon (major GC, cham hon)
//   - Mark-Sweep-Compact algorithm
//
// Flutter-specific:
//   - Widget objects → Young Space (tao/huy moi frame)
//   - Element/State objects → Old Space (ton tai lau)
//   - Nen: Widget IMMUTABLE + tao nhieu = OK (GC toi uu cho dieu nay)
```

### 3.5 Closures va Memory Leaks

```dart
// Closure "bat" (capture) bien tu scope ngoai
class MyWidget extends StatefulWidget { ... }

class _MyState extends State<MyWidget> {
  Timer? _timer;

  void startTimer() {
    // Closure nay capture `this` (_MyState)
    // Neu khong cancel timer → _MyState KHONG duoc GC → MEMORY LEAK
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() { });  // `this` duoc capture ngam
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // PHAI cancel de giai phong reference
    super.dispose();
  }
}

// Pattern an toan: check mounted
Timer.periodic(Duration(seconds: 1), (_) {
  if (!mounted) return;  // Khong lam gi neu widget da bi dispose
  setState(() { });
});
```

---

## A4. Flutter Architecture — Tu Engine den Widget

### 4.1 Cac tang kien truc

```
┌─────────────────────────────────────────┐
│           Your App Code (Dart)          │  ← Viet code o day
├─────────────────────────────────────────┤
│         Framework Layer (Dart)          │
│  ┌──────────┬───────────┬────────────┐  │
│  │ Material │ Cupertino │  Widgets   │  │  ← Widget library
│  ├──────────┴───────────┴────────────┤  │
│  │         Rendering Layer           │  │  ← Layout, Paint
│  ├───────────────────────────────────┤  │
│  │        Foundation Layer           │  │  ← Core utilities
│  └───────────────────────────────────┘  │
├─────────────────────────────────────────┤
│           Engine Layer (C++)            │
│  ┌──────────┬──────────┬─────────────┐  │
│  │   Skia   │  Dart VM │  Platform   │  │
│  │ (render) │ (runtime)│  Channels   │  │
│  └──────────┴──────────┴─────────────┘  │
├─────────────────────────────────────────┤
│         Platform Layer (Native)         │
│  ┌──────────┬──────────┬─────────────┐  │
│  │   iOS    │ Android  │   Desktop   │  │
│  │ (UIKit)  │ (View)   │ (Win/Mac)   │  │
│  └──────────┴──────────┴─────────────┘  │
└─────────────────────────────────────────┘
```

### 4.2 Flutter Engine (C++)

```
Flutter Engine lam gi:
1. Chay Dart VM (compile AOT cho release, JIT cho debug/hot reload)
2. Render UI bang Skia/Impeller (GPU-accelerated)
3. Quan ly platform channels (giao tiep native)
4. Xu ly input events (touch, keyboard, mouse)
5. Cung cap vsync signal cho frame scheduling

Engine KHONG biet ve Widget, Element, hay State.
No chi biet: "Ve cai nay len pixel, tai vi tri nay, voi mau nay"
```

### 4.3 Bindings — Cau noi giua Engine va Framework

```dart
// Flutter co nhieu Binding, moi cai dam nhan 1 nhiem vu:

WidgetsBinding          // Quan ly widget tree, build, lifecycle
RendererBinding         // Quan ly render tree, layout, paint
SchedulerBinding        // Quan ly frame scheduling, callbacks
GestureBinding          // Quan ly gesture recognition
ServicesBinding         // Quan ly platform messages
SemanticsBinding        // Quan ly accessibility
PaintingBinding         // Quan ly image cache

// WidgetsFlutterBinding.ensureInitialized() khoi tao TAT CA bindings
// Goi trong main() truoc khi dung bat ky Flutter API nao
void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Khoi tao tat ca bindings
  runApp(MyApp());
}
```

---

## A5. Widget Tree, Element Tree, RenderObject Tree

### 5.1 Khai niem 3 cay

Flutter co 3 cay hoat dong song song:

```
Widget Tree          Element Tree           RenderObject Tree
(Immutable config)   (Mutable lifecycle)    (Layout & Paint)

MyApp                MyAppElement           RenderView
  └── Scaffold         └── ScaffoldElement     └── RenderFlex
       └── Column           └── ColumnElement        └── RenderFlex
            ├── Text             ├── TextElement           ├── RenderParagraph
            └── Button           └── ButtonElement          └── RenderBox
```

| Cay | Vai tro | Dac diem |
|-----|---------|----------|
| **Widget Tree** | Mo ta UI (blueprint) | Immutable, duoc tao lai moi lan `build()` |
| **Element Tree** | Quan ly lifecycle, giu state | Mutable, ton tai xuyen suot, map 1:1 voi widget |
| **RenderObject Tree** | Tinh toan layout, ve pixel | Chi cap nhat khi can thiet (dirty marking) |

### Widget rebuild vs Element reuse

Khi `setState()` duoc goi:
1. Flutter goi `build()` → tao **Widget Tree moi**
2. Element Tree **so sanh** widget cu vs moi (bang `runtimeType` va `key`)
3. Neu match → **reuse Element** (giu state, chi update config)
4. Neu khong match → **xoa Element cu**, tao moi

```dart
// Vi du: Column co 3 children
// TRUOC rebuild: [Text("A"), Text("B"), TextField()]
// SAU rebuild:   [Text("A"), Text("NEW"), TextField()]
//
// Element[0]: runtimeType match (Text==Text) → reuse, update text
// Element[1]: runtimeType match (Text==Text) → reuse, update text
// Element[2]: runtimeType match → reuse, GIU NGUYEN STATE (focus, text)
```

**Trong du an** — `invite_identifiers_input_v2.dart`: TextField va chip items dung `ValueKey` de dam bao Column match dung element khi list thay doi thu tu.

---

## A6. Widget Lifecycle Chi Tiet

### 6.1 StatefulWidget Lifecycle

```
Constructor
  │
  ▼
createState()           ← Goi 1 lan duy nhat
  │
  ▼
initState()             ← Goi 1 lan sau khi State duoc tao
  │                        Dung de: khoi tao controller, listener, animation
  ▼
didChangeDependencies() ← Goi sau initState() va moi khi InheritedWidget thay doi
  │                        Dung de: doc context.read/watch lan dau
  ▼
build()                 ← Goi moi khi can rebuild (setState, parent rebuild)
  │                        KHONG duoc co side effect
  ▼
didUpdateWidget()       ← Goi khi parent rebuild va truyen widget moi (cung runtimeType + key)
  │                        Dung de: so sanh old vs new widget, update state
  ▼
deactivate()            ← Goi khi Element bi go khoi tree (co the duoc reinsert)
  │
  ▼
dispose()               ← Goi khi Element bi huy vinh vien
                           Dung de: cancel timer, dispose controller, remove listener
```

### Vi du trong du an

```dart
// desktop/lib/channels/render_media_channel.dart
class _RenderMediaChannelState extends State<RenderMediaChannel> {
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _controller.initialize();
  }

  @override
  void didUpdateWidget(RenderMediaChannel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller.dispose();
      _controller = VideoPlayerController.network(widget.url);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

```dart
// desktop/lib/pancake_work_desktop/ui/main_layout/main_drawer.dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // An toan de doc InheritedWidget o day
  final appUI = context.appUI(watch: true);
}
```

### Quy tac quan trong

| Method | Duoc goi | An toan de lam |
|--------|----------|----------------|
| `initState()` | 1 lan | Khoi tao controller, add listener. **KHONG** doc InheritedWidget |
| `didChangeDependencies()` | Nhieu lan | Doc InheritedWidget, context.read/watch |
| `build()` | Nhieu lan | Tra ve Widget. **KHONG** co side effect |
| `didUpdateWidget()` | Khi parent rebuild | So sanh old/new, update state neu can |
| `dispose()` | 1 lan | Giai phong tat ca resources |

---

## A7. BuildContext — Ban Chat va Anti-patterns

### BuildContext la gi?

`BuildContext` la **tham chieu den vi tri cua Element trong tree**. Moi widget co 1 context rieng.

### Provider patterns: read vs watch vs select

```dart
// READ - doc 1 lan, KHONG lắng nghe thay doi
// Dung trong: onTap, initState, callbacks
final repo = context.read<WorkspaceRepository>();

// WATCH - lang nghe MOI thay doi, rebuild khi provider thay doi
// Dung trong: build() method
final channels = context.watch<ChannelsProviderV2>();

// SELECT - chi lang nghe 1 PHAN cua provider, rebuild khi phan do thay doi
// Toi uu performance: chi rebuild khi gia tri duoc select thay doi
final hasViewAssignedToMe = context.select<IntegrationsProvider, bool>(
  (provider) => provider
    .installedIntegrations(workspaceId)
    .any((e) => e.integration.id == constant.assignedToMeIntegrationId),
);
```

### Loi thuong gap

```dart
// SAI - read trong build (khong rebuild khi data thay doi)
@override
Widget build(BuildContext context) {
  final count = context.read<Counter>().count; // KHONG rebuild!
  return Text('$count');
}

// DUNG - watch trong build
@override
Widget build(BuildContext context) {
  final count = context.watch<Counter>().count; // Rebuild khi count thay doi
  return Text('$count');
}

// SAI - watch trong callback (gay rebuild khong can thiet)
onTap: () {
  context.watch<Counter>(); // KHONG nen watch trong callback!
}

// DUNG - read trong callback
onTap: () {
  context.read<Counter>().increment(); // Dung: 1 lan, khong lang nghe
}
```

**Trong du an:**
```dart
// desktop/lib/pancake_work_desktop/services/app_focus_handler_service.dart
context.read<ViewProvider>()           // callback → read
context.read<AppUIProvider>()          // callback → read

// desktop/lib/pancake_work_desktop/ui/main_layout/main_drawer.dart
context.appUI(watch: true)             // build → watch (custom extension)
```

---

## A8. Key System — Thuat Toan Diff

### Tai sao can Key?

Khi Flutter rebuild, no match widget cu vs moi bang **runtimeType + position**. Key giup Flutter match chinh xac hon.

### Cac loai Key

```dart
// ValueKey<T> - match bang gia tri
// Dung khi: moi item co ID duy nhat
Padding(
  key: ValueKey(email.identifier),    // Match bang identifier string
  child: InviteIdentifierItemWidget(inviteIdentifier: email),
)

// GlobalKey - truy cap State/RenderObject tu bat ky dau
// Dung khi: can doc state cua widget khac, hoac cross-widget communication
final _navigatorKey = GlobalKey<NavigatorState>();
_navigatorKey.currentState?.push(route);

// UniqueKey - moi lan tao la khac nhau (force rebuild)
// Dung khi: can FORCE tao moi widget (xoa state cu)
ListView(children: items.map((e) => Text(e, key: UniqueKey())).toList())

// ObjectKey - match bang object identity
// Dung khi: item la object nhung khong co ID
ObjectKey(myObject)
```

### Vi du thuc te trong du an

**Bai toan**: TextField trong Column bi mat focus khi list thay doi:
```dart
// TRUOC (loi): Column match by index → TextField bi unmount khi them chip
Column(children: [
  chip1, chip2, TextField(),  // TextField o index 2
])
// Them chip moi:
Column(children: [
  chip1, chip2, newChip, TextField(),  // TextField o index 3 → ELEMENT MOI → mat focus
])

// SAU (fix): Dung ValueKey → Column match by key
Column(children: [
  Padding(key: ValueKey('chip1'), child: chip1),
  Padding(key: ValueKey('chip2'), child: chip2),
  Padding(key: ValueKey('newChip'), child: newChip),
  Padding(key: _textFieldKey, child: TextField()),  // Key match → GIU FOCUS
])
```

**Session reset** — `ValueKey(session)` de force rebuild toan bo app khi session thay doi:
```dart
// desktop/lib/main.dart
PancakeWork(key: ValueKey(session), ...)  // Doi session → xoa toan bo state cu
```

---

## A9. InheritedWidget va Dependency Injection

### InheritedWidget

Cho phep truyen data xuong widget tree **KHONG can truyen qua constructor**.

```dart
// Framework cung cap: Theme.of(context), MediaQuery.of(context)

// Cach hoat dong:
// 1. InheritedWidget nam o tree
// 2. Descendant goi .of(context) de doc data
// 3. Khi data thay doi → tat ca dependent widgets rebuild
```

### InheritedModel (toi uu hon)

Cho phep dependent chi rebuild khi **phan data cu the** thay doi:

```dart
// Trong du an: AppViewScope
class AppViewScope extends InheritedModel<AppViewAspect> {
  final AppView state;

  @override
  bool updateShouldNotifyDependent(AppViewScope oldWidget, Set<AppViewAspect> dependencies) {
    for (final aspect in dependencies) {
      switch (aspect) {
        case AppViewAspect.workspaceId:
          if (oldWidget.state.tryCurrentWorkspaceId != state.tryCurrentWorkspaceId) return true;
        case AppViewAspect.channelId:
          if (oldWidget.state.tryCurrentChannelId != state.tryCurrentChannelId) return true;
      }
    }
    return false;  // Chi rebuild khi aspect duoc subscribe thay doi
  }
}

// Su dung - chi rebuild khi workspaceId thay doi (khong care channelId)
InheritedModel.inheritFrom<AppViewScope>(context, aspect: AppViewAspect.workspaceId);
```

### So sanh

| | InheritedWidget | InheritedModel | Provider |
|---|---|---|---|
| Granularity | Toan bo data | Theo aspect | Theo selector |
| Complexity | Thap | Trung binh | Thap (wrapper) |
| Use case | Theme, MediaQuery | Multi-field scope | Business state |

---

## A10. Rendering Pipeline Chi Tiet

### Rendering Pipeline

```
Main Isolate (UI Thread)
├── Event Loop
│   ├── Microtask Queue (Future.then, scheduleMicrotask)
│   └── Event Queue (Timer, I/O, tap events)
├── build() → layout → paint → composite
└── KHONG duoc block > 16ms (60fps) hoac > 8ms (120fps)

Background Isolate (Separate memory)
├── Co rieng heap, stack
├── KHONG chia se memory voi Main Isolate
├── Giao tiep qua SendPort/ReceivePort (message passing)
└── Dung cho: JSON parsing lon, image processing, crypto
```

### compute() - Don gian nhat

```dart
// Top-level function (KHONG phai method cua class)
List<User> parseUsers(String jsonString) {
  final data = json.decode(jsonString);
  return data.map((e) => User.fromJson(e)).toList();
}

// Goi tu main isolate
final users = await compute(parseUsers, hugeJsonString);
```

### Isolate.spawn() - Linh hoat hon

```dart
// Trong du an: desktop/lib/media_conversation/isolate_media.dart
Future<T> executeOnIsolate<T>(Function(SendPort) computation) async {
  final completer = Completer<T>();
  final receivePort = ReceivePort();

  await Isolate.spawn(computation, receivePort.sendPort);

  receivePort.listen((message) {
    completer.complete(message as T);
    receivePort.close();
  });

  return completer.future;
}
```

### Khi nao dung Isolate?

| Thao tac | Dung Isolate? | Ly do |
|----------|---------------|-------|
| API call (Dio) | Khong | Dio da async, khong block UI |
| JSON parse nho (<100KB) | Khong | Du nhanh tren main isolate |
| JSON parse lon (>1MB) | Co | `json.decode` block main isolate |
| Image resize/compress | Co | CPU-intensive |
| Crypto/hash | Co | CPU-intensive |
| File I/O | Khong | Dart I/O da async |
| SQLite query | Tuy | Dung isolate neu query nang |

### async/await vs Isolate

```dart
// async/await - VAN CHAY TREN MAIN ISOLATE
// Chi "nhuong" control khi gap await (I/O, timer)
Future<void> fetchData() async {
  final response = await dio.get('/api');  // Nhuong control o day
  // Khi response ve → tiep tuc tren main isolate
  processData(response);  // NEU nang → block UI!
}

// Isolate - CHAY TREN THREAD RIENG
// Khong bao gio block main isolate
final result = await compute(heavyProcess, data);
```

---

## A11. Layout System — Constraints, Sizes, Offsets

### Stream la gi?

Stream la **chuoi cac su kien theo thoi gian** (tuong tu Observable trong Rx).

```
Single value:  Future<T>    (1 gia tri, 1 lan)
Multi values:  Stream<T>    (nhieu gia tri, theo thoi gian)
```

### Cac loai Stream

```dart
// Single-subscription Stream (mac dinh)
// Chi 1 listener. Dung cho: file read, HTTP response
final stream = File('data.txt').openRead();

// Broadcast Stream
// Nhieu listener. Dung cho: events, state changes
final controller = StreamController<int>.broadcast();
controller.stream.listen((data) => print('Listener 1: $data'));
controller.stream.listen((data) => print('Listener 2: $data'));
controller.add(42);  // Ca 2 listener deu nhan
```

### Trong du an — Socket Events

```dart
// SocketDataSource su dung Stream de phat events
class SocketDataSource {
  final _eventController = StreamController<RawEvent>.broadcast();

  Stream<RawEvent> get eventStream => _eventController.stream;

  void _onMessageReceived(dynamic data) {
    _eventController.add(RawEvent.fromJson(data));
  }
}
```

```dart
// SocketLifecycleService lang nghe system events qua Stream
class SocketLifecycleService {
  StreamSubscription<SystemEvent>? _subscription;

  void start() {
    _subscription = systemEventPlugin.systemEventStream.listen((event) {
      switch (event) {
        case ScreenSleep():   socketDataSource.suspend();
        case ScreenAwake():   socketDataSource.resume();
        case ScreenLocked():  socketDataSource.suspend();
        case ScreenUnlocked(): socketDataSource.resume();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();  // LUON cancel khi dispose!
  }
}
```

### StreamBuilder trong UI

```dart
StreamBuilder<ConnectionStatus>(
  stream: socketDataSource.connectionStatusStream,
  builder: (context, snapshot) {
    if (snapshot.data == ConnectionStatus.connected) {
      return Icon(Icons.wifi, color: Colors.green);
    }
    return Icon(Icons.wifi_off, color: Colors.red);
  },
)
```

---

## A12. Paint va Compositing

### FocusNode

```dart
// Quan ly focus cua 1 widget (TextField, Button, ...)
class _MyWidgetState extends State<MyWidget> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Widget duoc focus
      } else {
        // Widget mat focus
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();  // LUON dispose!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(focusNode: _focusNode);
  }
}
```

### FocusScope

```dart
// Nhom cac FocusNode lai. Dung cho: dialog, form, modal
FocusScope(
  child: Column(children: [
    TextField(focusNode: _node1),
    TextField(focusNode: _node2),
  ]),
)

// Chuyen focus
FocusScope.of(context).nextFocus();      // Tab order
FocusScope.of(context).requestFocus(_node2);  // Focus cu the
FocusScope.of(context).unfocus();        // Bo focus
```

### Focus va Key Events (Desktop)

```dart
// Trong du an: invite_identifiers_input_v2.dart
Focus(
  focusNode: _keyboardFocusNode,
  onKeyEvent: (node, event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.tab:
        _viewModel.commitCurrentInput();
        return KeyEventResult.handled;     // Ngan Flutter xu ly tiep

      case LogicalKeyboardKey.arrowUp:
        _viewModel.navigateToPreviousIdentifier();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.backspace:
        if (_viewModel.rawInputController.selection.baseOffset == 0) {
          _viewModel.navigateToPreviousIdentifier();
          return KeyEventResult.handled;
        }
    }
    return KeyEventResult.ignored;  // De Flutter xu ly binh thuong
  },
  child: textField,
)
```

### Focus Timing Issue

```
PointerDown (Frame N):
  1. Hit test → tim widget duoc tap
  2. FocusManager unfocus widget cu → FocusNode listener fire
  3. addPostFrameCallback → chay CUOI frame N

PointerUp (Frame N+1):
  4. GestureDetector.onTap fire
  5. FocusManager focus widget moi

→ Bat ky logic trong focus listener (Frame N) deu chay TRUOC onTap (Frame N+1)
→ Day la nguyen nhan "deferred commit" pattern trong du an
```

---

## A13. Gesture System va Hit Testing (Vi du du an)

### Gesture Arena

Khi user tap, nhieu widget co the nhan event. Flutter dung **Gesture Arena** de quyet dinh widget nao "thang":

```
Tap event
  ├── GestureDetector (child)    → Tham gia arena
  ├── GestureDetector (parent)   → Tham gia arena
  └── Gesture Arena
       └── Chi 1 winner (thuong la child innermost)
```

### GestureDetector vs Listener

```dart
// GestureDetector - High-level, tham gia Gesture Arena
// Fire on PointerUp (onTap), co the bi "thua" trong arena
GestureDetector(
  onTap: () => print('Tap!'),        // Fire khi PointerUp
  onLongPress: () => print('Long!'),  // Fire sau 500ms hold
  child: container,
)

// Listener - Low-level, KHONG tham gia arena
// Fire NGAY khi PointerDown, luon nhan event
Listener(
  onPointerDown: (_) => print('Down!'),  // Fire ngay lap tuc
  child: container,
)
```

### HitTestBehavior

```dart
// opaque - Nhan tat ca events trong bound (ke ca vung trong)
GestureDetector(behavior: HitTestBehavior.opaque, ...)

// translucent - Nhan event VA cho phep widget phia sau cung nhan
GestureDetector(behavior: HitTestBehavior.translucent, ...)

// deferToChild - Chi nhan event neu child nhan (mac dinh)
GestureDetector(behavior: HitTestBehavior.deferToChild, ...)
```

### Vi du thuc te — Chip click conflict

```dart
// Van de: Parent GestureDetector(translucent) canh tranh voi chip GestureDetector
// → Parent thang arena → chip onTap khong fire

// Fix: Bo parent GestureDetector(translucent), dung GestureDetector tren tung chip
// voi HitTestBehavior.opaque
```

---

## A14. Rendering va Layout (Vi du du an)

### 3 giai doan moi frame

```
1. BUILD Phase (Widget → Element)
   setState() → markNeedsBuild() → build() → tao Widget tree moi
   Element so sanh widget cu/moi → reuse hoac tao moi

2. LAYOUT Phase (Element → RenderObject)
   Parent truyen constraints xuong → Child tinh size → tra ve size cho parent
   Chi chay cho "dirty" RenderObjects

3. PAINT Phase (RenderObject → Layer)
   RenderObject.paint() → ve len Canvas
   Composite layers → gui cho GPU

Target: Toan bo < 16ms (60fps) hoac < 8ms (120fps)
```

### Constraints flow

```
         Constraints go DOWN
Parent ──────────────────────► Child
         (min/max width/height)

         Sizes go UP
Parent ◄──────────────────────  Child
         (actual width/height)

         Parent sets position
Parent ──────────────────────► Child
         (offset)
```

### BoxConstraints

```dart
// Tight constraint: width/height co dinh
BoxConstraints.tight(Size(200, 100))  // min == max

// Loose constraint: tu 0 den max
BoxConstraints.loose(Size(200, 100))  // min = 0, max = given

// Expand: chiem toan bo khong gian
BoxConstraints.expand()  // min == max == infinity (hoac parent size)

// Loi thuong gap:
// "RenderBox was not laid out" → Widget khong nhan duoc constraints hop le
// "Unbounded height" → Column/ListView trong Column ma khong co Expanded
```

---

## A15. Mixin va App Lifecycle (Vi du du an)

### Cach giao tiep Flutter ↔ Native

```
Flutter (Dart)          ←→     Native (Swift/Kotlin/C++)
     │                              │
     └── MethodChannel ────────────┘
         (async message passing)
```

### MethodChannel

```dart
// Dart side - goi native method
const channel = MethodChannel('resize_image_by_bytes');
final result = await channel.invokeMethod('resize', {'data': bytes, 'maxWidth': 800});

// Native side (Swift) - xu ly
let channel = FlutterMethodChannel(name: "resize_image_by_bytes", ...)
channel.setMethodCallHandler { (call, result) in
  if call.method == "resize" {
    let args = call.arguments as! [String: Any]
    // Process image...
    result(resizedData)
  }
}
```

### Vi du trong du an

```dart
// desktop/lib/media_conversation/model.dart
// Resize image bang native code (performance tot hon Dart)
final resized = await MethodChannel('resize_image_by_bytes')
    .invokeMethod('resize', {'data': imageBytes});

// desktop/lib/multi_window_screen.dart
// Quan ly multi-window tren desktop
const MethodChannel('custom_window_channel')

// desktop/lib/workspaces/apps/snappy/file_save_helper.dart
// Mo file Excel bang native app
MethodChannel('launchFile').invokeMethod('viewExcel', filePath)

// desktop/lib/common/drop_zone.dart
// Xu ly drag & drop file tu OS
MethodChannel('drop_zone').invokeMethod('getDroppedFiles')
```

---

## (old) Mixin trong Dart/Flutter

### Mixin la gi?

Mixin la cach **chia se code giua nhieu class** ma khong dung ke thua (inheritance).

```dart
// Dinh nghia mixin
mixin SocketHandlerMixin on ChangeNotifier {
  // "on ChangeNotifier" → chi class extends ChangeNotifier moi dung duoc mixin nay

  final List<VoidCallback> _disposers = [];

  void addSocketHandler<T extends ReceiveEvent>(EventHandler<T> handler) {
    socketDataSource.addHandler<T>(handler);
    _disposers.add(() => socketDataSource.removeHandler<T>(handler));
  }

  @override
  void dispose() {
    for (final disposer in _disposers) disposer();
    super.dispose();
  }
}

// Su dung
class ChannelsProviderV2 extends ChangeNotifier with SocketHandlerMixin {
  // Co tat ca methods cua SocketHandlerMixin
}
```

### Cac mixin Flutter hay dung

```dart
// SingleTickerProviderStateMixin - cho AnimationController
class _MyState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: Duration(ms: 300));
}

// TickerProviderStateMixin - cho NHIEU AnimationController
class _MyState extends State<MyWidget> with TickerProviderStateMixin { }

// AutomaticKeepAliveClientMixin - giu state khi tab/page bi offstage
class _MyState extends State<MyWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}

// WidgetsBindingObserver - lang nghe app lifecycle
class _MyState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { }
}
```

### Trong du an

```dart
// desktop/lib/pancake_work_desktop/ui/main_layout/main_screen.dart
class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin,     // Animation
         AutomaticKeepAliveClientMixin,       // Keep state alive
         WindowListener {                     // Window events (desktop)

// desktop/lib/pancake_work_desktop/ui/core/app_focus_mixin.dart
mixin AppFocusMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<SystemEvent>? _appFocusSubscription;

  @override
  void initState() {
    super.initState();
    _appFocusSubscription = systemEventStream.listen(_handleFocusEvent);
  }

  @override
  void dispose() {
    _appFocusSubscription?.cancel();
    super.dispose();
  }
}

// desktop/lib/task_view/task_list_mixin.dart
mixin TaskListMixin<T extends StatefulWidget> on State<T> {
  final filterKey = GlobalKey();
  // Shared logic cho task list across different screens
}
```

---

## (old) App Lifecycle

### Mobile App Lifecycle

```
         ┌─────────────────┐
         │    inactive      │ ← Chuyen doi giua foreground/background
         └────────┬────────┘
                  │
    ┌─────────────┼─────────────┐
    ▼             │             ▼
┌────────┐   ┌────────┐   ┌──────────┐
│ resumed │   │ paused │   │ detached │
│(active) │   │(bg)    │   │(closing) │
└────────┘   └────────┘   └──────────┘
```

| State | Khi nao | Nen lam gi |
|-------|---------|------------|
| `resumed` | App visible va interactive | Reconnect, refresh data |
| `inactive` | Dang chuyen (vd: incoming call) | Pause animations |
| `paused` | App hoan toan bi an | Disconnect socket, save state |
| `detached` | App sap bi kill | Final cleanup |
| `hidden` | App hidden nhung chua paused | Pause non-critical work |

### Desktop App Lifecycle (Du an dung NativePlugin)

```dart
// Thay vi WidgetsBindingObserver, du an dung native system events
class SocketLifecycleService {
  void start() {
    _subscription = systemEventPlugin.systemEventStream.listen((event) {
      switch (event) {
        case ScreenSleep():    _socketDataSource.suspend();
        case ScreenAwake():    _socketDataSource.resume();
        case ScreenLocked():   _socketDataSource.suspend();
        case ScreenUnlocked(): _socketDataSource.resume();
      }
    });
  }
}

// App focus/unfocus
class AppFocusHandlerService {
  void _onAppFocused() {
    // Refresh data, reconnect, update presence
  }

  void _onAppUnfocused() {
    // Pause polling, reduce activity
  }
}
```

---

## (old) Performance Optimization

### RepaintBoundary

```dart
// Ngan widget con lam "dirty" widget cha (va nguoc lai)
// Dung khi: animation chi anh huong 1 phan UI

// Trong du an:
// desktop/lib/pancake_work_desktop/ui/app_root.dart
RepaintBoundary(
  key: AppErrorProcessor.repaintKey,
  child: child,  // Error overlay khong lam repaint toan app
)

// desktop/lib/flutter_mention/custom_text_field.dart
Widget child = RepaintBoundary(
  child: editableText,  // Text editing khong repaint surrounding UI
)
```

### Offstage (Giu state ma khong render)

```dart
// Offstage giu widget SONG nhung KHONG ve len man hinh
// Dung cho: tab switching, giu scroll position, giu state

// Trong du an: primary_panel.dart
// Stack workspace view va DM view, chi hien 1 cai
Stack(children: [
  Offstage(offstage: activeTab != AppActiveTab.workspace, child: workspaceView),
  Offstage(offstage: activeTab != AppActiveTab.directMessage, child: dmView),
])
// → Chuyen tab KHONG mat state, scroll position, message list
```

### const Constructor

```dart
// const widgets duoc tao 1 lan, TAI SU DUNG qua cac rebuild
const SizedBox(height: 16)           // 1 instance duy nhat
const EdgeInsets.all(12)             // 1 instance duy nhat
const Icon(Icons.check, size: 14)   // 1 instance duy nhat

// Flutter skip rebuild cho const widgets vi chung identical
```

### ListView.builder (Lazy rendering)

```dart
// CHI tao widgets cho items DANG HIEN tren man hinh
ListView.builder(
  itemCount: 10000,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  // Chi ~15-20 widgets duoc tao cung luc (tuy viewport size)
)

// KHONG nen:
ListView(
  children: items.map((e) => ListTile(...)).toList(),  // Tao TAT CA 10000 widgets!
)
```

### select() thay vi watch()

```dart
// watch() - rebuild khi BAT KY field nao cua provider thay doi
final provider = context.watch<HugeProvider>();  // Rebuild qua nhieu

// select() - chi rebuild khi field CU THE thay doi
final name = context.select<HugeProvider, String>((p) => p.name);  // Chi rebuild khi name doi
```

---

## (old) Scheduler va Frame Timing

### Frame lifecycle

```
vsync signal (60fps = moi 16.67ms)
  │
  ├── 1. Transient callbacks (SchedulerBinding.scheduleFrameCallback)
  │      → Animation ticks
  │
  ├── 2. Persistent callbacks (SchedulerBinding.addPersistentFrameCallback)
  │      → Build → Layout → Paint (rendering pipeline)
  │
  └── 3. Post-frame callbacks (SchedulerBinding.addPostFrameCallback)
         → Chay SAU rendering xong
         → An toan de: scroll to position, request focus, measure size
```

### addPostFrameCallback

```dart
// Chay 1 LAN sau khi frame hien tai render xong
WidgetsBinding.instance.addPostFrameCallback((_) {
  // An toan de doc size, vi tri, request focus
  _inputFocusNode.requestFocus();
});

// Trong du an — request focus sau khi widget tree da stable
void _requestInputFocus() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _inputFocusNode.requestFocus();
  });
}
```

### Timer.run vs Future.microtask vs addPostFrameCallback

```dart
// Future.microtask - chay truoc EVENT QUEUE tiep theo
// Nhanh nhat, nhung truoc rendering
Future.microtask(() => doSomething());

// Timer.run - chay o EVENT QUEUE tiep theo (= Timer(Duration.zero, ...))
// Sau microtask, nhung co the truoc hoac sau rendering
Timer.run(() => doSomething());

// addPostFrameCallback - chay SAU rendering
// Cham nhat, nhung dam bao UI da update
WidgetsBinding.instance.addPostFrameCallback((_) => doSomething());

// Thu tu thuc thi:
// 1. Future.microtask (microtask queue)
// 2. Timer.run (event queue)
// 3. addPostFrameCallback (cuoi frame)
```

### Bai hoc tu du an — Focus timing

```
Van de: Focus loss fire tren PointerDown (Frame N),
        nhung GestureDetector.onTap chi fire tren PointerUp (Frame N+1).
        addPostFrameCallback chay cuoi Frame N → QUA SOM, truoc onTap.

Timeline:
  Frame N:   PointerDown → focusLost → addPostFrameCallback runs ← qua som!
  Frame N+1: PointerUp → onTap fires ← qua muon, callback da chay

Giai phap: Khong dung timer/callback. Thay vao do, thiet ke lai logic
           de khong phu thuoc vao timing giua focus va tap.
```

---

## A16. Isolate va Concurrency (Bo sung sau)

*(Da co o muc A6 cu — xem Section A3 ve Event Loop va muc cu A6 de hoc them)*

---

## A17. Stream va Reactive Programming (Bo sung sau)

*(Da co o muc A7 cu — xem Section A3.1 ve Event Queue)*

---

## A18. Platform Channels va FFI

### 18.1 Cac loai channel

```
MethodChannel      — Goi method async, tra ve Future
                     Dung cho: 1 lan goi, 1 lan tra ket qua
                     VD: resize image, open file, get device info

EventChannel       — Stream events tu native → Dart
                     Dung cho: sensor data, location updates, system events
                     VD: accelerometer stream, battery level changes

BasicMessageChannel — Gui/nhan message raw (String, ByteData)
                     Dung cho: custom protocol, binary data
```

### 18.2 FFI (Foreign Function Interface)

```dart
// Goi C/C++ truc tiep tu Dart (KHONG qua platform channel)
// Nhanh hon MethodChannel vi khong can serialize/deserialize

import 'dart:ffi';

// Load native library
final dylib = DynamicLibrary.open('libnative.so');

// Lookup function
typedef NativeAdd = Int32 Function(Int32, Int32);
typedef DartAdd = int Function(int, int);
final add = dylib.lookupFunction<NativeAdd, DartAdd>('add');

print(add(3, 4));  // 7 — goi C function truc tiep
```

---

## A19. Navigation va Routing

### 19.1 Navigator 1.0 (Imperative)

```dart
// Push screen moi len stack
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen()));

// Pop screen hien tai
Navigator.pop(context);

// Push va xoa tat ca screen cu
Navigator.pushAndRemoveUntil(context, route, (route) => false);
```

### 19.2 Navigator 2.0 (Declarative)

```dart
// Du an dung Declarative navigation qua AppUIProvider
// UI duoc MO TA boi state, KHONG phai boi imperative push/pop

// Thay vi:  Navigator.push(context, InviteScreen())
// Dung:     appUIProvider.switchToInviteView(workspaceId: id)
//           → state thay doi → UI tu dong rebuild → hien InviteScreen

// Loi the:
// - Deep linking de (state → URL → state)
// - Back button hoat dong dung
// - State co the serialize/deserialize (khoi phuc khi restart)
```

### 19.3 showDialog vs Overlay

```dart
// showDialog — dung Navigator, co barrier, co route
showDialog(context: context, builder: (_) => AlertDialog(...));
// → Push 1 route moi len Navigator stack
// → Nhan Back button
// → Co modal barrier (tap outside de dong)

// Overlay — truc tiep, khong dung Navigator
Overlay.of(context).insert(OverlayEntry(builder: (_) => MyOverlay()));
// → Khong co route, khong co barrier
// → Dung cho: tooltip, dropdown, popup menu
// → Phai tu quan ly lifecycle
```

---

## A20. State Management — Nguyen Ly va Cac Phuong Phap

### 20.1 Tai sao can State Management?

```
Van de co ban:
Widget A can data tu Widget B, nhung A va B o KHAC NHANH trong tree.

        Root
       /    \
      A      C
     / \      \
    B   D      E  ← E can data tu B

Khong co state management:
  B → truyen data len A → truyen len Root → truyen xuong C → truyen xuong E
  = "Prop drilling" — code xau, kho maintain

Voi state management:
  B update state → Provider/InheritedWidget notify → E rebuild truc tiep
  = Clean, declarative
```

### 20.2 setState (Local state)

```dart
// Don gian nhat. Dung cho state CHI thuoc 1 widget.
// KHONG dung cho: shared state, complex logic

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => setState(() => _count++),  // Rebuild widget nay
      child: Text('$_count'),
    );
  }
}

// setState() lam gi ben trong:
// 1. Goi callback (thay doi state)
// 2. markNeedsBuild() — danh dau Element la "dirty"
// 3. SchedulerBinding schedule 1 frame moi
// 4. Trong frame moi: build() duoc goi lai
```

### 20.3 Provider Pattern (Du an dung)

```
Provider wrap InheritedWidget de de su dung hon:

                    ChangeNotifierProvider<MyProvider>
                              │
                    InheritedNotifier<MyProvider>
                              │
                       InheritedWidget
                              │
                      Element.dependOnInheritedElement()
                              │
                     Khi notifyListeners() →
                     tat ca dependents duoc rebuild
```

### 20.4 So sanh cac phuong phap

| Phuong phap | Complexity | Use case | Du an dung |
|---|---|---|---|
| `setState` | Thap | UI state don gian | isOpen, isHovered |
| `ValueNotifier` | Thap | 1 gia tri | Selected tab |
| `ChangeNotifier` | Trung binh | Multi-field state | ViewModels, Providers |
| `Provider` | Trung binh | Shared state | Toan bo du an |
| `Bloc/Cubit` | Cao | Complex events | Khong dung |
| `Riverpod` | Cao | Compile-safe DI | Khong dung |

---

## A21. Testing trong Flutter

### 21.1 3 loai test

```
Unit Test          Widget Test           Integration Test
(nhanh nhat)       (trung binh)          (cham nhat)
   │                   │                      │
   ▼                   ▼                      ▼
Test logic thuan   Test widget render     Test toan bo app
Khong can Flutter  Mock framework         Can emulator/device
                   pump() de render
```

### 21.2 Unit Test

```dart
// Test logic thuan — KHONG can Flutter
test('removeDuplicates removes duplicates by identifier', () {
  final items = [
    PendingInviteIdentifier(identifier: 'a@b.com', originalInput: 'a@b.com'),
    PendingInviteIdentifier(identifier: 'a@b.com', originalInput: 'A@B.COM'),
  ];
  final result = removeDuplicates(items);
  expect(result.length, 1);
});
```

### 21.3 Widget Test

```dart
// Test widget render va interaction
testWidgets('Button shows loading when command is running', (tester) async {
  final command = Command0<void>(() async {
    await Future.delayed(Duration(seconds: 1));
  });

  await tester.pumpWidget(MaterialApp(
    home: ListenableBuilder(
      listenable: command,
      builder: (_, __) => Button(loading: command.running, onTap: command.execute),
    ),
  ));

  // Verify initial state
  expect(find.byType(CircularProgressIndicator), findsNothing);

  // Tap button
  await tester.tap(find.byType(Button));
  await tester.pump();  // Trigger 1 frame

  // Verify loading state
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### 21.4 Cac ham quan trong

```dart
tester.pump()              // Trigger 1 frame (build + layout + paint)
tester.pumpAndSettle()     // Pump cho den khi khong con animation
tester.tap(finder)         // Simulate tap
tester.enterText(finder, 'hello')  // Nhap text
tester.drag(finder, Offset(0, -300))  // Keo

find.text('Hello')         // Tim widget co text 'Hello'
find.byType(Button)        // Tim widget theo type
find.byKey(ValueKey('x'))  // Tim widget theo key

expect(finder, findsOneWidget)     // Dung 1 widget
expect(finder, findsNothing)       // Khong tim thay
expect(finder, findsNWidgets(3))   // Dung 3 widgets
```

---

## A22. Performance — Do Luong va Toi Uu

### 22.1 Nguyen tac vang

```
1. MEASURE truoc, optimize sau
   - Dung DevTools Performance tab
   - Dung Timeline events
   - KHONG doan — do luong thuc te

2. Build phase la thu pham thuong gap nhat
   - Qua nhieu widget rebuild khong can thiet
   - Dung const, select(), RepaintBoundary

3. 60fps = 16.67ms per frame
   - Build + Layout + Paint PHAI < 16ms
   - Neu > 16ms → jank (frame drop)
```

### 22.2 Cach giam rebuild

```dart
// 1. const constructor — widget KHONG BAO GIO rebuild
const SizedBox(height: 16)
const Icon(Icons.check)
const EdgeInsets.all(12)

// 2. select() thay vi watch()
// SAI: rebuild khi BAT KY field nao thay doi
final provider = context.watch<BigProvider>();

// DUNG: chi rebuild khi field cu the thay doi
final name = context.select<BigProvider, String>((p) => p.name);

// 3. Tach widget nho
// SAI: 1 widget lon, rebuild toan bo khi 1 phan thay doi
class BigWidget extends StatelessWidget {
  Widget build(context) {
    return Column(children: [
      ExpensiveHeader(),        // Rebuild khong can thiet!
      Text(context.watch<P>().count.toString()),
      ExpensiveFooter(),        // Rebuild khong can thiet!
    ]);
  }
}

// DUNG: tach phan thay doi ra widget rieng
class CountDisplay extends StatelessWidget {
  Widget build(context) {
    return Text(context.watch<P>().count.toString());  // Chi rebuild widget nay
  }
}
```

### 22.3 RepaintBoundary

```dart
// Khi 1 widget thay doi (animation, counter), Flutter repaint
// tat ca widget CUNG LAYER. RepaintBoundary tao layer moi.

// TRUOC: counter thay doi → repaint toan bo Column
Column(children: [
  HeavyChart(),           // Bi repaint khong can thiet!
  AnimatedCounter(),       // Nguon thay doi
])

// SAU: counter thay doi → chi repaint counter
Column(children: [
  RepaintBoundary(child: HeavyChart()),  // Layer rieng, khong bi repaint
  AnimatedCounter(),
])
```

### 22.4 Offstage vs Visibility vs Conditional

```dart
// Offstage — KHONG render nhung GIU STATE (layout vẫn chạy)
Offstage(offstage: !isVisible, child: ExpensiveWidget())
// Dung khi: can giu state (scroll position, text input)

// Visibility — KHONG render, KHONG layout, GIU STATE
Visibility(visible: isVisible, child: ExpensiveWidget())
// Dung khi: can giu state + khong ton layout cost

// Conditional — KHONG tao widget, MAT STATE
if (isVisible) ExpensiveWidget()
// Dung khi: khong can giu state, tiet kiem memory
```

---

## A23. Memory Management va Leak Detection

### 23.1 Nguyen nhan Memory Leak trong Flutter

```
1. Khong dispose controller
   TextEditingController, AnimationController, ScrollController, FocusNode
   → PHAI dispose trong dispose()

2. Khong cancel subscription
   StreamSubscription, Timer
   → PHAI cancel trong dispose()

3. Closure capture
   Timer.periodic(() { setState(() {}); })
   → Closure giu reference den State → State khong duoc GC

4. Global reference
   static List<Callback> listeners = [];
   listeners.add(myCallback);  // myCallback capture State
   → PHAI remove trong dispose()
```

### 23.2 Pattern an toan

```dart
class _MyState extends State<MyWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  StreamSubscription? _subscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _subscription = stream.listen(_onData);
    _timer = Timer.periodic(Duration(seconds: 5), _onTick);
  }

  void _onData(data) {
    if (!mounted) return;  // An toan check
    setState(() { });
  }

  void _onTick(Timer t) {
    if (!mounted) { t.cancel(); return; }
    // ...
  }

  @override
  void dispose() {
    _timer?.cancel();           // 1. Cancel timers
    _subscription?.cancel();    // 2. Cancel subscriptions
    _focusNode.dispose();       // 3. Dispose focus nodes
    _controller.dispose();      // 4. Dispose controllers
    super.dispose();            // 5. CUOI CUNG goi super.dispose()
  }
}
```

### 23.3 Du an pattern: SocketHandlerMixin auto-dispose

```dart
// Mixin tu dong dispose handlers khi provider bi dispose
mixin SocketHandlerMixin on ChangeNotifier {
  final List<VoidCallback> _disposers = [];

  void addSocketHandler<T>(handler) {
    socketDataSource.addHandler<T>(handler);
    _disposers.add(() => socketDataSource.removeHandler<T>(handler));  // Luu de dispose
  }

  @override
  void dispose() {
    for (final disposer in _disposers) disposer();  // Giai phong TAT CA
    super.dispose();
  }
}
// → KHONG BAO GIO quen dispose socket handler
```

---

## A24. Scheduler, Binding va Frame Timing

### 24.1 1 Frame trong Flutter

```
vsync signal (60Hz = moi 16.67ms, 120Hz = moi 8.33ms)
│
├── Phase 1: ANIMATION (Transient callbacks)
│   SchedulerBinding.scheduleFrameCallback()
│   → AnimationController tick
│   → Implicit animation update
│
├── Phase 2: BUILD (Persistent callbacks - rendering pipeline)
│   │
│   ├── 2a. Build Phase
│   │   Element.rebuild() cho dirty elements
│   │   Widget.build() duoc goi
│   │   Element tree duoc update
│   │
│   ├── 2b. Layout Phase
│   │   RenderObject.performLayout()
│   │   Constraints di xuong, sizes di len
│   │   Parent dat vi tri cho children
│   │
│   └── 2c. Paint Phase
│       RenderObject.paint()
│       Ve len Canvas → tao Layer tree
│       Composite layers → gui cho engine
│
├── Phase 3: POST-FRAME (Post-frame callbacks)
│   WidgetsBinding.addPostFrameCallback()
│   → An toan de: measure size, request focus, scroll to position
│   → Chay SAU khi UI da duoc render
│
└── Engine composite va present len man hinh
```

### 24.2 Chi tiet ve Dirty Marking

```dart
// Khi setState() duoc goi:
setState(() { _count++; });

// Ben trong:
// 1. _count thay doi (synchronous)
// 2. markNeedsBuild() duoc goi tren Element
// 3. Element duoc them vao "dirty list"
// 4. SchedulerBinding.scheduleFrame() — request 1 frame moi

// QUAN TRONG: build() KHONG chay ngay!
// No chi chay khi frame tiep theo duoc schedule

setState(() { _count = 1; });
print(_count);  // 1 — state DA thay doi
// Nhung UI CHUA update — phai doi frame tiep theo
```

### 24.3 Microtask vs Timer vs PostFrame — Chi tiet

```dart
print('1. sync');

Future.microtask(() => print('3. microtask'));

Timer.run(() => print('4. timer (event queue)'));

WidgetsBinding.instance.addPostFrameCallback((_) {
  print('5. post-frame');
});

setState(() { });  // Schedule frame

print('2. sync (tiep)');

// Output:
// 1. sync
// 2. sync (tiep)
// 3. microtask          ← Microtask queue (truoc event queue)
// 4. timer              ← Event queue (truoc frame)
// --- Frame starts ---
// build() runs
// layout runs
// paint runs
// --- Frame ends ---
// 5. post-frame         ← Sau khi frame hoan thanh
```

---

## A25. Accessibility va Semantics

### 25.1 Semantics Tree

```
Flutter co 1 cay thu 4: Semantics Tree
Cung cap thong tin cho screen readers (VoiceOver, TalkBack)

Widget Tree → Element Tree → RenderObject Tree → Semantics Tree

Semantics(
  label: 'Send message button',
  button: true,
  enabled: true,
  child: Icon(Icons.send),
)
```

### 25.2 Cach hoat dong

```dart
// Flutter tu dong tao semantics cho nhieu widget:
// Text('Hello') → Semantics(label: 'Hello')
// ElevatedButton(onPressed: ...) → Semantics(button: true, enabled: true)
// Checkbox(value: true) → Semantics(checked: true)

// Custom semantics:
Semantics(
  label: 'User avatar',
  image: true,
  child: CircleAvatar(backgroundImage: NetworkImage(url)),
)

// Exclude tu semantics tree:
ExcludeSemantics(child: decorativeWidget)

// Merge children semantics:
MergeSemantics(child: Row(children: [Icon(...), Text(...)]))
```

### 25.3 Tai sao quan trong

```
1. Legal requirement o nhieu nuoc (ADA, WCAG)
2. 15% dan so the gioi co khuyet tat
3. Screen reader users can navigate app
4. Flutter DevTools co "Semantics Debugger" de kiem tra
```

---

## A26. Flutter Ve 1 Widget Nhu The Nao — Tu Dong Lenh Den Pixel

Day la phan QUAN TRONG NHAT de hieu Flutter tu goc re.

### 26.1 Tong quan: Tu `runApp()` den pixel tren man hinh

```
runApp(MyApp())
     │
     ▼
[1] TAO WIDGET TREE
     MyApp().build() → MaterialApp → Scaffold → Column → [Text, Button]
     Moi widget la 1 IMMUTABLE CONFIGURATION OBJECT
     Widget KHONG ve gi ca — no chi MO TA "toi muon gi"
     │
     ▼
[2] TAO ELEMENT TREE (mount)
     Moi Widget → 1 Element
     Element la MUTABLE, giu reference den Widget va RenderObject
     Element song xuyen suot (khong bi tao lai moi frame)
     │
     ▼
[3] TAO RENDEROBJECT TREE
     Moi RenderObjectWidget → 1 RenderObject
     RenderObject la object THUC SU lam layout va paint
     Chi 1 so widget tao RenderObject (Padding, Container, Text, ...)
     Cac widget nhu Column, Row, Stack → tao RenderFlex, RenderStack
     │
     ▼
[4] LAYOUT PHASE
     RenderObject.performLayout()
     Parent gui constraints xuong → Child tinh size → tra size len
     Ket qua: moi RenderObject biet SIZE va POSITION cua minh
     │
     ▼
[5] PAINT PHASE
     RenderObject.paint(PaintingContext, Offset)
     Ve len Canvas: rect, text, image, path, ...
     Tao Layer tree (display list)
     │
     ▼
[6] COMPOSITING
     Layer tree → gui cho Flutter Engine (C++)
     Engine → Skia/Impeller (GPU) → Pixel tren man hinh
```

### 26.2 Chi tiet: Widget KHONG ve gi

```dart
// Widget chi la CONFIG — giong nhu blueprint cua 1 ngoi nha
// NO KHONG PHAI la ngoi nha

class Text extends StatelessWidget {
  final String data;
  final TextStyle? style;

  // build() tra ve WIDGET KHAC — khong phai pixel
  @override
  Widget build(BuildContext context) {
    // Cuoi cung se tra ve RichText — mot RenderObjectWidget
    return RichText(
      text: TextSpan(text: data, style: effectiveStyle),
    );
  }
}

// RichText la LeafRenderObjectWidget — no TAO RenderObject
class RichText extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraph(text);  // DAY moi la object VE text
  }
}

// Hierarchy:
// Text (StatelessWidget) — chi config
//   → RichText (LeafRenderObjectWidget) — tao RenderObject
//     → RenderParagraph (RenderObject) — THUC SU ve text
```

### 26.3 Chi tiet: Element — Bo nao cua Flutter

```
Element la TRUNG TAM dieu phoi:

  Widget (immutable config)
     ↕ reference
  Element (mutable, long-lived)
     ↕ reference
  RenderObject (layout + paint)

Element lam gi:
1. GIU STATE (cho StatefulWidget)
2. GIU REFERENCE den Widget hien tai va RenderObject
3. QUYET DINH khi nao rebuild, khi nao reuse
4. QUAN LY lifecycle (mount, update, unmount)
5. THAM GIA vao InheritedWidget notification system
```

```dart
// Khi Flutter gap 1 Widget lan dau:
// 1. Goi widget.createElement() → tao Element
// 2. Goi element.mount(parent, slot) → gan vao tree
// 3. Neu la RenderObjectWidget: goi createRenderObject() → tao RenderObject

// Khi parent rebuild va tra ve Widget moi:
// 1. Element SO SANH widget cu vs moi (canUpdate)
// 2. canUpdate = (runtimeType giong) && (key giong hoac ca hai khong co key)
// 3. Neu canUpdate == true:
//    → Goi element.update(newWidget) — reuse Element, chi update config
//    → Neu la RenderObject: goi updateRenderObject() — update properties
// 4. Neu canUpdate == false:
//    → Deactivate Element cu → Unmount → Tao Element moi tu Widget moi

static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}
```

### 26.4 Vi du cu the: Column([Text("A"), Text("B")]) duoc ve nhu the nao

```
BUOC 1: Widget Tree (chi la config)
─────────────────────────────────
Column(children: [Text("A"), Text("B")])

Widget tree:
  Column
    ├── Text("A")
    └── Text("B")

BUOC 2: Element Tree (mount)
─────────────────────────────
Column.createElement() → MultiChildRenderObjectElement
  ├── Text("A").createElement() → StatelessElement
  │     └── RichText.createElement() → LeafRenderObjectElement
  └── Text("B").createElement() → StatelessElement
        └── RichText.createElement() → LeafRenderObjectElement

BUOC 3: RenderObject Tree
─────────────────────────
Column tao RenderFlex (direction: vertical)
  ├── RichText tao RenderParagraph("A")
  └── RichText tao RenderParagraph("B")

Chi RenderObjectWidget moi tao RenderObject:
  Column     → RenderFlex          (MultiChildRenderObjectWidget)
  Padding    → RenderPadding       (SingleChildRenderObjectWidget)
  RichText   → RenderParagraph     (LeafRenderObjectWidget)
  Container  → RenderDecoratedBox  (SingleChildRenderObjectWidget)
  SizedBox   → RenderConstrainedBox

Cac widget KHONG tao RenderObject:
  Text, Scaffold, MaterialApp, Builder, Consumer, ListenableBuilder
  → Chung chi goi build() va tra ve widget khac

BUOC 4: Layout
─────────────
RenderFlex.performLayout():
  1. Gui constraints cho moi child: BoxConstraints(0, maxWidth, 0, infinity)
  2. Child[0] (RenderParagraph "A"): tinh size = (50, 16)
  3. Child[1] (RenderParagraph "B"): tinh size = (50, 16)
  4. RenderFlex tinh tong: height = 16 + 16 = 32
  5. Dat position: Child[0] offset (0, 0), Child[1] offset (0, 16)

BUOC 5: Paint
─────────────
RenderFlex.paint(context, offset):
  context.paintChild(child[0], Offset(0, 0))
    → RenderParagraph.paint(): ve "A" len Canvas tai (0, 0)
  context.paintChild(child[1], Offset(0, 16))
    → RenderParagraph.paint(): ve "B" len Canvas tai (0, 16)

BUOC 6: Compositing → Engine → GPU → Man hinh
```

### 26.5 Widget Categories — Loai nao tao RenderObject?

```
┌─────────────────────────────────────────────────────────────────┐
│                        Widget                                    │
├──────────────────────────┬──────────────────────────────────────┤
│   StatelessWidget        │   StatefulWidget                     │
│   (chi goi build())     │   (chi goi build() + co State)       │
│                          │                                      │
│   KHONG tao RenderObject │   KHONG tao RenderObject             │
│                          │                                      │
│   VD: Text, Icon,        │   VD: Checkbox, TextField,          │
│   MaterialApp,           │   AnimatedContainer,                 │
│   Consumer, Builder      │   ScrollView                         │
├──────────────────────────┴──────────────────────────────────────┤
│                  RenderObjectWidget                              │
│                  (TAO RenderObject)                              │
├──────────────────┬────────────────────┬─────────────────────────┤
│ LeafRenderObject │ SingleChildRender  │ MultiChildRender        │
│ Widget           │ ObjectWidget       │ ObjectWidget            │
│ (khong con)      │ (1 con)           │ (nhieu con)             │
│                  │                    │                         │
│ RichText         │ Padding            │ Column/Row (→RenderFlex)│
│ RawImage         │ Align              │ Stack (→RenderStack)    │
│ ErrorWidget      │ SizedBox           │ Wrap (→RenderWrap)      │
│                  │ DecoratedBox       │ CustomMultiChild        │
│                  │ Transform          │                         │
│                  │ Opacity            │                         │
│                  │ ClipRect           │                         │
└──────────────────┴────────────────────┴─────────────────────────┘

QUAN TRONG: Phan lon widget ban dung (Text, Container, Scaffold, ...)
la StatelessWidget/StatefulWidget. Chung chi goi build() va cuoi cung
tra ve 1 RenderObjectWidget o leaf node.

Container thuc ra la tho hop cua nhieu widget:
  Container = Padding + DecoratedBox + ConstrainedBox + Transform + ...
  Moi cai la 1 SingleChildRenderObjectWidget
```

### 26.6 setState() — Chuyen gi xay ra ben trong?

```
Ban goi:  setState(() { _count++; })

FRAME HIEN TAI (synchronous):
──────────────────────────
1. Callback chay: _count thay doi tu 0 → 1
2. _element.markNeedsBuild() duoc goi
3. Element duoc them vao "dirty list" cua BuildOwner
4. SchedulerBinding.scheduleFrame() — yeu cau engine cho 1 frame moi

FRAME TIEP THEO (khi vsync signal den):
──────────────────────────────────────
5. WidgetsBinding.drawFrame() duoc goi
6. BuildOwner.buildScope():
   - Duyet qua dirty list
   - Goi element.rebuild() cho moi dirty element
   - rebuild() goi widget.build(context)
   - build() tra ve Widget tree moi
   - Element so sanh cu vs moi (canUpdate)
   - Update hoac tao moi Element/RenderObject

7. PipelineOwner.flushLayout():
   - Duyet qua RenderObjects co "needs layout"
   - Goi performLayout() cho tung cai
   - Constraints di xuong, sizes di len

8. PipelineOwner.flushCompositingBits():
   - Update compositing bits (layer boundaries)

9. PipelineOwner.flushPaint():
   - Duyet qua RenderObjects co "needs paint"
   - Goi paint() cho tung cai
   - Ve len Canvas → Layer tree

10. renderView.compositeFrame():
    - Gui Layer tree cho engine
    - Engine composite → GPU render → pixel
```

### 26.7 Dirty Marking — Tai sao chi rebuild 1 phan?

```
KHONG phai toan bo tree rebuild moi frame.
Chi nhung Element DIRTY moi rebuild.

setState() chi mark 1 Element la dirty.
Chi Element do va SUBTREE cua no rebuild.
Cac Element khac KHONG bi anh huong.

Vi du:
        App
       /   \
    Header   Body
             /  \
          List  *Counter*  ← setState() o day

Chi Counter va subtree cua no rebuild.
Header, Body, List — KHONG rebuild.

Tuong tu cho layout va paint:
- markNeedsLayout() → chi relayout subtree
- markNeedsPaint() → chi repaint subtree

Day la ly do Flutter nhanh du rebuild widget tree moi frame:
- Widget tree rebuild (tao object moi) — NHANH vi chi la allocation
- Element tree — REUSE, chi update dirty nodes
- RenderObject tree — Chi relayout/repaint dirty nodes
```

### 26.8 Khi nao KHONG tao RenderObject moi?

```dart
// TRUONG HOP 1: const widget — CUNG 1 INSTANCE qua cac frame
const SizedBox(height: 16)
// Lan build() 1: tao SizedBox instance A
// Lan build() 2: van la instance A (identical)
// → Element.update() thay oldWidget == newWidget → KHONG lam gi

// TRUONG HOP 2: canUpdate == true — REUSE Element va RenderObject
// Build lan 1: Text("Hello")  → TextElement → RenderParagraph
// Build lan 2: Text("World")  → canUpdate(Text, Text) == true
//   → REUSE TextElement
//   → Goi RenderParagraph.text = "World" (chi update property)
//   → KHONG tao RenderParagraph moi

// TRUONG HOP 3: canUpdate == false — TAO MOI tat ca
// Build lan 1: Text("Hello")    → TextElement → RenderParagraph
// Build lan 2: Icon(Icons.star)  → canUpdate(Text, Icon) == false
//   → Deactivate TextElement + RenderParagraph
//   → Tao IconElement + RenderParagraph moi
```

### 26.9 Container — Widget "gia" phuc tap nhat

```dart
// Container KHONG phai 1 widget don — no la COMPOSITION cua nhieu widget

Container(
  width: 100,
  height: 50,
  padding: EdgeInsets.all(8),
  margin: EdgeInsets.all(4),
  decoration: BoxDecoration(color: Colors.blue, borderRadius: ...),
  child: Text("Hello"),
)

// Thuc te tao ra widget tree:
Padding(                          // margin → Padding
  padding: EdgeInsets.all(4),
  child: ConstrainedBox(          // width/height → ConstrainedBox
    constraints: BoxConstraints.tightFor(width: 100, height: 50),
    child: DecoratedBox(          // decoration → DecoratedBox
      decoration: BoxDecoration(...),
      child: Padding(             // padding → Padding
        padding: EdgeInsets.all(8),
        child: Text("Hello"),
      ),
    ),
  ),
)

// Moi Padding, ConstrainedBox, DecoratedBox tao 1 RenderObject rieng
// → 4 RenderObjects cho 1 Container!
// Neu chi can padding → dung Padding truc tiep (1 RenderObject)
// Neu chi can color → dung ColoredBox truc tiep (1 RenderObject)
```

---

## A27. Widget Tree Diffing Algorithm Chi Tiet

### 27.1 Thuat toan so sanh (Reconciliation)

```
Khi parent rebuild, Flutter can so sanh OLD children vs NEW children
de quyet dinh: reuse, update, hay tao moi.

Thuat toan KHAC voi React:
- React dung key + heuristic O(n)
- Flutter dung key + LINEAR SCAN O(n)

BUOC 1: Scan tu dau den cuoi, match theo position
  old: [A, B, C, D]
  new: [A, B, E, D]

  index 0: canUpdate(A, A) → true → REUSE
  index 1: canUpdate(B, B) → true → REUSE
  index 2: canUpdate(C, E) → false → STOP top scan

BUOC 2: Scan tu cuoi ve dau
  old: [A, B, C, D]
  new: [A, B, E, D]

  last: canUpdate(D, D) → true → REUSE

BUOC 3: Xu ly phan giua (dung key de match)
  old remaining: [C]
  new remaining: [E]
  → C bi deactivate, E duoc tao moi

KET QUA:
  A → reuse
  B → reuse
  C → REMOVE (deactivate + unmount)
  E → CREATE NEW (createElement + mount)
  D → reuse
```

### 27.2 Key thay doi tat ca

```dart
// KHONG co key — match theo POSITION (index trong parent)
Column(children: [
  Text("Alice"),    // index 0
  Text("Bob"),      // index 1
])
// Doi thu tu:
Column(children: [
  Text("Bob"),      // index 0: canUpdate(Text,Text)=true → REUSE element cua "Alice"
  Text("Alice"),    // index 1: canUpdate(Text,Text)=true → REUSE element cua "Bob"
])
// → Chi UPDATE text property, KHONG move element
// → Hieu qua cho Text, NHUNG mat state cho StatefulWidget!

// CO key — match theo KEY (khong phai position)
Column(children: [
  Text("Alice", key: ValueKey("alice")),
  Text("Bob", key: ValueKey("bob")),
])
// Doi thu tu:
Column(children: [
  Text("Bob", key: ValueKey("bob")),      // Match key "bob" → reuse Bob's element
  Text("Alice", key: ValueKey("alice")),  // Match key "alice" → reuse Alice's element
])
// → MOVE element, giu nguyen state
```

### 27.3 GlobalKey — Di chuyen element GIUA cac parent

```dart
// GlobalKey cho phep 1 element SONG SOT khi di chuyen giua parent khac nhau

final key = GlobalKey();

// Frame 1: widget nam trong Column
Column(children: [
  MyStatefulWidget(key: key),  // Element A
  Text("other"),
])

// Frame 2: widget chuyen sang Stack
Stack(children: [
  MyStatefulWidget(key: key),  // CUNG Element A — duoc "reparent"
  Text("other"),
])

// Element A KHONG bi unmount + remount
// State cua no duoc GIU NGUYEN
// Day la dieu KHONG THE lam voi ValueKey (chi hoat dong trong cung parent)
```

---

## A28. Layer Tree va Compositing — GPU Rendering

### 28.1 Layer Tree la gi?

```
Sau khi Paint xong, Flutter KHONG gui pixel cho GPU.
No gui LAYER TREE — mot cay cac "display list commands".

RenderObject Tree          Layer Tree
RenderView                 TransformLayer (root)
  └── RenderFlex              └── OffsetLayer
       ├── RenderParagraph         ├── PictureLayer (text "A")
       └── RenderOpacity           └── OpacityLayer
            └── RenderImage              └── PictureLayer (image)

Cac loai Layer:
- PictureLayer    → chua danh sach lenh ve (rect, text, path, ...)
- ContainerLayer  → nhom cac layer con
- OffsetLayer     → dich chuyen vi tri
- ClipRectLayer   → cat hinh chu nhat
- OpacityLayer    → thay doi do trong suot
- TransformLayer  → phep bien doi (rotate, scale, ...)

TAI SAO dung Layer thay vi ve truc tiep?
→ GPU co the CACHE layer va chi ve lai layer thay doi
→ Animations chi thay doi 1 layer (vd: OpacityLayer) → khong repaint widget
→ Day la nguyen ly cua RepaintBoundary
```

### 28.2 RepaintBoundary — Tao Layer rieng

```dart
// Mac dinh, nhieu RenderObject CHIA SE 1 PictureLayer
// Khi 1 cai markNeedsPaint → ca layer bi ve lai

// RepaintBoundary tao 1 layer RIENG
// → Paint chi anh huong layer do, khong lan sang layer khac

// TRUOC:
Column(children: [
  HeavyChart(),           // |
  AnimatedCounter(),       // | ← Cung 1 PictureLayer
])                         //   AnimatedCounter repaint → HeavyChart cung bi repaint!

// SAU:
Column(children: [
  RepaintBoundary(         // | ← PictureLayer 1 (rieng)
    child: HeavyChart(),   // |
  ),                       //
  AnimatedCounter(),       // ← PictureLayer 2 (rieng)
])                         //   AnimatedCounter repaint → CHI repaint layer 2
```

### 28.3 Compositing Pipeline

```
Layer Tree
     │
     ▼
SceneBuilder (Dart)
     │  Duyet layer tree, tao Scene object
     │  Scene = tap hop cac GPU commands
     ▼
window.render(scene) → gui cho Engine
     │
     ▼
Flutter Engine (C++)
     │  Nhan Scene
     │  Chuyen thanh GPU commands
     ▼
Skia / Impeller
     │  GPU rendering
     │  Skia: mature, OpenGL/Vulkan
     │  Impeller: moi, Metal/Vulkan, less jank
     ▼
GPU Hardware
     │  Rasterize triangles
     │  Output framebuffer
     ▼
Display Controller
     │  Doc framebuffer
     ▼
Pixel tren man hinh
```

### 28.4 Impeller vs Skia

```
Skia (cu, mac dinh tren Android):
  - Compile shader TAI RUNTIME → jank lan dau (shader compilation jank)
  - Mature, ho tro nhieu GPU
  - OpenGL ES / Vulkan backend

Impeller (moi, mac dinh tren iOS, dang len Android):
  - PRE-COMPILE shader luc build → khong jank
  - Metal (iOS/macOS) / Vulkan (Android) backend
  - Tessellation-based rendering
  - Predictable performance
  - KHONG co shader compilation jank

Flutter 3.x+:
  - iOS: Impeller mac dinh (bat buoc tu Flutter 3.16)
  - Android: Impeller optional (dang beta)
  - Desktop: Skia (Impeller chua ho tro)
```

---

## A29. Layout Chi Tiet — Constraints Van De Thuong Gap

### 29.1 Quy tac vang: Constraints go down, Sizes go up, Parent sets position

```
         ┌──── Parent ────┐
         │                 │
         │  "Con oi, con   │
         │  duoc rong 0-300│  CONSTRAINTS GO DOWN
         │  va cao 0-600"  │  (parent noi con: "con duoc phep lon nhu nay")
         │        │        │
         │        ▼        │
         │   ┌── Child ──┐ │
         │   │            │ │
         │   │ "OK, con   │ │
         │   │ chon rong  │ │  SIZES GO UP
         │   │ 200, cao   │ │  (child tu quyet dinh size trong constraints)
         │   │ 100"       │ │
         │   └────────────┘ │
         │        │        │
         │   Parent dat    │  PARENT SETS POSITION
         │   child tai     │  (child KHONG biet vi tri cua minh)
         │   (50, 100)     │
         └─────────────────┘
```

### 29.2 BoxConstraints

```dart
BoxConstraints(
  minWidth: 0,     // Con PHAI it nhat rong 0
  maxWidth: 300,   // Con KHONG duoc rong hon 300
  minHeight: 0,
  maxHeight: 600,
)

// Tight constraint: size CO DINH (min == max)
BoxConstraints.tight(Size(200, 100))
// → Con PHAI dung 200x100, khong co lua chon

// Loose constraint: tu 0 den max
BoxConstraints.loose(Size(200, 100))
// → Con chon bat ky size nao tu 0x0 den 200x100

// Unbounded: khong gioi han (dung trong scrollable)
BoxConstraints(maxHeight: double.infinity)
// → Con chon bat ky height nao
```

### 29.3 Loi thuong gap va cach fix

```dart
// LOI 1: "RenderFlex children have non-zero flex but incoming height constraints are unbounded"
// Nguyen nhan: Column trong Column (hoac ListView) ma khong co gioi han
Column(
  children: [
    Column(            // Column ngoai gui height=infinity cho Column trong
      children: [
        Expanded(...)  // Expanded can height gioi han → LOI
      ],
    ),
  ],
)
// Fix: Wrap inner Column trong SizedBox hoac Expanded
Column(children: [
  Expanded(child: Column(children: [Expanded(...)]))  // OK
])

// LOI 2: "A RenderFlex overflowed by 20 pixels on the bottom"
// Nguyen nhan: Noi dung lon hon khong gian cho phep
Row(children: [
  Text("Very long text that exceeds the available width......")
])
// Fix: Wrap trong Flexible hoac Expanded
Row(children: [
  Flexible(child: Text("...", overflow: TextOverflow.ellipsis))
])

// LOI 3: "BoxConstraints forces an infinite width/height"
// Nguyen nhan: Unbounded constraint truyen cho widget can bounded
ListView(
  children: [
    Row(children: [Expanded(child: Text("..."))]) // Row trong ListView
  ],
)
// Row nhan width=infinity tu ListView
// Expanded expand den infinity → LOI
// Fix: Wrap Row trong SizedBox voi width cu the

// LOI 4: "setState() called after dispose()"
// Khong phai loi layout nhung rat thuong gap
// Fix: check `if (mounted) setState(() {});`
```

### 29.4 Intrinsic Dimensions — Hoi size truoc khi layout

```dart
// Binh thuong: parent GUI constraints → child TRA size (1 luot)
// Intrinsic: parent HOI "neu constraints la X, con se chon size bao nhieu?"
//            → roi parent dung thong tin do de tinh constraints that

// Vi du: IntrinsicHeight
IntrinsicHeight(
  child: Row(
    children: [
      Container(color: Colors.red, width: 50),    // Height = ?
      Container(color: Colors.blue, width: 50, height: 100),  // Height = 100
    ],
  ),
)
// IntrinsicHeight hoi: "Row, neu khong gioi han height, con cao bao nhieu?"
// Row tra loi: "100" (cao nhat cua children)
// IntrinsicHeight set tight constraint height=100 cho Row
// → Container do CUNG cao 100

// CANH BAO: Intrinsic dimensions lam layout chay 2 LAN (hoi + layout)
// Chi dung khi CAN THIET — anh huong performance neu dung qua nhieu
```

---

## A30. Hot Reload va Hot Restart — Cach Flutter Cap Nhat Code

### 30.1 Hot Reload (nhanh, giu state)

```
Ban save file → Flutter phat hien thay doi

1. Dart VM nhan code moi (incremental compilation)
2. VM thay the class definitions TRONG MEMORY
   (method bodies, field initializers)
3. Framework goi reassemble() tren root element
4. reassemble() → markNeedsBuild() cho TOAN BO tree
5. Tat ca element rebuild voi code MOI nhung STATE CU

KHONG reset:
- State objects (_MyState)
- Global variables
- Static fields
- Constructor parameters da luu

CO reset:
- build() method output
- initState() KHONG chay lai (State da ton tai)
- Constructor body KHONG chay lai
```

### 30.2 Hot Restart (cham hon, reset state)

```
1. Dart VM huy toan bo state
2. main() chay lai tu dau
3. initState() chay lai cho tat ca widget
4. Global variables reset
5. Navigation reset ve root

Khi nao can Hot Restart thay vi Hot Reload:
- Thay doi initState() logic
- Thay doi global/static variables
- Thay doi enum values
- Thay doi generic type parameters
- Thay doi native code
```

### 30.3 Tai sao Hot Reload nhanh?

```
Debug mode: Dart VM chay JIT (Just-In-Time compilation)
  → Co the thay doi code trong memory
  → Khong can compile lai toan bo

Release mode: Dart VM chay AOT (Ahead-Of-Time compilation)
  → Code da duoc compile thanh machine code
  → KHONG co hot reload
  → Nhanh hon JIT 2-5x

Profile mode: AOT + debug tools
  → Performance gan nhu release
  → Van co observatory, timeline
```

---

## A31. Dart Compilation — JIT vs AOT

### 31.1 Debug Mode (JIT)

```
Source Code (.dart)
      │
      ▼
  Dart Frontend
  (parse → AST → Kernel binary)
      │
      ▼
  Dart VM (JIT)
  - Load kernel binary
  - Interpret hoac JIT compile tung function khi can
  - Co the thay doi code tai runtime (hot reload)
  - Cham hon AOT nhung flexible hon

Uu diem:
  ✓ Hot reload
  ✓ Debug tools (breakpoints, inspector)
  ✓ assert() statements hoat dong

Nhuoc diem:
  ✗ Cham hon release 2-5x
  ✗ App size lon hon (chua ca VM)
  ✗ Startup cham (parse + compile)
```

### 31.2 Release Mode (AOT)

```
Source Code (.dart)
      │
      ▼
  Dart Frontend
  (parse → AST → Kernel binary)
      │
      ▼
  Dart AOT Compiler
  (Kernel → machine code)
  - Tree shaking: loai bo code khong dung
  - Type flow analysis: toi uu dispatch
  - Inlining: inline small functions
      │
      ▼
  Native Machine Code (.so / framework)
  - Chay truc tiep tren CPU
  - Khong can VM interpreter
  - Startup nhanh
  - Runtime nhanh

Uu diem:
  ✓ Performance toi da
  ✓ App size nho hon (tree shaking)
  ✓ Startup nhanh
  ✓ Predictable performance

Nhuoc diem:
  ✗ Khong co hot reload
  ✗ Khong co debug tools
  ✗ assert() bi loai bo
  ✗ Build cham hon
```

---

# PHAN B: KIEN THUC DU AN

## 1. Tong quan du an

Pancake Work la ung dung chat va quan ly cong viec da nen tang (iOS, Android, macOS, Windows), xay dung bang Flutter.

### Cac package chinh

| Package | Chuc nang |
|---------|-----------|
| `pancake_work_core` | State management, domain logic, repositories, providers, view models |
| `pancake_work_ui` | Design system (colors, typography, shadows, components) |
| `pancake_work_sdk` | Auto-generated OpenAPI client (Dart/Dio) |
| `pancake_work_intl` | Internationalization (da ngon ngu) |
| `pancake_work_message_kit` | He thong render tin nhan |
| `pancake_work_message_composer` | Widget soan tin nhan |
| `pancake_work_wm` | Module quan ly cong viec (Work Management) |
| `pancake_work_utils` | Utilities (logging, feature flags) |
| `pancake_work_telemetry` | Thu thap hieu nang |

### Cong nghe su dung

- **Flutter** 3.41.4 (Dart >=3.9.0)
- **State Management**: Provider + ChangeNotifier + ViewModel pattern
- **Networking**: Dio + auto-generated SDK tu OpenAPI
- **Real-time**: WebSocket (Phoenix protocol)
- **Local Storage**: SharedPreferences, KVStorage (session + persistent)
- **Error Tracking**: Sentry
- **Feature Flags**: GrowthBook
- **Push Notifications**: Firebase Cloud Messaging (mobile)
- **Auto-update**: Sparkle (macOS)

---

## 2. Cau truc thu muc

```
pancake-work-client/
├── desktop/                    # Desktop app (macOS, Windows)
│   ├── lib/
│   │   ├── main.dart           # Entry point
│   │   ├── env/                # Environment configs (DevConfig, ProdConfig, TestConfig)
│   │   ├── pancake_work_desktop/
│   │   │   ├── domain/
│   │   │   │   ├── providers/  # AppUIProvider, AppUpdaterProvider
│   │   │   │   └── use_cases/  # SwitchToChannel, InitializeAppData, etc.
│   │   │   ├── ui/
│   │   │   │   ├── core/       # AppViewScope, AppNavigationState
│   │   │   │   ├── main_layout/# PrimaryPanel, NavigationSidebar
│   │   │   │   └── workspace/  # Workspace screens
│   │   │   └── services/       # SocketLifecycleService, AppLinksService
│   │   ├── providers/          # Desktop-specific providers
│   │   ├── components/         # Desktop-specific widgets (63+ files)
│   │   └── controllers/        # Feature controllers
│   └── macos/                  # macOS native config
│
├── mobile/                     # Mobile app (iOS, Android)
│   ├── lib/
│   │   ├── main.dart           # Entry point
│   │   └── env/                # Environment configs (DevConfig, ProdConfig)
│   ├── ios/                    # iOS native config
│   └── android/                # Android native config
│
├── packages/
│   ├── pancake_work_core/      # Core business logic
│   │   ├── lib/
│   │   │   ├── ui/view_models/ # ViewModel implementations
│   │   │   ├── data/
│   │   │   │   ├── data_sources/   # RemoteDataSource, SocketDataSource, KVStorage
│   │   │   │   ├── repositories/   # 20+ repositories
│   │   │   │   └── models/         # Data models
│   │   │   ├── domain/
│   │   │   │   ├── providers/      # 25+ ChangeNotifier providers
│   │   │   │   └── use_cases/      # Business logic
│   │   │   └── helpers/
│   │   │       ├── command.dart    # Command pattern
│   │   │       └── socket_handler_mixin.dart
│   │
│   ├── pancake_work_ui/        # Design system
│   │   ├── lib/
│   │   │   ├── design_system/      # Button, Modal, Dropdown, Input, etc.
│   │   │   ├── pancake_work_colors.dart
│   │   │   ├── pancake_work_typos.dart
│   │   │   ├── pancake_work_shadows.dart
│   │   │   └── pancake_work_icons.dart
│   │
│   ├── pancake_work_sdk/       # Auto-generated API client
│   ├── pancake_work_intl/      # Translations (ARB files)
│   └── pancake_work_message_kit/ # Message rendering system
│
├── scripts/                    # Build & codegen scripts
├── .github/workflows/          # CI/CD pipelines
├── conventions/                # Code conventions docs
└── mise.toml                   # Task runner config
```

---

## 3. Flavor va Environment

### 3.1 Cac flavor

| Flavor | Platform | Bundle ID | Moi truong |
|--------|----------|-----------|------------|
| **dev** | Mobile + Desktop | `vn.pancake.chat.dev` | Development/Staging |
| **prod** | Mobile + Desktop | `vn.pancake.chat` | Production |
| **test** | Desktop only | `vn.pancake.chat.test` | Testing |

### 3.2 Cach chay

Flavor **bat buoc** phai truyen qua `--dart-define`:

```bash
# Mobile dev
flutter run --flavor dev --dart-define=FLAVOR=dev

# Mobile prod
flutter run --flavor prod --dart-define=FLAVOR=prod

# Desktop (macOS)
flutter run -d macos --dart-define=FLAVOR=dev

# Voi mise task
mise run desktop              # macOS dev
mise run mobile dev            # Mobile dev
mise run mobile prod           # Mobile prod
```

### 3.3 Environment Config

Moi flavor co class config rieng:

```dart
// desktop/lib/env/dev_config.dart
class DevConfig extends EnvConfig {
  String get env => "dev";
  String get appId => "vn.pancake.chat.dev";
  String get appName => "Pancake Work Dev";
  String get appScheme => "wcake-dev";
  String get baseUrl => _resolveBaseUrl();  // Dynamic based on SERVER dart-define
  String get baseWebUrl => _resolveBaseWebUrl();
  String get growthBookClientKey => "sdk-Y631ep5FROf0zOYT";
  String get sentryDsn => "";  // No Sentry in dev
}
```

### 3.4 Bien moi truong (dart-define)

| Bien | Muc dich | Vi du |
|------|----------|-------|
| `FLAVOR` | **Bat buoc.** Chon dev/prod config | `--dart-define=FLAVOR=dev` |
| `SERVER` | Override base URL (chi dev) | `--dart-define=SERVER=local` |
| `DEBUG_BASE_URL` | Custom local server URL | `--dart-define=DEBUG_BASE_URL=https://localhost:6001` |
| `DEBUG_USER_TOKEN` | Debug user token (skip login) | Tu dinh nghia |
| `FULL_VERSION` | Override version (CI/CD) | CI tu truyen |
| `BENCHMARK` | Bat benchmark mode | `--dart-define=BENCHMARK=true` |

### 3.5 Base URL Resolution (dev flavor)

```dart
String get baseUrl {
  const server = String.fromEnvironment("SERVER");
  return switch (server) {
    "local" => "https://localhost:6001",
    "dev"   => "https://dev.pancakework.vn",
    "prod"  => "https://pancakework.vn",
    _       => "https://dev.pancakework.vn",  // default
  };
}
```

---

## 4. Firebase

### 4.1 Cau hinh

- **Firebase Project**: `pancake-chat`
- **Database URL**: `https://pancake-chat.firebaseio.com`
- **Storage Bucket**: `pancake-chat.appspot.com`
- **GCM Sender ID**: `592269086567`

### 4.2 Tinh nang su dung

| Tinh nang | Trang thai | Ghi chu |
|-----------|-----------|---------|
| Firebase Cloud Messaging | **Bat** | Push notifications (mobile only) |
| Firebase Analytics | **Tat** | `IS_ANALYTICS_ENABLED: false` |
| Firebase Crashlytics | **Khong dung** | Dung Sentry thay the |
| Firebase Remote Config | **Khong dung** | Dung GrowthBook |
| Firebase Auth | **Khong dung** | Dung OAuth custom (Pancake ID) |

### 4.3 Push Notifications

**Mobile (Android)**:
```kotlin
// MyFirebaseMessagingService.kt
class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // Handle: call, card_comment, issue_comment, attendance, DM
    }
}
```

**Mobile (Dart)**:
```dart
// Background handler
@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async { ... }

// Initialization
await Firebase.initializeApp();
```

**Desktop**: Khong dung Firebase. Dung native notifications qua `flutter_local_notifications`.

### 4.4 File cau hinh

- iOS: `/mobile/ios/Runner/GoogleService/GoogleService-Info.plist`
- iOS Dev: `/mobile/ios/Runner/GoogleService/GoogleService-Info-Dev.plist`
- Android: Google Services plugin trong `build.gradle`
- Dart: `/mobile/lib/firebase_options.dart` (auto-generated)

---

## 5. Ket noi API (SDK)

### 5.1 Kien truc

```
UI Layer
  └── ViewModel / Provider
        └── Repository (workspace_repository.dart, channel_repository.dart, ...)
              └── RemoteDataSource
                    └── PancakeWorkSdk (auto-generated)
                          └── Dio (HTTP client)
                                └── BearerAuthInterceptor (JWT token)
```

### 5.2 RemoteDataSource

```dart
// packages/pancake_work_core/lib/data/data_sources/remote_data_source.dart
class RemoteDataSource {
  late final PancakeWorkSdk _sdk;

  RemoteDataSource({required String baseUrl, List<Interceptor> additionalInterceptors = const []}) {
    _sdk = PancakeWorkSdk(
      dio: Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: 10000),
        receiveTimeout: Duration(milliseconds: 10000),
      )),
      interceptors: [
        BearerAuthInterceptor(),        // JWT token injection
        _ErrorHandlerInterceptor(),     // Parse API errors
        ...additionalInterceptors,
      ],
    );
  }

  PancakeWorkSdk get sdk => _sdk;

  void setAccessToken(String token) {
    _sdk.setBearerAuth('jwtAuth', token);
  }
}
```

### 5.3 Repository Pattern

```dart
// packages/pancake_work_core/lib/data/repositories/workspace_repository.dart
class WorkspaceRepository {
  final RemoteDataSource remoteDataSource;

  // API calls thong qua SDK
  Future<List<sdk.ValidateInviteIdentifiersResponseV2Inner>> validateInviteIdentifiersV2({
    required int workspaceId,
    required List<String> identifiers,
  }) async {
    final api = remoteDataSource.sdk.getWorkspaceApi();
    final result = await api.validateWorkspaceInviteIdentifiersV2(
      workspaceId: workspaceId,
      inviteWorkspaceToRequestV2: sdk.InviteWorkspaceToRequestV2(identifiers: identifiers),
    );
    return result.data!;
  }
}
```

### 5.4 Error Handling

```dart
// RemoteDataSource wraps DioException thanh RemoteDataSourceError
class RemoteDataSourceError {
  final String? errorCode;     // Ma loi tu API
  final dynamic parsedError;   // Structured error object
  final DioException original; // Original exception
}

// Su dung .showError() extension de hien thi snackbar
final result = await api.updateChannel(...).showError();
```

### 5.5 Interceptor Chain

```
Request Flow:
  App Code
    → BearerAuthInterceptor (add Authorization header)
    → _ErrorHandlerInterceptor (parse error responses)
    → Dio (HTTP call)
    → Server Response
    → _ErrorHandlerInterceptor (wrap errors)
    → App Code
```

---

## 6. Bao mat JWT

### 6.1 Luong xac thuc

```
1. App khoi dong
   └── Doc cached token tu SharedPreferences (key: "userData")
       ├── Co token → MeProvider.authenticate(AutoLoginAction())
       │              └── setAccessToken() → API ready
       │              └── Connect WebSocket voi token
       └── Khong co token → Hien man hinh dang nhap
                            └── OAuth voi Pancake ID
                            └── Nhan token → Luu vao SharedPreferences
                            └── setAccessToken() → API ready
```

### 6.2 Token Storage

```dart
// SharedPreferenceDataSource
// Key: "userData" → JSON: {'token': accessToken, 'userId': userId, ...}
// Key: "refreshToken" → Refresh token
// Key: "credentials" → Stored credentials

// Doc token
String? _getCachedAccessToken() {
  final userData = SharedPreferenceDataSource.instance
    .sharedPreferences.getString('userData');
  if (userData == null) return null;
  return json.decode(userData)['token'];
}
```

### 6.3 Token trong API Request

```dart
// BearerAuthInterceptor (auto-generated trong SDK)
class BearerAuthInterceptor extends AuthInterceptor {
  final Map<String, String> tokens = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Tim auth info tu route metadata
    final authInfo = getAuthInfo(options,
      (secure) => secure['type'] == 'http' && secure['scheme'] == 'bearer');

    for (final info in authInfo) {
      final token = tokens[info['name']];
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        break;
      }
    }
    super.onRequest(options, handler);
  }
}
```

### 6.4 Token trong WebSocket

```dart
// Token truyen trong join payload cua moi topic
class UserSocketTopic extends SocketTopic {
  Map<String, dynamic> get joinPayload => {
    'device_id': deviceId,
    'access_token': accessToken,  // JWT token
  };
}

class WorkspaceSocketTopic extends SocketTopic {
  Map<String, dynamic> get joinPayload => {
    'access_token': accessToken,  // JWT token
  };
}
```

### 6.5 Authentication State Machine

```dart
// MeProvider quan ly trang thai xac thuc
sealed class AuthenticationState {}

class NotLoggedIn extends AuthenticationState {}
class PreviouslyLoggedIn extends AuthenticationState {
  final String accessToken;
}
class LoggingIn extends AuthenticationState {}
class LoggedIn extends AuthenticationState {
  final String accessToken;
  final Me user;
}
```

---

## 7. WebSocket va Real-time

### 7.1 Kien truc tong quan

```
SocketDataSource (Singleton)
├── SocketConnection (low-level WebSocket)
│   ├── Heartbeat: ping moi 10 giay
│   ├── Timeout: 30 giay cho response
│   └── Connection timeout: 10 giay
├── SocketChannel (per-topic channel)
│   ├── UserSocketTopic (per user)
│   └── WorkspaceSocketTopic (per workspace)
└── Event Handlers (registered by providers)
```

### 7.2 State Machine

```
SocketDataSource States:
  _Idle ──connect()──► _Connecting ──success──► _Connected
                         ▲  (retry with exponential backoff, max 5s)
                         │
                         └── suspend() ──► _Suspended
                                            │ (topics & handlers preserved)
                                            │ resume/reconnect
                                            ▼
                                          _Connecting
```

### 7.3 Ket noi

```dart
// URL format
Utils.socketUrl = "wss://${baseUrlWithoutScheme}/socket/websocket";

// Ket noi
SocketDataSource.instance.connect(
  url: Utils.socketUrl,
  topics: [
    UserSocketTopic(userId: userId, deviceId: deviceId, accessToken: token),
    WorkspaceSocketTopic(workspaceId: wsId, accessToken: token),
  ],
);
```

### 7.4 Event Handler Registration

```dart
// Providers dung SocketHandlerMixin de dang ky handler
class ChannelsProviderV2 with ChangeNotifier, SocketHandlerMixin {
  @override
  SocketDataSource get socketDataSource => _socketDataSource;

  ChannelsProviderV2(...) {
    // Dang ky typed event handlers
    addSocketHandler<UserChannelReadActivityEvent>(_readChannel);
    addSocketHandler<UserChannelJoinedEvent>(_userChannelJoined);

    // Handler khi reconnect
    addSocketReconnectedHandler(_onReconnected);
  }

  void _readChannel(UserChannelReadActivityEvent event) {
    // Xu ly event, update state
    notifyListeners();
  }
}
```

### 7.5 Socket Events (Auto-generated)

Events duoc generate tu OpenAPI spec:

```dart
// Generated: packages/pancake_work_core/lib/.../generated/socket_events.dart
class ChannelMessageCreatedEvent extends ReceiveEvent {
  final String messageId;
  final int channelId;
  // ... typed properties from OpenAPI schema
  factory ChannelMessageCreatedEvent.fromRawEvent(RawEvent raw) { ... }
}

// 50+ event types: UserChannelReadActivityEvent, AppUserUpdatedEvent,
// WorkspaceCreatedEvent, MentionNewEvent, MentionDeletedEvent, etc.
```

### 7.6 Lifecycle Management (Desktop)

```dart
// SocketLifecycleService quan ly suspend/resume
class SocketLifecycleService {
  // Suspend khi OS sleep/lock
  // Resume khi OS wake/unlock
  // Reconnect khi network thay doi (connectivity_plus)
}
```

---

## 8. State Management

### 8.1 Provider Tree

```
MultiProvider (app root)
├── DataSources Layer
│   ├── RemoteDataSource
│   ├── SessionKvStorage
│   ├── PersistentKvStorage
│   └── SharedPreferenceDataSource
│
├── Repositories Layer (25+)
│   ├── ChannelRepository
│   ├── WorkspaceRepository
│   ├── ChannelMessagesRepository
│   ├── MeRepository
│   ├── FileRepository
│   └── ... (20+ more)
│
├── Providers Layer (ChangeNotifier)
│   ├── MeProvider (authentication)
│   ├── ChannelsProviderV2 (channels + socket)
│   ├── WorkspacesProviderV2 (workspaces)
│   ├── ChannelMessagesProvider (messages)
│   ├── AppUIProvider (navigation - desktop)
│   ├── AppUsersProvider (user profiles)
│   ├── MentionProvider (mentions)
│   └── ... (15+ more)
│
└── UseCases Layer
    ├── SendMessageUseCase
    ├── SwitchToChannelUseCase
    ├── InitializeAppDataUseCase
    └── ...
```

### 8.2 ViewModel Pattern

```dart
// Convention: WidgetName → WidgetNameViewModel
class InviteToWorkspaceViewModelV2 extends ChangeNotifier {
  // Inject dependencies, KHONG truyen context
  InviteToWorkspaceViewModelV2({
    required WorkspaceRepository repository,
    required int workspaceId,
  });

  // State
  List<InviteIdentifierInputItem> _allInviteIdentifiers = [];

  // Computed properties
  bool get canInvite => _allInviteIdentifiers.every((e) => e is ValidInviteIdentifier);

  // Async operations dung Command pattern
  late final Command0<void> validateUsers = Command0<void>(_validateInviteIdentifiers);

  // Methods thay doi state
  void changeTab({required type}) {
    _currentType = type;
    notifyListeners();
  }
}
```

### 8.3 Widget su dung ViewModel

```dart
class InviteToWorkspace extends StatefulWidget {
  @override
  State createState() => _InviteToWorkspaceState();
}

class _InviteToWorkspaceState extends State<InviteToWorkspace> {
  late final _viewModel = InviteToWorkspaceViewModelV2(
    repository: context.read<WorkspaceRepository>(),
    workspaceId: widget.workspaceId,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Column(children: [
          // Dung _viewModel.xxx de doc state
          if (_viewModel.canInvite) InviteButton(onTap: _viewModel.inviteToWorkspace),
        ]);
      },
    );
  }
}
```

### 8.4 Command Pattern (Async UI State)

```dart
// packages/pancake_work_core/lib/helpers/command.dart
enum Status { idle, running, success, error }

// Command0<T> - khong co argument
// Command1<T, A> - 1 argument

// Khai bao
late final Command0<void> validateUsers = Command0<void>(_validateInviteIdentifiers);

// Thuc thi
await validateUsers.execute();

// Doc trang thai
validateUsers.running  // true/false
validateUsers.status   // idle, running, success, error
validateUsers.result   // T? - ket qua

// Trong UI
switch (command.status) {
  case Status.idle:    return Text("Idle");
  case Status.running: return CircularProgressIndicator();
  case Status.success: return Text("Done: ${command.result}");
  case Status.error:   return Text("Error");
}

// Voi design system Button
design_system.Button(
  loading: command.running,
  disabled: command.running,
  onTap: command.execute,
  text: "Validate",
)
```

---

## 9. Navigation System

### 9.1 AppView Hierarchy (Sealed Classes)

```dart
sealed class AppView {}

// Main view chua workspace tab va DM tab
class PrimaryView extends AppView {
  final DMView dmView;
  final WorkspaceView workspaceView;
  final AppActiveTab activeTab;  // workspace | directMessage
}

// Workspace views
sealed class WorkspaceView extends AppView {}
  class NoWorkspaceView extends WorkspaceView {}
  class ChannelMessagesView extends WorkspaceView { channelId, workspaceId }
  class WorkspaceMentionsView extends WorkspaceView { workspaceId }
  class WorkspaceThreadsView extends WorkspaceView { workspaceId }
  class WorkspaceInviteView extends WorkspaceView { workspaceId }
  class WorkspaceIntegrationView extends WorkspaceView { workspaceId, integrationId }

// DM views
sealed class DMView extends AppView {}
  class NoDMView extends DMView {}
  class DMMessagesView extends DMView { conversationId }

// Detail views (right panel)
sealed class DetailView extends AppView {}
  class ChannelDetailView extends DetailView { channelId, workspaceId }
  class ChannelMembersView extends DetailView { ... }

// Drawer views (slide-in panels)
sealed class DrawerView extends AppView {}
  class IssueDetailDrawer extends DrawerView { issueId, workspaceId, channelId }
  class TaskDetailDrawer extends DrawerView { taskId, workspaceId, channelId }
```

### 9.2 AppUIProvider (Navigation Controller)

```dart
class AppUIProvider extends ChangeNotifier {
  // Chuyen view
  void switchToChannelMessages({required channelId, required workspaceId});
  void switchToDMMessages({required conversationId});
  void switchToThreadsView({required workspaceId});
  void switchToMentionsView({required workspaceId});
  void switchToInviteView({required workspaceId});
  void switchToIntegrationView({required workspaceId, required integrationId});

  // Tab switching
  void switchToWorkspaceTab();
  void switchToDMTab();

  // Drawer management
  void openDrawer(DrawerView drawer);
  void closeDrawer();
  void closeAllDrawers();
}
```

### 9.3 AppViewScope (InheritedModel)

```dart
// Cung cap view state xuong widget tree
class AppViewScope extends InheritedModel<AppViewAspect> {
  final AppView state;

  // Truy cap
  static AppView of(BuildContext context, {required bool watch});
}

// Su dung
final workspaceId = AppViewScope.of(context, watch: true).currentWorkspaceId;
```

### 9.4 PrimaryPanel Rendering

```dart
// desktop/lib/pancake_work_desktop/ui/main_layout/primary_panel.dart
final child = switch (workspaceView) {
  WorkspaceMentionsView()       => MentionList(),
  WorkspaceThreadsView()        => ThreadsWorkspaceList(),
  WorkspaceInviteView(ws)       => InviteToWorkspaceScreen(workspaceId: ws),
  WorkspaceIntegrationView(...) => WorkspaceIntegrationDashboard(...),
  ChannelMessagesView()         => StackedMessagesView(),
  NoWorkspaceView()             => WelcomeScreen(),
};
```

### 9.5 Navigation Serialization

Navigation state duoc serialize/deserialize de khoi phuc khi restart app:

```dart
// serialization.dart
static Map<String, dynamic> _workspaceViewToJson(WorkspaceView view) {
  return switch (view) {
    ChannelMessagesView v => {'type': 'ChannelMessagesView', 'channelId': v.channelId, ...},
    WorkspaceInviteView v => {'type': 'WorkspaceInviteView', 'workspaceId': v.workspaceId},
    // ... tat ca WorkspaceView subclasses
  };
}
```

---

## 10. Design System

### 10.1 Colors

```dart
import 'package:pancake_work_ui/pancake_work_ui.dart';

// Truy cap truc tiep
Container(color: appColors.primary1)
Container(color: appColors.grey10)
Container(color: appColors.danger)

// Theme-aware (dark/light)
Container(
  color: appColors.color(
    dark: appColors.aquablue8,
    light: appColors.aquablue6,
  ),
)

// Cac nhom mau
// Grey:     grey1 - grey12 (light theme)
// DarkGrey: darkGrey1 - darkGrey15 (dark theme)
// Aquablue: aquablue1 - aquablue12
// Moss:     moss1 - moss12
// Cherry:   cherry1 - cherry12
// Semantic: primary1, danger, warning, info, success, caption, body1-4, etc.
```

### 10.2 Typography

```dart
import 'package:pancake_work_ui/pancake_work_ui.dart';

// Fluent style syntax
Text("Hello", style: appTypos.body1.semibold.textColor(appColors.primary1))
Text("Title", style: appTypos.headline3.bold)
Text("Caption", style: appTypos.caption.medium)

// Variants: body1, body2, headline1-3, title1-2, caption
// Weights: regular, medium, semibold, bold, extraBold
```

### 10.3 Shadows

```dart
import 'package:pancake_work_ui/pancake_work_ui.dart';

Container(
  decoration: BoxDecoration(boxShadow: appShadows.md),
)
```

### 10.4 Icons

```dart
import 'package:pancake_work_ui/pancake_work_icons.dart';

Icon(PancakeWorkIcons.check, color: _iconColor, size: 14)

// Them icon moi:
// 1. Them SVG vao packages/pancake_work_ui/assets/icons/
// 2. Chay: mise ui_gen_icon_font
// 3. Su dung: PancakeWorkIcons.tenIcon
```

### 10.5 Illustrations

```dart
import 'package:pancake_work_ui/pancake_work_ui.dart';

appIllustrations.emptyBox.width(120).height(120)
appIllustrations.memberList
```

### 10.6 Components (design_system prefix)

```dart
import 'package:pancake_work_ui/pancake_work_design_system.dart' as design_system;

// Button
design_system.Button(
  text: "Click me",
  type: design_system.ButtonType.primary,      // primary, danger, textGrey, filledTonalPrimary, ...
  size: design_system.ButtonSize.M,            // S, M, L, XL, XXL
  loading: isLoading,
  disabled: isDisabled,
  onTap: () { },
  icon: const design_system.ButtonIcon(icon: PhosphorIconsRegular.plus),
)

// Modal
design_system.Modal(
  width: 600,
  title: "Title",
  description: "Description",
  child: content,
)

// Dropdown
design_system.Dropdown(
  items: [
    design_system.DropdownItem(title: "Option 1", onTap: () {}),
    design_system.DropdownItem(title: "Danger", variant: design_system.DropdownItemVariant.danger),
  ],
  triggerContent: Text("Open"),
)

// Tooltip
design_system.Tooltip(text: "Hint text", child: icon)

// LoadingIndicator
design_system.LoadingIndicator(size: 24, description: "Loading...")

// ConfirmationModal
design_system.ConfirmationModal.show(
  context: context,
  title: "Delete?",
  description: "This cannot be undone",
  confirmButtonText: "Delete",
  confirmButtonType: design_system.ButtonType.danger,
  onConfirm: () async { ... },
)

// TabList
design_system.TabList(
  type: const design_system.Segmented(),
  tabs: [
    design_system.TabItem(text: "Tab 1", onTap: () {}),
    design_system.TabItem(text: "Tab 2", onTap: () {}),
  ],
)
```

---

## 11. Internationalization

### 11.1 Cau truc

```
packages/pancake_work_intl/lib/l10n/
├── common/
│   ├── intl_en.arb
│   ├── intl_vi.arb
│   └── intl_es.arb
├── channel/
│   ├── intl_en.arb
│   └── intl_vi.arb
├── message/
├── user/
├── workspace/
├── issue/
└── wm_task/
```

### 11.2 Su dung

```dart
import 'package:pancake_work_intl/generated/pancake_work_intl.dart';

// Truy cap theo module
Text(L.common.email)
Text(L.workspace.inviteToWorkspace)
Text(L.channel.pinnedCategory)
Text(L.message.editedMessage)

// Voi parameters
Text(L.workspace.invitedMembersSuccess(count))
Text(L.workspace.inviteBy(L.common.email))
```

### 11.3 Ngon ngu ho tro

- English (en)
- Vietnamese (vi)
- Spanish (es)

---

## 12. Message Kit

### 12.1 Kien truc 4 tang

```
packages/pancake_work_message_kit/lib/src/ui/
├── core/primitives/        # Thanh phan co ban
│   ├── UserMessageContent
│   ├── MessageReactionBar
│   ├── MessageToolbarRow
│   └── MessageToolbarOverlay
├── packs/                  # Assembled message tiles
│   ├── BaseMessageTile
│   ├── ChannelMessageTile
│   └── ChannelThreadMessageTile
└── renderers/              # Content renderers
    ├── RichTextRenderer
    └── AttachmentRenderer
```

### 12.2 Message Actions

```dart
class MessageAction {
  final String label;
  final IconData icon;
  final MessageActionCallback onExecute;
  final MessageActionVariant variant;  // normal, danger
}

class MessageActionsManager {
  List<MessageAction> get toolbarActions;      // Hien tren toolbar
  List<MessageAction> get contextMenuActions;  // Hien trong dropdown "more"
  bool get hasMoreActions;
}
```

---

## 13. CI/CD va Deployment

### 13.1 Release Channels

| Channel | Branch | Flavor | Moi truong |
|---------|--------|--------|------------|
| **alpha** | `develop` | dev | Development |
| **beta** | `main` | prod | Staging |
| **stable** | manual | prod | Production |
| **nightly** | manual | prod | Nightly builds |

### 13.2 Workflows

```
.github/workflows/
├── build_and_release.yaml              # Main trigger (PR merge)
├── build_and_release_ios.yaml          # iOS build + App Store
├── build_and_release_android.yaml      # Android build + Google Play
├── build_and_release_macos.yaml        # macOS Sparkle update
├── build_and_release_windows.yaml      # Windows build
├── tag_and_release.yaml                # Version tagging
├── create_release_pull_request.yaml    # Auto PR for releases
├── lint.yml                            # Code quality
├── test.yml                            # Automated tests
└── code_review.yml                     # AI code review
```

### 13.3 Build Flow

```
PR Merge to develop/main
  └── build_and_release.yaml
       ├── Determine flavor (develop→dev, main→prod)
       ├── Run codegen (SDK, socket events, translations)
       └── Dispatch platform builds:
            ├── iOS: Xcode 16.2.0 + Fastlane + App Store
            ├── Android: Java 17 + Fastlane + Google Play
            ├── macOS: Sparkle framework + auto-update feed
            └── Windows: Manual dispatch
```

### 13.4 Build Number

```bash
# Android: Minutes since 2025-01-01 + 4000000
build_number = (minutes_since_epoch - minutes_at_2025_01_01) + 4000000
```

### 13.5 macOS Auto-update (Sparkle)

```
Feed URL: https://pancakework.vn/downloads/beta/latest/pancakework_appcast_macos.xml
Version format: {version}-{channel}.{YYMMDD}  (e.g., 1.2.0-beta.260418)
```

---

## 14. Codegen va SDK Generation

### 14.1 Chay codegen

```bash
# Generate tat ca (SDK + error codes + socket events + notification payloads)
mise sdk_gen remote

# Chi generate SDK
mise sdk_gen remote --only=sdk

# Tu local server
mise sdk_gen local --only=sdk

# Chi socket events
mise sdk_gen remote --only=socket_events
```

### 14.2 Quy trinh generate SDK

```
1. Download OpenAPI spec tu server
   - Remote: https://dev.pancakework.vn/api/v2/openapi/index.yaml
   - Local:  https://localhost:6001/api/v2/openapi/index.yaml

2. Chay OpenAPI Generator (Docker)
   - Image: openapitools/openapi-generator-cli:v7.16.0
   - Generator: dart-dio
   - Output: packages/pancake_work_sdk/

3. Build runner
   cd packages/pancake_work_sdk && dart run build_runner build
```

### 14.3 Cac loai codegen

| Loai | Source | Output |
|------|--------|--------|
| SDK (API client) | OpenAPI spec | `packages/pancake_work_sdk/` |
| Error codes | `error_codes.yaml` | `packages/pancake_work_core/lib/helpers/errors/generated/` |
| Socket events | OpenAPI spec (Socket tag) | `packages/pancake_work_core/lib/.../generated/socket_events.dart` |
| Notification payloads | `notification_payloads.yaml` | `packages/pancake_work_core/lib/.../generated/notification_payload.dart` |
| Icon font | SVG files | `packages/pancake_work_ui/lib/pancake_work_icons.dart` |
| Translations | ARB files | `packages/pancake_work_intl/lib/generated/` |

---

## 15. Testing

### 15.1 Chay test

```bash
# Test theo package
mise test ui --path test/design_system/dropdown_test.dart
mise test core --path test/ui/view_models/invite_to_workspace_view_model_test.dart

# E2E tests
mise run test_e2e
```

### 15.2 Lint va format

```bash
# Fix imports va format
mise run fix <file_path_1> <file_path_2> ...
```

---

## 16. Cac Pattern Quan Trong

### 16.1 Sealed Classes cho Data Modeling

```dart
// Thay vi enum, dung sealed class de co typed variants
sealed class InviteIdentifierInputItem {
  final String identifier;
  final String originalInput;
}

class PendingInviteIdentifier extends InviteIdentifierInputItem { }
class ValidInviteIdentifier extends InviteIdentifierInputItem {
  final WorkspaceInviteBasicUserInfo userBasicInfo;
  void onEdit() => _viewModel._editInviteIdentifier(identifier);
  void onDelete() => _viewModel._removeInviteIdentifier(identifier);
}
class NotExistsInviteIdentifier extends ErroredInviteIdentifier {
  void onEdit() => ...;
  void onDelete() => ...;
}

// Compiler bat buoc xu ly tat ca case
switch (item) {
  case PendingInviteIdentifier():   ...
  case ValidInviteIdentifier():     ...
  case NotExistsInviteIdentifier(): ...
  // Thieu case → compiler error
}
```

### 16.2 SocketHandlerMixin

```dart
mixin SocketHandlerMixin on ChangeNotifier {
  SocketDataSource get socketDataSource;

  void addSocketHandler<T extends ReceiveEvent>(EventHandler<T> handler) {
    socketDataSource.addHandler<T>(handler);
    _disposers.add(() => socketDataSource.removeHandler<T>(handler));
  }

  // Auto-dispose khi provider bi dispose
  @override
  void dispose() {
    for (final disposer in _disposers) disposer();
    super.dispose();
  }
}
```

### 16.3 ProviderCache

```dart
ProviderCache<List<UserChannel>>(
  cachePrefix: 'v1/workspaces',
  ttl: const Duration(days: 3),
  storage: sessionKvStorage,
)
```

### 16.4 UIStateDelegate (Architecture Inversion)

```dart
// Providers khong phu thuoc vao navigation UI
// Thay vao do, notify qua UIStateDelegate interface
// Desktop va mobile implement khac nhau
```

### 16.5 Feature Flags (GrowthBook)

```dart
// Khoi tao
await PancakeWorkFeatureFlag.initialize(
  AppEnvironment.instance.config.growthBookClientKey,
);

// Su dung
if (PancakeWorkFeatureFlag.isEnabled('new_invite_flow')) {
  // Show new UI
}
```

### 16.6 Error Reporting (Sentry)

```dart
await SentryFlutter.init((options) {
  options.dsn = AppEnvironment.instance.config.sentryDsn;
  options.environment = AppEnvironment.instance.config.env;
  options.release = '${packageInfo.packageName}@$version+${packageInfo.buildNumber}';
  options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
});
```

---

## Phu luc: Cac lenh thuong dung

```bash
# Chay app
mise run desktop                          # macOS dev
mise run mobile dev                       # Mobile dev
flutter run -d macos --dart-define=FLAVOR=dev --dart-define=SERVER=local

# Codegen
mise sdk_gen remote --only=sdk            # Regenerate SDK
mise ui_gen_icon_font                     # Regenerate icon font

# Test
mise test ui --path test/path/to_test.dart
mise run fix file1.dart file2.dart        # Fix imports & format

# Build
flutter build apk --flavor prod --dart-define=FLAVOR=prod
flutter build ios --flavor prod --dart-define=FLAVOR=prod
```
