import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'helpers/take_screenshot.dart';

void main() {
  late FlutterDriver driver;

  group('scan-page', () {
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.waitUntilFirstFrameRasterized();
    });

    tearDownAll(() async {
      await driver.close();
    });
    test('scan-page-screenshot', () async {
      final file = File('test_driver/resources/encointer-receive-qr-1.jpg');
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);

      // set the background in the MockScanPage
      await driver.requestData(base64);

      await takeScreenshot(driver, 'scan_view');
    });
  });
}
