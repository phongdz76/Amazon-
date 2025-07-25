// constants/network_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  // ⚠️ CHANGE THIS IP AND PORT ACCORDING TO YOUR SETUP
  static const String hostIP = "192.168.1.7"; // <-- Change this IP
  static const String port = "5000"; // <-- Change port from 3000 to 5000

  /// Base URL for API server (Bun TypeScript)
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
      return "https://your-production-domain.com"; // Replace with real domain
    }
  }

  /// Email API endpoint - Matches Bun server endpoint
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
