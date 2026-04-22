# Dependency Injection (GetIt)

## GetIt la gi?

GetIt la Service Locator pattern - dang ky cac dependency 1 lan,
lay ra o bat ky dau trong app.

## File cau hinh: `common_packages/lib/di/injection.dart`

```dart
final sl = GetIt.instance;  // sl = Service Locator

Future<void> init() async {
  // 1. External (Firebase, Supabase, Google Sign In)
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2. Data Sources
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(firebaseAuth: sl(), supabaseClient: sl(), ...),
  );

  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // 4. Use Cases
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));

  // 5. BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(signInWithGoogleUseCase: sl(), ...),
  );
}
```

## Phan biet registerLazySingleton vs registerFactory

| Kieu              | Tao instance     | Dung cho                       |
|-------------------|------------------|--------------------------------|
| registerSingleton | Ngay lap tuc     | Config, DB client              |
| registerLazySingleton | Lan dau goi  | Repository, UseCase, DataSource|
| registerFactory   | Moi lan goi      | BLoC (moi man hinh = BLoC moi) |

**Quan trong:**
- BLoC PHAI dung `registerFactory` vi moi man hinh can instance moi
- Repository dung `registerLazySingleton` vi chi can 1 instance chia se

## Cach su dung

```dart
// Lay instance
final authBloc = sl<AuthBloc>();

// Trong BlocProvider
BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
```

## Thu tu dang ky

```
External → DataSource → Repository → UseCase → BLoC
```

Phai dang ky theo thu tu nay vi moi tang phu thuoc vao tang truoc do.
`sl()` se tu dong tim dependency da dang ky truoc do.
