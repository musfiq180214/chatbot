import 'package:flutter/foundation.dart';

class AppLogger {
  static void logRequest(String url, Map<String, dynamic> body) {
    debugPrint("🚀 REQUEST → $url");
    debugPrint("📦 BODY → $body");
  }

  static void logResponse(String url, dynamic response) {
    debugPrint("✅ RESPONSE ← $url");
    debugPrint("📥 DATA ← $response");
  }

  static void logError(String url, dynamic error) {
    debugPrint("❌ ERROR ← $url");
    debugPrint("🔥 MESSAGE ← $error");
  }
}