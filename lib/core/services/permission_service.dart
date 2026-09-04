import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionService {
  // In-memory permission state for testing allow & deny anytime
  static bool? _mockPermissionOverride;

  static bool? get currentOverride => _mockPermissionOverride;

  static void setMockPermission(bool? granted) {
    _mockPermissionOverride = granted;
  }

  static Future<bool> requestStoragePermission() async {
    if (_mockPermissionOverride != null) {
      return _mockPermissionOverride!;
    }

    if (kIsWeb) {
      // On web, storage permission is automatically simulated/granted
      return true;
    }

    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        
        if (androidInfo.version.sdkInt >= 33) {
          final audio = await Permission.audio.request();
          final video = await Permission.videos.request();
          final photos = await Permission.photos.request();
          return audio.isGranted && video.isGranted && photos.isGranted;
        } else {
          final storage = await Permission.storage.request();
          return storage.isGranted;
        }
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
    return true;
  }

  static Future<bool> checkPermissionStatus() async {
    if (_mockPermissionOverride != null) {
      return _mockPermissionOverride!;
    }

    if (kIsWeb) {
      return true;
    }

    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        
        if (androidInfo.version.sdkInt >= 33) {
          final audio = await Permission.audio.status;
          final video = await Permission.videos.status;
          final photos = await Permission.photos.status;
          return audio.isGranted && video.isGranted && photos.isGranted;
        } else {
          final storage = await Permission.storage.status;
          return storage.isGranted;
        }
      }
    } catch (e) {
      debugPrint('Permission status check error: $e');
    }
    return true;
  }
}

