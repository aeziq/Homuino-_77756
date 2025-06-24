import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
/// Base class for all custom exceptions in the app
abstract class AppException implements Exception {
  final String message;
  final String code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    required this.code,
    this.stackTrace,
  });

  @override
  String toString() => '[$runtimeType] $code: $message${stackTrace != null ? '\n$stackTrace' : ''}';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory AuthException.fromFirebase(FirebaseAuthException e, [StackTrace? stackTrace]) {
    String message;

    // Handle common Firebase Auth error codes
    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is badly formatted.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No account found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'This email is already registered.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed. Contact support.';
        break;
      case 'weak-password':
        message = 'The password is too weak. Please choose a stronger password.';
        break;
      case 'requires-recent-login':
        message = 'This operation requires recent authentication. Please log in again.';
        break;
      default:
        message = e.message ?? 'An unknown authentication error occurred.';
    }

    return AuthException(
      message: message,
      code: e.code,
      stackTrace: stackTrace,
    );
  }

  factory AuthException.cancelled([StackTrace? stackTrace]) {
    return AuthException(
      message: 'The operation was cancelled by the user.',
      code: 'cancelled',
      stackTrace: stackTrace,
    );
  }

  factory AuthException.invalidCredentials([StackTrace? stackTrace]) {
    return AuthException(
      message: 'Invalid email or password.',
      code: 'invalid-credentials',
      stackTrace: stackTrace,
    );
  }

  factory AuthException.sessionExpired([StackTrace? stackTrace]) {
    return AuthException(
      message: 'Your session has expired. Please log in again.',
      code: 'session-expired',
      stackTrace: stackTrace,
    );
  }
}

/// Device related exceptions
class DeviceException extends AppException {
  const DeviceException({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory DeviceException.connectionFailed(String deviceName, [StackTrace? stackTrace]) {
    return DeviceException(
      message: 'Failed to connect to $deviceName. Please try again.',
      code: 'connection-failed',
      stackTrace: stackTrace,
    );
  }

  factory DeviceException.notFound(String deviceId, [StackTrace? stackTrace]) {
    return DeviceException(
      message: 'Device with ID $deviceId not found.',
      code: 'device-not-found',
      stackTrace: stackTrace,
    );
  }

  factory DeviceException.scanFailed([StackTrace? stackTrace]) {
    return DeviceException(
      message: 'Failed to scan for devices. Please check permissions and try again.',
      code: 'scan-failed',
      stackTrace: stackTrace,
    );
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory NetworkException.noInternet([StackTrace? stackTrace]) {
    return NetworkException(
      message: 'No internet connection available.',
      code: 'no-internet',
      stackTrace: stackTrace,
    );
  }

  factory NetworkException.timeout([StackTrace? stackTrace]) {
    return NetworkException(
      message: 'Request timed out. Please try again.',
      code: 'timeout',
      stackTrace: stackTrace,
    );
  }

  factory NetworkException.serverError(int statusCode, [StackTrace? stackTrace]) {
    return NetworkException(
      message: 'Server error occurred (Status: $statusCode).',
      code: 'server-error',
      stackTrace: stackTrace,
    );
  }
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory DatabaseException.writeFailed(String path, [StackTrace? stackTrace]) {
    return DatabaseException(
      message: 'Failed to write data at path: $path',
      code: 'write-failed',
      stackTrace: stackTrace,
    );
  }

  factory DatabaseException.readFailed(String path, [StackTrace? stackTrace]) {
    return DatabaseException(
      message: 'Failed to read data from path: $path',
      code: 'read-failed',
      stackTrace: stackTrace,
    );
  }
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory PermissionException.denied(String permission, [StackTrace? stackTrace]) {
    return PermissionException(
      message: '$permission permission was denied.',
      code: 'permission-denied',
      stackTrace: stackTrace,
    );
  }

  factory PermissionException.permanentlyDenied(String permission, [StackTrace? stackTrace]) {
    return PermissionException(
      message: '$permission permission was permanently denied. Please enable it in app settings.',
      code: 'permission-permanently-denied',
      stackTrace: stackTrace,
    );
  }
}

/// General app exceptions
class AppError extends AppException {
  const AppError({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory AppError.unexpected([Object? error, StackTrace? stackTrace]) {
    return AppError(
      message: 'An unexpected error occurred: ${error?.toString() ?? 'Unknown error'}',
      code: 'unexpected-error',
      stackTrace: stackTrace,
    );
  }

  factory AppError.notImplemented([StackTrace? stackTrace]) {
    return AppError(
      message: 'This feature is not implemented yet.',
      code: 'not-implemented',
      stackTrace: stackTrace,
    );
  }

  factory AppError.missingDependency(String dependency, [StackTrace? stackTrace]) {
    return AppError(
      message: 'Required dependency $dependency is missing.',
      code: 'missing-dependency',
      stackTrace: stackTrace,
    );
  }
}

/// Extension to convert exceptions to user-friendly messages
extension ExceptionExtensions on AppException {
  String toUserFriendlyMessage() {
    // Return more user-friendly messages for known error codes
    switch (code) {
      case 'no-internet':
        return 'No internet connection. Please check your network settings.';
      case 'user-not-found':
        return 'Account not found. Please check your email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'permission-denied':
      case 'permission-permanently-denied':
        return 'Please enable the required permissions in settings.';
      default:
        return message;
    }
  }
}