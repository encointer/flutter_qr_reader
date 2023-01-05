import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterQrReader {
  static const MethodChannel _channel = MethodChannel('me.hetian.flutter_qr_reader');

  static Future<String?> imgScan(File file) async {
    if (file.existsSync() == false) {
      return null;
    }
    try {
      final rest = await _channel.invokeMethod('imgQrCode', {'file': file.path});
      return rest as String;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
