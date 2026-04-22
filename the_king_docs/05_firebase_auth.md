# Firebase Authentication

## Vai tro trong project

Firebase Auth la he thong xac thuc chinh cua app.
Supabase chi luu data, KHONG xu ly auth.

## Cac phuong thuc dang nhap

| Phuong thuc          | File xu ly                    |
|----------------------|-------------------------------|
| Google Sign-In       | remote_data_source.dart       |
| Email + Password     | remote_data_source.dart       |

## Luong dang nhap

### Google Sign-In

```
1. GoogleSignIn().signIn()           → Chon tai khoan Google
2. googleUser.authentication         → Lay accessToken, idToken
3. GoogleAuthProvider.credential()    → Tao Firebase credential
4. FirebaseAuth.signInWithCredential  → Dang nhap Firebase
5. saveUserToSupabase()              → Upsert user vao bang users
```

### Email + Password

```
Dang ky:
1. FirebaseAuth.createUserWithEmailAndPassword(email, password)
2. saveUserToSupabase()

Dang nhap:
1. FirebaseAuth.signInWithEmailAndPassword(email, password)
2. saveUserToSupabase()
```

## Theo doi trang thai auth

```dart
// Stream lang nghe thay doi auth state
FirebaseAuth.authStateChanges().map((User? user) {
  if (user == null) return null;
  return UserModel(uid: user.uid, email: user.email, ...);
});
```

AuthBloc lang nghe stream nay trong `_onAppStarted`:
- User != null → emit `AuthAuthenticated`
- User == null → emit `AuthUnauthenticated`

RootScreen (the_king_app.dart) chuyen man hinh dua tren state:
- `AuthAuthenticated` → HomeScreen
- `AuthUnauthenticated` → SignInScreen

## Cau hinh Firebase

Moi flavor co firebase_options.dart rieng:

```
development/lib/firebase_options.dart   → Firebase project dev
production/lib/firebase_options.dart    → Firebase project prod
```

Khoi tao trong main.dart:

```dart
await Firebase.initializeApp(options: firebaseOptions);
```

## Luu y

- Firebase Auth quan ly session tu dong (persist qua app restart)
- User UID tu Firebase duoc dung lam Primary Key trong Supabase (bang users.uid)
- Khi them phuong thuc auth moi, can:
  1. Them vao RemoteDataSource (abstract + impl)
  2. Them vao AuthRepository (abstract + impl)
  3. Tao UseCase
  4. Them Event + handler trong AuthBloc
  5. Cap nhat UI SignInScreen
  6. Dang ky trong injection.dart
