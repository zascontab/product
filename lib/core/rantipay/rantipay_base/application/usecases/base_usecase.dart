

import 'package:rantipay_app/core/errors/failure_commons.dart';

/// Native tuple patterns - no external dependencies
/// Result type for use case operations using native Dart tuples
typedef UseCaseResult<T> = (T? data, UseCaseFailure? error);

/// Result type for validation operations using native Dart tuples
typedef ValidationResult = (bool isValid, List<ValidationFailure> failures);

/// Base use case interface for business logic encapsulation
/// 
/// Provides consistent pattern for:
/// - Input validation
/// - Error handling  
/// - Performance monitoring
/// - Business rule enforcement
abstract class UseCase<Type, Params> {
  /// Executes the use case with given parameters
  /// Returns (result, error) tuple using native Dart patterns
  Future<UseCaseResult<Type>> call(Params params);
}

/// Use case for operations that don't require parameters
abstract class NoParamsUseCase<Type> {
  Future<UseCaseResult<Type>> call();
}

/// Base parameters class for use cases
abstract class UseCaseParams {
  /// Validates parameters before use case execution
  /// Returns (isValid, failures) tuple
  ValidationResult validate();
}

/// Base use case implementation with common functionality
abstract class BaseUseCase<Type, Params extends UseCaseParams>
    implements UseCase<Type, Params> {
  
  @override
  Future<UseCaseResult<Type>> call(Params params) async {
    try {
      // Validate parameters
      final (isValid, failures) = params.validate();
      if (!isValid) {
        return (null, UseCaseFailure.invalidParams(
          message: 'Parameter validation failed',
          failures: failures,
        ));
      }
      
      // Execute business logic
      final result = await execute(params);
      return (result, null);
    } catch (error, stackTrace) {
      if (error is UseCaseFailure) {
        return (null, error);
      }
      
      if (error is FailureCommons) {
        return (null, UseCaseFailure.repository(repositoryFailure: error));
      }
      
      return (null, UseCaseFailure.unexpected(
        message: 'Unexpected error in use case execution',
        cause: error,
        stackTrace: stackTrace,
      ));
    }
  }
  
  /// Implement business logic in subclasses
  Future<Type> execute(Params params);
}

/// Use case failure types
class UseCaseFailure {
  final String type;
  final String message;
  final Map<String, dynamic> details;
  
  const UseCaseFailure._({
    required this.type,
    required this.message,
    required this.details,
  });
  
   UseCaseFailure.invalidParams({
    required String message,
    required List<ValidationFailure> failures,
  }) : this._(
    type: 'INVALID_PARAMS',
    message: message,
    details: {'failures': failures},
  );
  
   UseCaseFailure.businessRule({
    required String rule,
    required String message,
    String? code,
  }) : this._(
    type: 'BUSINESS_RULE',
    message: message,
    details: {'rule': rule, 'code': code},
  );
  
   UseCaseFailure.repository({
    required FailureCommons repositoryFailure,
  }) : this._(
    type: 'REPOSITORY',
    message: 'Repository operation failed',
    details: {'repositoryFailure': repositoryFailure},
  );
  
   UseCaseFailure.unexpected({
    required String message,
    Object? cause,
    StackTrace? stackTrace,
  }) : this._(
    type: 'UNEXPECTED',
    message: message,
    details: {'cause': cause, 'stackTrace': stackTrace},
  );
  
  @override
  String toString() => '$type: $message';
}

/// Validation failure class
class ValidationFailure {
  final String field;
  final String message;
  final String code;
  final Map<String, dynamic>? context;
  
  const ValidationFailure({
    required this.field,
    required this.message,
    required this.code,
    this.context,
  });
  
  @override
  String toString() => '$field: $message ($code)';
}

/// Common validation codes
abstract class ValidationCodes {
  static const String required = 'REQUIRED';
  static const String invalid = 'INVALID';
  static const String tooLong = 'TOO_LONG';
  static const String tooShort = 'TOO_SHORT';
  static const String outOfRange = 'OUT_OF_RANGE';
  static const String duplicate = 'DUPLICATE';
  static const String forbidden = 'FORBIDDEN';
  static const String expired = 'EXPIRED';
}