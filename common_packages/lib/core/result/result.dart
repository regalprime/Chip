import 'package:common_packages/core/error/app_failure.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    _ => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Failure(:final failure) => failure,
    _ => null,
  };

  R when<R>({required R Function(T data) success, required R Function(AppFailure failure) failure}) => switch (this) {
    Success(:final data) => success(data),
    Failure(failure: final appFailure) => failure(appFailure),
  };

  T getOrThrow() => switch (this) {
    Success(:final data) => data,
    Failure(:final failure) => throw Exception(failure.message),
  };
}
