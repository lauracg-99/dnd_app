import 'package:flutter/foundation.dart';

/// Log levels for the application
enum LogLevel {
  debug,
  info,
  warning,
  error,
  none,
}

/// Configuration for the logger
class LoggerConfig {
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static bool _enableTimestamps = true;
  static bool _enableColors = true;

  static LogLevel get currentLevel => _currentLevel;
  static bool get enableTimestamps => _enableTimestamps;
  static bool get enableColors => _enableColors;

  static void setLevel(LogLevel level) {
    _currentLevel = level;
  }

  static void setTimestamps(bool enabled) {
    _enableTimestamps = enabled;
  }

  static void setColors(bool enabled) {
    _enableColors = enabled;
  }

  static void disableLogsInProduction() {
    if (kReleaseMode) {
      _currentLevel = LogLevel.none;
    }
  }
}

/// Professional logging system for the D&D app
class AppLogger {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _gray = '\x1B[90m';
  static const String _green = '\x1B[32m';

  /// Log a debug message (only in debug mode)
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag, color: _gray);
  }

  /// Log an info message
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag, color: _blue);
  }

  /// Log a success message
  static void success(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag, color: _green);
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag, color: _yellow);
  }

  /// Log an error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, color: _red);
    
    if (error != null) {
      _log(LogLevel.error, 'Error details: $error', tag: tag, color: _red);
    }
    
    if (stackTrace != null && kDebugMode) {
      _log(LogLevel.error, 'Stack trace:\n$stackTrace', tag: tag, color: _red);
    }
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    String color = _reset,
  }) {
    if (!_shouldLog(level)) return;

    final buffer = StringBuffer();

    if (LoggerConfig.enableColors) {
      buffer.write(color);
    }

    if (LoggerConfig.enableTimestamps) {
      final timestamp = DateTime.now().toIso8601String().substring(11, 23);
      buffer.write('[$timestamp] ');
    }

    buffer.write('[${_levelToString(level)}]');

    if (tag != null) {
      buffer.write(' [$tag]');
    }

    buffer.write(' $message');

    if (LoggerConfig.enableColors) {
      buffer.write(_reset);
    }

    debugPrint(buffer.toString());
  }

  /// Check if a log level should be logged
  static bool _shouldLog(LogLevel level) {
    if (LoggerConfig.currentLevel == LogLevel.none) return false;
    return level.index >= LoggerConfig.currentLevel.index;
  }

  /// Convert log level to string
  static String _levelToString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO ';
      case LogLevel.warning:
        return 'WARN ';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.none:
        return 'NONE ';
    }
  }

  /// Log a separator line (useful for visual separation in logs)
  static void separator({String? tag}) {
    debug('═' * 80, tag: tag);
  }

  /// Log a section header
  static void section(String title, {String? tag}) {
    separator(tag: tag);
    info(title, tag: tag);
    separator(tag: tag);
  }

  /// Log data in a structured format
  static void data(String label, dynamic value, {String? tag}) {
    debug('$label: $value', tag: tag);
  }

  /// Log a list of items
  static void list(String title, List<dynamic> items, {String? tag}) {
    info(title, tag: tag);
    for (var i = 0; i < items.length; i++) {
      debug('  ${i + 1}. ${items[i]}', tag: tag);
    }
  }

  /// Log performance timing
  static void timing(String operation, Duration duration, {String? tag}) {
    final ms = duration.inMilliseconds;
    final message = '$operation completed in ${ms}ms';
    
    if (ms > 1000) {
      warning(message, tag: tag);
    } else {
      debug(message, tag: tag);
    }
  }

  /// Create a logger instance for a specific class/module
  static ModuleLogger forModule(String moduleName) {
    return ModuleLogger(moduleName);
  }
}

/// Logger instance for a specific module/class
class ModuleLogger {
  final String moduleName;

  ModuleLogger(this.moduleName);

  void debug(String message) => AppLogger.debug(message, tag: moduleName);
  void info(String message) => AppLogger.info(message, tag: moduleName);
  void success(String message) => AppLogger.success(message, tag: moduleName);
  void warning(String message) => AppLogger.warning(message, tag: moduleName);
  
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, tag: moduleName, error: error, stackTrace: stackTrace);
  }

  void separator() => AppLogger.separator(tag: moduleName);
  void section(String title) => AppLogger.section(title, tag: moduleName);
  void data(String label, dynamic value) => AppLogger.data(label, value, tag: moduleName);
  void list(String title, List<dynamic> items) => AppLogger.list(title, items, tag: moduleName);
  void timing(String operation, Duration duration) => AppLogger.timing(operation, duration, tag: moduleName);
}
