import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/views/qr_reader_view_mixin.dart';

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
    this.text,
  }) : super(key: key);

  final Widget? headerWidget;
  final Future Function(String?, String?) onScan;
  final double scanBoxRatio;
  final Color boxLineColor;
  final Widget? helpWidget;
  final String? text;

  @override
  State<QrcodeReaderView> createState() => QrcodeReaderViewState();
}

/// 扫码后的后续操作
/// ```dart
/// GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();
/// qrViewKey.currentState.startScan();
/// ```
class QrcodeReaderViewState extends State<QrcodeReaderView> with TickerProviderStateMixin, QrReaderViewMixin {
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    initAnimation();
  }

  @override
  Widget build(BuildContext context) {
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
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: QrReaderView(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                callback: onCreateController,
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
                      animationValue: animationController.value,
                      isForward: animationController.status == AnimationStatus.forward,
                    ),
                    child: SizedBox(
                      width: qrScanSize,
                      height: qrScanSize,
                    ),
                  ),
                  DefaultTextStyle(
                    style: TextStyle(color: Colors.white),
                    child: widget.helpWidget ?? Text("${widget.text ?? '请将二维码置于方框中'}"),
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
                  child: Image.asset(
                    "assets/${openFlashlight ? flashOpen : flashClose}",
                    package: "flutter_qr_scan",
                    width: 35,
                    height: 35,
                    color: Colors.white,
                  ),
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
                    onTap: scanImage,
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
  Future Function(String? p1, String? p2) get onScan => widget.onScan;
}
