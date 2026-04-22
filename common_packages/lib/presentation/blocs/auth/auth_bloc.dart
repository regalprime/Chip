import 'package:common_packages/data/models/user/user_model.dart';
import 'package:common_packages/domain/entities/user/user_entity.dart';
import 'package:common_packages/domain/repositories/auth_repository.dart';
import 'package:common_packages/domain/usecases/auth/sign_in_with_email_use_case.dart';
import 'package:common_packages/domain/usecases/auth/sign_in_with_google_use_case.dart';
import 'package:common_packages/domain/usecases/auth/sign_out_use_case.dart';
import 'package:common_packages/domain/usecases/auth/sign_up_with_email_use_case.dart';
import 'package:common_packages/util/app_preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthRepository authRepository,
  })  : _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _signOutUseCase = signOutUseCase,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignOutEvent>(_onSignOutEvent);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // 1. Check Firebase currentUser (available synchronously after Firebase.initializeApp)
    final firebaseUser = await _authRepository.getCurrentUserOnce();
    if (firebaseUser != null) {
      await AppPreferences.setCachedUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoUrl,
      );
      emit(AuthAuthenticated(firebaseUser));
    } else {
      // Firebase has no user — check if we had a cached session
      final cached = await AppPreferences.getCachedUser();
      if (cached != null && cached['uid'] != null) {
        // Session expired or Firebase lost it — clear stale cache
        await AppPreferences.clearCachedUser();
      }
      emit(AuthUnauthenticated());
    }

    // 2. Listen to ongoing auth changes (sign-in, sign-out, token refresh)
    await emit.forEach<UserEntity?>(
      _authRepository.currentUserStream,
      onData: (user) {
        if (user != null) {
          AppPreferences.setCachedUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
          );
          return AuthAuthenticated(user);
        } else {
          AppPreferences.clearCachedUser();
          return AuthUnauthenticated();
        }
      },
      onError: (error, stackTrace) {
        return AuthFailureState('Failed to load user: $error');
      },
    );
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signInWithGoogleUseCase();
      if (user != null) {
        await AppPreferences.setCachedUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailureState('Đăng nhập Google bị huỷ'));
      }
    } catch (e) {
      emit(AuthFailureState('Đăng nhập thất bại: $e'));
    }
  }

  Future<void> _onSignInWithEmail(
      SignInWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signInWithEmailUseCase(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        await AppPreferences.setCachedUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailureState('Đăng nhập thất bại'));
      }
    } catch (e) {
      emit(AuthFailureState('Đăng nhập thất bại: $e'));
    }
  }

  Future<void> _onSignUpWithEmail(
      SignUpWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signUpWithEmailUseCase(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        await AppPreferences.setCachedUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthFailureState('Đăng ký thất bại'));
      }
    } catch (e) {
      emit(AuthFailureState('Đăng ký thất bại: $e'));
    }
  }

  Future<void> _onSignOutEvent(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await AppPreferences.clearCachedUser();
      await _signOutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailureState('Đăng xuất thất bại: $e'));
    }
  }
}