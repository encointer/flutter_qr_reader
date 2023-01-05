import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/flutter_qr_reader.dart';

mixin QrReaderViewMixin<T extends StatefulWidget> on State<T> {
  late QrReaderViewController controller;
  late AnimationController animationController;

  bool openFlashlight = false;
  Timer? timer;
  bool isScan = false;

  final flashOpen = 'tool_flashlight_open.png';
  final flashClose = 'tool_flashlight_close.png';

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

  void clearAnimation() async {
    animationController.dispose();
    timer?.cancel();
  }

  void _upState() {
    if (mounted) setState(() {});
  }

  Future<void> onCreateController(QrReaderViewController qrReaderViewController) async {
    controller = qrReaderViewController;
    controller.startCamera(_onQrBack);
  }

  Future _onQrBack(data, _, rawData) async {
    if (isScan == true) return;
    isScan = true;
    await onScan(data, rawData);
    await Future.delayed(Duration(seconds: 2));
    isScan = false;
  }

  // void stopScan() {
  //   clearAnimation();
  //   controller.stopCamera();
  // }

  Future<bool?> setFlashlight() async {
    openFlashlight = await controller.setFlashlight() ?? false;
    setState(() {});
    return openFlashlight;
  }

  @override
  void dispose() {
    clearAnimation();
    super.dispose();
  }
}
