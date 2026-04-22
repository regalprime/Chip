abstract class AppFailure {
  const AppFailure([this.message = '']);
  final String message;
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet']);
}

class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Cache error']);
}
