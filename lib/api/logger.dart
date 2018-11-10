import 'package:flutter/material.dart';

enum LogLevel { info, debug, warning, error }
enum TimestampStyle { timeOnly, noYear, dateTime }

final sliceStart = {
  TimestampStyle.dateTime: 0,
  TimestampStyle.noYear: 5,
  TimestampStyle.timeOnly: 11,
};

String _timestamp(TimestampStyle ts) =>
    DateTime.now().toString().substring(sliceStart[ts]);

void _logInfo(LogLevel level, String msg, TimestampStyle s) {
  if (level != LogLevel.info) return;
  debugPrint("[I/${_timestamp(s)}] $msg");
}

void _logDebug(LogLevel level, String msg, TimestampStyle s) {
  if (level == LogLevel.info) return;
  debugPrint("[D/${_timestamp(s)}] $msg");
}

void _logWarning(LogLevel level, String msg, TimestampStyle s) {
  if (level == LogLevel.info || level == LogLevel.debug) return;
  debugPrint("[W/${_timestamp(s)}] $msg");
}

void _logError(LogLevel _, String msg, TimestampStyle s) {
  debugPrint("[E/${_timestamp(s)}] $msg");
}

typedef void LogFunc(LogLevel level, String msg, TimestampStyle s);

class Logger {
  static bool _checkDebug() {
    var result = false;
    assert(() {
      result = true;
      return true;
    }());
    return result;
  }

  static final isDebug = _checkDebug();
  LogLevel level = isDebug ? LogLevel.warning : LogLevel.debug;
  TimestampStyle style = TimestampStyle.timeOnly;

  static final _logFuncs = {
    LogLevel.info: _logInfo,
    LogLevel.debug: _logDebug,
    LogLevel.warning: _logWarning,
    LogLevel.error: _logError,
  };

  void log(LogLevel lvl, String msg) {
    _logFuncs[lvl](level, msg, style);
  }

  void info(String msg) {
    log(LogLevel.debug, msg);
  }

  void dbg(String msg) {
    log(LogLevel.debug, msg);
  }

  void warn(String msg) {
    log(LogLevel.debug, msg);
  }

  void err(String msg) {
    log(LogLevel.debug, msg);
  }
}

final logger = Logger();

void log(String msg, [LogLevel lvl = LogLevel.debug]) {
  logger.log(lvl, msg);
}

void logi(String msg) {
  logger.dbg(msg);
}

void logd(String msg) {
  logger.dbg(msg);
}

void logw(String msg) {
  logger.dbg(msg);
}

void loge(String msg) {
  logger.dbg(msg);
}
