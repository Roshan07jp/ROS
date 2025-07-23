import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../platform/platform_service.dart';

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
  fatal
}

enum ErrorCategory {
  platform,
  network,
  permission,
  terminal,
  ai,
  file,
  system,
  ui,
  unknown
}

class AppError {
  final String id;
  final String title;
  final String message;
  final String? technicalDetails;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;
  final String? userAction;
  final bool canRetry;

  const AppError({
    required this.id,
    required this.title,
    required this.message,
    this.technicalDetails,
    required this.severity,
    required this.category,
    required this.timestamp,
    this.stackTrace,
    this.context,
    this.userAction,
    this.canRetry = false,
  });

  factory AppError.create({
    required String title,
    required String message,
    String? technicalDetails,
    ErrorSeverity severity = ErrorSeverity.error,
    ErrorCategory category = ErrorCategory.unknown,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userAction,
    bool canRetry = false,
  }) {
    return AppError(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      technicalDetails: technicalDetails,
      severity: severity,
      category: category,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      context: context,
      userAction: userAction,
      canRetry: canRetry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'technicalDetails': technicalDetails,
      'severity': severity.name,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'userAction': userAction,
      'canRetry': canRetry,
    };
  }
}

class ErrorHandler {
  static final List<AppError> _errorHistory = [];
  static final List<Function(AppError)> _errorListeners = [];

  // Platform-specific error handling
  static Future<void> initialize() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = AppError.create(
        title: 'Flutter Error',
        message: details.exception.toString(),
        technicalDetails: details.toString(),
        severity: ErrorSeverity.error,
        category: ErrorCategory.ui,
        stackTrace: details.stack,
      );
      _handleError(error);
    };

    // Handle platform dispatcher errors
    PlatformDispatcher.instance.onError = (error, stack) {
      final appError = AppError.create(
        title: 'Platform Error',
        message: error.toString(),
        severity: ErrorSeverity.critical,
        category: ErrorCategory.platform,
        stackTrace: stack,
      );
      _handleError(appError);
      return true;
    };

    if (kDebugMode) {
      developer.log('ErrorHandler initialized');
    }
  }

  static void _handleError(AppError error) {
    _errorHistory.add(error);
    
    // Keep only last 100 errors
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }

    // Log to console in debug mode
    if (kDebugMode) {
      developer.log(
        error.message,
        name: 'ROS.${error.category.name}',
        error: error.technicalDetails,
        stackTrace: error.stackTrace,
        level: _getSeverityLevel(error.severity),
      );
    }

    // Notify listeners
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        if (kDebugMode) {
          print('Error in error listener: $e');
        }
      }
    }
  }

  static int _getSeverityLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 800;
      case ErrorSeverity.warning:
        return 900;
      case ErrorSeverity.error:
        return 1000;
      case ErrorSeverity.critical:
        return 1100;
      case ErrorSeverity.fatal:
        return 1200;
    }
  }

  // Error reporting methods
  static void reportError(AppError error) {
    _handleError(error);
  }

  static void reportException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    ErrorCategory category = ErrorCategory.unknown,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final error = AppError.create(
      title: 'Exception',
      message: exception.toString(),
      technicalDetails: context,
      severity: severity,
      category: category,
      stackTrace: stackTrace,
      context: {'exception_type': exception.runtimeType.toString()},
    );
    _handleError(error);
  }

  // Platform-specific error creators
  static AppError createPlatformError(String message, {String? details}) {
    return AppError.create(
      title: 'Platform Error',
      message: message,
      technicalDetails: details,
      severity: ErrorSeverity.error,
      category: ErrorCategory.platform,
      userAction: 'Try restarting the app or check platform compatibility',
      canRetry: true,
    );
  }

  static AppError createNetworkError(String message, {String? details}) {
    return AppError.create(
      title: 'Network Error',
      message: message,
      technicalDetails: details,
      severity: ErrorSeverity.warning,
      category: ErrorCategory.network,
      userAction: 'Check your internet connection and try again',
      canRetry: true,
    );
  }

  static AppError createPermissionError(String permission, {String? details}) {
    return AppError.create(
      title: 'Permission Required',
      message: 'Permission "$permission" is required for this feature',
      technicalDetails: details,
      severity: ErrorSeverity.warning,
      category: ErrorCategory.permission,
      userAction: 'Grant the required permission in app settings',
      canRetry: true,
    );
  }

  static AppError createTerminalError(String message, {String? command}) {
    return AppError.create(
      title: 'Terminal Error',
      message: message,
      technicalDetails: command != null ? 'Command: $command' : null,
      severity: ErrorSeverity.error,
      category: ErrorCategory.terminal,
      userAction: 'Check command syntax and try again',
      canRetry: true,
      context: {'command': command},
    );
  }

  static AppError createAIError(String message, {String? details}) {
    return AppError.create(
      title: 'AI Service Error',
      message: message,
      technicalDetails: details,
      severity: ErrorSeverity.warning,
      category: ErrorCategory.ai,
      userAction: 'AI service may be temporarily unavailable. Try again later.',
      canRetry: true,
    );
  }

  static AppError createFileError(String operation, String path, {String? details}) {
    return AppError.create(
      title: 'File Operation Error',
      message: 'Failed to $operation file: $path',
      technicalDetails: details,
      severity: ErrorSeverity.error,
      category: ErrorCategory.file,
      userAction: 'Check file permissions and storage space',
      canRetry: true,
      context: {'operation': operation, 'path': path},
    );
  }

  // Error recovery methods
  static Future<bool> tryRecover(AppError error) async {
    switch (error.category) {
      case ErrorCategory.network:
        return await _recoverNetworkError(error);
      case ErrorCategory.permission:
        return await _recoverPermissionError(error);
      case ErrorCategory.terminal:
        return await _recoverTerminalError(error);
      case ErrorCategory.ai:
        return await _recoverAIError(error);
      case ErrorCategory.file:
        return await _recoverFileError(error);
      default:
        return false;
    }
  }

  static Future<bool> _recoverNetworkError(AppError error) async {
    // Implement network connectivity check and retry logic
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simplified
  }

  static Future<bool> _recoverPermissionError(AppError error) async {
    // Implement permission re-request logic
    return false; // Usually requires user intervention
  }

  static Future<bool> _recoverTerminalError(AppError error) async {
    // Implement terminal recovery logic
    return true; // Simplified
  }

  static Future<bool> _recoverAIError(AppError error) async {
    // Implement AI service recovery logic
    await Future.delayed(const Duration(seconds: 1));
    return true; // Simplified
  }

  static Future<bool> _recoverFileError(AppError error) async {
    // Implement file operation recovery logic
    return false; // Usually requires user intervention
  }

  // Error history and listeners
  static List<AppError> getErrorHistory() {
    return List.unmodifiable(_errorHistory);
  }

  static void addErrorListener(Function(AppError) listener) {
    _errorListeners.add(listener);
  }

  static void removeErrorListener(Function(AppError) listener) {
    _errorListeners.remove(listener);
  }

  static void clearErrorHistory() {
    _errorHistory.clear();
  }

  // Error statistics
  static Map<ErrorCategory, int> getErrorStatistics() {
    final stats = <ErrorCategory, int>{};
    for (final error in _errorHistory) {
      stats[error.category] = (stats[error.category] ?? 0) + 1;
    }
    return stats;
  }

  static List<AppError> getRecentErrors({int limit = 10}) {
    final recent = _errorHistory.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return recent.take(limit).toList();
  }
}

// Error UI Components
class ErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        _getErrorIcon(error.severity),
        color: _getErrorColor(error.severity),
        size: 32,
      ),
      title: Text(error.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.message),
          if (error.userAction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error.userAction!,
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (kDebugMode && error.technicalDetails != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Technical Details'),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    error.technicalDetails!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (error.canRetry && onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: onDismiss ?? () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
      case ErrorSeverity.fatal:
        return Icons.error;
    }
  }

  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade700;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }
}

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required AppError error,
    VoidCallback? onRetry,
  }) : super(
          content: Row(
            children: [
              Icon(
                _getErrorIcon(error.severity),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error.message),
              ),
            ],
          ),
          backgroundColor: _getErrorColor(error.severity),
          action: error.canRetry && onRetry != null
              ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
              : null,
          duration: Duration(
            seconds: error.severity == ErrorSeverity.info ? 2 : 4,
          ),
        );

  static IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
      case ErrorSeverity.fatal:
        return Icons.error;
    }
  }

  static Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade700;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }
}

// Riverpod providers
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});

final errorHistoryProvider = StateNotifierProvider<ErrorHistoryNotifier, List<AppError>>((ref) {
  return ErrorHistoryNotifier();
});

class ErrorHistoryNotifier extends StateNotifier<List<AppError>> {
  ErrorHistoryNotifier() : super([]) {
    ErrorHandler.addErrorListener(_onError);
  }

  void _onError(AppError error) {
    state = [...state, error];
    // Keep only last 50 errors in state
    if (state.length > 50) {
      state = state.sublist(state.length - 50);
    }
  }

  void clearErrors() {
    state = [];
    ErrorHandler.clearErrorHistory();
  }

  @override
  void dispose() {
    ErrorHandler.removeErrorListener(_onError);
    super.dispose();
  }
}