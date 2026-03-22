import 'package:flutter/foundation.dart';

class AppLogger {
  // ANSI color codes
  static const _blue = '\x1B[34m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _reset = '\x1B[0m';

  static void logRequest(String url, Map<String, dynamic> body) {
    debugPrint("$_blue🚀 REQUEST → $url$_reset");
    debugPrint("$_blue📦 BODY → $body$_reset");
  }

  static void logResponse(String url, dynamic response) {
    debugPrint("$_green✅ RESPONSE ← $url$_reset");
    debugPrint("$_green📥 DATA ← $response$_reset");
  }

  static void logError(String url, dynamic error) {
    debugPrint("$_red❌ ERROR ← $url$_reset");
    debugPrint("$_red🔥 MESSAGE ← $error$_reset");
  }
}