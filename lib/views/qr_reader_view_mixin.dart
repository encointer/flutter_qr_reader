import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/flutter_qr_reader.dart';
import 'package:image_picker/image_picker.dart';

mixin QrReaderViewMixin<T extends StatefulWidget> on State<T> {
  late QrReaderViewController controller;
  late AnimationController animationController;

  bool openFlashlight = false;
  Timer? timer;
  bool isScan = false;

  final flashOpen = 'tool_flashlight_open.png';
  final flashClose = 'tool_flashlight_close.png';

  Future Function(String?, String?) get onScan;

  void initAnimation() {
    animationController
      ..addListener(_upState)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          timer = Timer(Duration(seconds: 1), () {
            animationController.reverse(from: 1.0);
          });
        } else if (state == AnimationStatus.dismissed) {
          timer = Timer(Duration(seconds: 1), () {
            animationController.forward(from: 0.0);
          });
        }
      });
    animationController.forward(from: 0.0);
  }

  void clearAnimation() {
    timer?.cancel();
    animationController.dispose();
  }

  void _upState() {
    setState(() {});
  }

  Future<void> onCreateController(QrReaderViewController qrReaderViewController) async {
    controller = qrReaderViewController;
    await controller.startCamera(_onQrBack);
  }

  Future _onQrBack(data, _, rawData) async {
    if (isScan == true) return;
    isScan = true;
    await stopScan();
    await onScan(data, rawData);
  }

  Future<void> startScan()async {
    isScan = false;
    await controller.startCamera(_onQrBack);
    initAnimation();
  }

  Future<void> stopScan() async{
    clearAnimation();
    await controller.stopCamera();
  }

  Future<bool?> setFlashlight() async {
    openFlashlight = await controller.setFlashlight() ?? false;
    setState(() {});
    return openFlashlight;
  }

  Future<void> scanImage() async {
    stopScan();
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      startScan();
      return;
    }
    final rest = await FlutterQrReader.imgScan(File(image.path));
    await onScan(rest, '');
    await startScan();
  }

  @override
  void dispose() {
    clearAnimation();
    super.dispose();
  }
}
