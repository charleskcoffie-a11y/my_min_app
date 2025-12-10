import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';
import 'dart:async';

/// Global error handler service for consistent error management across the app
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  factory ErrorHandler() {
    return _instance;
  }

  ErrorHandler._internal();

  /// Log error to Crashlytics and local storage
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  }) async {
    debugPrint('❌ Error in $context: $error');
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: context ?? 'unknown',
      );
    } catch (e) {
      debugPrint('Failed to log error to Crashlytics: $e');
    }
  }

  /// Handle and display error to user with SnackBar
  void showError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = customMessage ?? _getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: duration,
      ),
    );

    // Log the error
    logError(error, null, context: 'SnackBar Error');
  }

  /// Handle and display info message to user
  void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        duration: duration,
      ),
    );
  }

  /// Handle and display success message to user
  void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: duration,
      ),
    );
  }

  /// Extract user-friendly error message from exception
  String getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (error is FormatException) {
      return 'Invalid format. Please try again.';
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please check your connection.';
    }
    if (error is SocketException) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorStr.contains('permission')) {
      return 'Permission denied. Please check app settings.';
    }
    if (errorStr.contains('not found')) {
      return 'Resource not found.';
    }
    if (errorStr.contains('auth')) {
      return 'Authentication failed. Please log in again.';
    }
    return errorStr.length > 100
        ? 'An error occurred. Please try again later.'
        : errorStr;
  }

  /// Extract user-friendly error message from exception (private version)
  String _getErrorMessage(dynamic error) {
    return getErrorMessage(error);
  }
}

