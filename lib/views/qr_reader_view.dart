import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_qr_scan/flutter_qr_reader.dart';

/// 使用前需已经获取相关权限
/// Relevant privileges must be obtained before use
class QrcodeReaderView extends StatefulWidget {
  const QrcodeReaderView({
    Key? key,
    required this.onScan,
    this.headerWidget,
    this.boxLineColor = Colors.cyanAccent,
    this.helpWidget,
    this.scanBoxRatio = 0.85,
  }) : super(key: key);

  final Widget? headerWidget;
  final Future Function(String?, String?) onScan;
  final double scanBoxRatio;
  final Color boxLineColor;
  final Widget? helpWidget;

  @override
  State<QrcodeReaderView> createState() => QrcodeReaderViewState();
}

/// 扫码后的后续操作
/// ```dart
/// GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();
/// qrViewKey.currentState.startScan();
/// ```
class QrcodeReaderViewState extends State<QrcodeReaderView> with TickerProviderStateMixin {
  late final QrReaderViewController _controller;
  late final AnimationController _animationController;
  bool openFlashlight = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _initAnimation();
  }

  void _initAnimation() {
    _animationController
      ..addListener(_upState)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          _timer = Timer(Duration(seconds: 1), () {
            _animationController.reverse(from: 1.0);
          });
        } else if (state == AnimationStatus.dismissed) {
          _timer = Timer(Duration(seconds: 1), () {
            _animationController.forward(from: 0.0);
          });
        }
      });
    _animationController.forward(from: 0.0);
  }

  void _clearAnimation() {
    _timer?.cancel();
    _animationController.dispose();
  }

  void _upState() {
    setState(() {});
  }

  Future<void> _onCreateController(QrReaderViewController controller) async {
    _controller = controller;
    await _controller.startCamera(_onQrBack);
  }

  bool isScan = false;
  Future _onQrBack(data, _, rawData) async {
    if (isScan == true) return;
    isScan = true;
    stopScan();
    await widget.onScan(data, rawData);
  }

  void startScan() {
    isScan = false;
    _controller.startCamera(_onQrBack);
    _initAnimation();
  }

  void stopScan() {
    _clearAnimation();
    _controller.stopCamera();
  }

  Future<bool?> setFlashlight() async {
    openFlashlight = await _controller.setFlashlight() ?? false;
    setState(() {});
    return openFlashlight;
  }

  Future _scanImage() async {
    stopScan();
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      startScan();
      return;
    }
    final rest = await FlutterQrReader.imgScan(File(image.path));
    await widget.onScan(rest, '');
    startScan();
  }

  @override
  Widget build(BuildContext context) {
    final flashOpen = Image.asset(
      "assets/tool_flashlight_open.png",
      package: "flutter_qr_scan",
      width: 35,
      height: 35,
      color: Colors.white,
    );
    final flashClose = Image.asset(
      "assets/tool_flashlight_close.png",
      package: "flutter_qr_scan",
      width: 35,
      height: 35,
      color: Colors.white,
    );
    return Material(
      color: Colors.black,
      child: LayoutBuilder(builder: (context, constraints) {
        final qrScanSize = constraints.maxWidth * widget.scanBoxRatio;
        final mediaQuery = MediaQuery.of(context);
        if (constraints.maxHeight < qrScanSize * 1.5) {
          log("建议高度与扫码区域高度比大于1.5");
        }
        return Stack(
          children: <Widget>[
            SizedBox(
              width: 200, // constraints.maxWidth,
              height: 200, // constraints.maxHeight,
              child: Stack(
                children: [
                  FlutterLogo(size: 300),
                  QrReaderView(
                    width: 200, // constraints.maxWidth,
                    height: 200, // constraints.maxHeight,
                    callback: _onCreateController,
                  ),
                  FlutterLogo(size: 700),
                ],
              ),
            ),
            if (widget.headerWidget != null) widget.headerWidget!,
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    painter: QrScanBoxPainter(
                      boxLineColor: widget.boxLineColor,
                      animationValue: _animationController.value,
                      isForward: _animationController.status == AnimationStatus.forward,
                    ),
                    child: SizedBox(
                      width: qrScanSize,
                      height: qrScanSize,
                    ),
                  ),
                  DefaultTextStyle(
                    style: TextStyle(color: Colors.white),
                    child: widget.helpWidget ?? Text("请将二维码置于方框中"),
                  ),
                ],
              ),
            ),
            Positioned(
              top: (constraints.maxHeight - qrScanSize) * 0.333333 + qrScanSize - 12 - 35,
              width: constraints.maxWidth,
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: setFlashlight,
                  child: openFlashlight ? flashOpen : flashClose,
                ),
              ),
            ),
            Positioned(
              width: constraints.maxWidth,
              bottom: constraints.maxHeight == mediaQuery.size.height ? 12 + mediaQuery.padding.top : 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _scanImage,
                    child: Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/tool_img.png",
                        package: "flutter_qr_scan",
                        width: 25,
                        height: 25,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      border: Border.all(color: Colors.white30, width: 12),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/tool_qrcode.png",
                      package: "flutter_qr_scan",
                      width: 35,
                      height: 35,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(width: 45, height: 45),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _clearAnimation();
    super.dispose();
  }
}
