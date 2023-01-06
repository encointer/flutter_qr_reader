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

  /// if return is `true` controller will stop camera
  /// if `false` controller continue work
  Future<bool> Function(String?, String?) get onScan;
  TickerProvider get vsync;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 1000));
    initAnimation();
  }

  void initAnimation() {
    animationController
      ..addListener(_upState)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          timer = Timer(const Duration(seconds: 1), () {
            animationController.reverse(from: 1);
          });
        } else if (state == AnimationStatus.dismissed) {
          timer = Timer(const Duration(seconds: 1), () {
            animationController.forward(from: 0);
          });
        }
      })
      ..forward(from: 0);
  }

  void clearAnimation() {
    animationController.dispose();
    timer?.cancel();
  }

  void _upState() {
    if (mounted) setState(() {});
  }

  Future<void> onCreateController(QrReaderViewController qrReaderViewController) async {
    controller = qrReaderViewController;
    await controller.startCamera(_onQrBack);
  }

  Future<void> _onQrBack(String? data, List<Offset> _, String? rawData) async {
    if (isScan == true) return;
    isScan = true;
    stopScan();
    await onScan(data, rawData).then(
      (value) async {
        if (!value) {
          isScan = false;
          await Future<void>.delayed(const Duration(seconds: 1));
          await controller.startCamera(_onQrBack);
        }
      },
    );
  }

  void stopScan() {
    controller.stopCamera();
  }

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
