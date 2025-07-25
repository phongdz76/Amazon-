// constants/network_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  // ⚠️ THAY ĐỔI IP VÀ PORT NÀY THEO THIẾT LẬP CỦA BẠN
  static const String hostIP = "192.168.1.7"; // <-- Thay IP này
  static const String port = "5000"; // <-- Đổi port từ 3000 thành 5000

  /// Base URL cho API server (Bun TypeScript)
  static String get baseUrl {
    if (kDebugMode) {
      // Development mode
      if (Platform.isAndroid) {
        // Android emulator: 10.0.2.2 maps to host machine
        return "http://10.0.2.2:$port";
      } else if (Platform.isIOS) {
        // iOS simulator: localhost works
        return "http://localhost:$port";
      } else {
        // Real device or other platforms
        return "http://$hostIP:$port";
      }
    } else {
      // Production mode
      return "https://your-production-domain.com"; // Thay bằng domain thật
    }
  }

  /// Email API endpoint - Khớp với Bun server endpoint
  static String get emailApi => "$baseUrl/api";

  // Debug method to check configuration
  static void printConfig() {
    print('=== NetworkConfig Debug ===');
    print('Platform: ${Platform.operatingSystem}');
    print('Debug mode: $kDebugMode');
    print('Host IP: $hostIP');
    print('Port: $port');
    print('Base URL: $baseUrl');
    print('Email API: $emailApi');
    print('==========================');
  }
}
