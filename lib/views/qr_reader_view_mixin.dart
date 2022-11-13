import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/flutter_qr_reader.dart';
// import 'package:image_picker/image_picker.dart';

mixin QrReaderViewMixin<T extends StatefulWidget> on State<T> {
  late QrReaderViewController controller;
  late AnimationController animationController;

  bool openFlashlight = false;
  Timer? timer;
  bool isScan = false;

  final flashOpen = 'tool_flashlight_open.png';
  final flashClose = 'tool_flashlight_close.png';

  /// if after onscan call navigate pop return true else false
  /// [bool] is true call animate dispose method
  Future<void> Function(String?, String?) get onScan;
  TickerProvider get vsync;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: vsync, duration: Duration(milliseconds: 1000));
    initAnimation();
  }

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
    animationController
      ..stop()
      ..dispose();
    timer?.cancel();
  }

  void _upState() {
    setState(() {});
  }

  Future<void> onCreateController(QrReaderViewController qrReaderViewController) async {
    controller = qrReaderViewController;
    controller.startCamera(_onQrBack);
  }

  Future _onQrBack(data, _, rawData) async {
    if (isScan == true) return;
    isScan = true;
    // stopScan();
    await onScan(data, rawData);
    isScan = false;
    // setState(() {});
    print('=========>01 $isScan');
  }

  // void startScan() {
  //   isScan = false;
  //   controller.startCamera(_onQrBack);
  //   initAnimation();
  // }

  void stopScan() {
    clearAnimation();
    controller.stopCamera();
  }

  Future<bool?> setFlashlight() async {
    openFlashlight = await controller.setFlashlight() ?? false;
    setState(() {});
    return openFlashlight;
  }

  // Future<void> scanImage() async {
  //   stopScan();
  //   var image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (image == null) {
  //     startScan();
  //     return;
  //   }
  //   final rest = await FlutterQrReader.imgScan(File(image.path));
  //   await onScan(rest, '');
  //   startScan();
  // }

  @override
  void dispose() {
    clearAnimation();
    super.dispose();
  }
}
