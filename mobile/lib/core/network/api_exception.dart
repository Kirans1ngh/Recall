class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  NetworkException({required super.message});
}

class ServerException extends ApiException {
  ServerException({required super.message, super.statusCode});
}

class NotFoundException extends ApiException {
  NotFoundException({required super.message}) : super(statusCode: 404);
}

