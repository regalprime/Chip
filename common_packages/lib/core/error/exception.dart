import 'dart:developer' as dev;

class ServerException implements Exception {
  final String message;

  ServerException(this.message) {
    dev.log('ServerException: $message', name: 'SERVER_ERROR');
  }

  @override
  String toString() => message;
}