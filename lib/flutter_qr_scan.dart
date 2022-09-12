import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterQrReader {
  static const MethodChannel _channel = const MethodChannel('me.hetian.flutter_qr_reader');

  static Future<String?> imgScan(File file) async {
    if (file.existsSync() == false) {
      return null;
    }
    try {
      final rest = await _channel.invokeMethod(
        "imgQrCode",
        {"file": file.path},
      );
      return rest;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}

class QrReaderView extends StatefulWidget {
  final Function(QrReaderViewController)? callback;

  final int autoFocusIntervalInMs;
  final bool torchEnabled;
  final double? width;
  final double? height;

  const QrReaderView({
    Key? key,
    this.width,
    this.height,
    this.callback,
    this.autoFocusIntervalInMs = 500,
    this.torchEnabled = false,
  }) : super(key: key);

  @override
  State<QrReaderView> createState() => _QrReaderViewState();
}

class _QrReaderViewState extends State<QrReaderView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "me.hetian.flutter_qr_reader.reader_view",
        creationParams: {
          "width": (widget.width! * window.devicePixelRatio).floor(),
          "height": (widget.height! * window.devicePixelRatio).floor(),
          "extra_focus_interval": widget.autoFocusIntervalInMs,
          "extra_torch_enabled": widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        ].toSet(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "me.hetian.flutter_qr_reader.reader_view",
        creationParams: {
          "width": widget.width,
          "height": widget.height,
          "extra_focus_interval": widget.autoFocusIntervalInMs,
          "extra_torch_enabled": widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        ].toSet(),
      );
    } else {
      return Text('平台暂不支持');
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.callback!(QrReaderViewController(id));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

typedef ReadChangeBack = void Function(String?, List<Offset>, String?);

class QrReaderViewController {
  QrReaderViewController(this.id) : _channel = MethodChannel('me.hetian.flutter_qr_reader.reader_view_$id') {
    _channel.setMethodCallHandler(_handleMessages);
  }
  final int id;
  final MethodChannel _channel;
  late ReadChangeBack onQrBack;

  Future _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "onQRCodeRead":
        final points = <Offset>[];
        if (call.arguments.containsKey("points")) {
          final pointsStrs = call.arguments["points"];
          for (String point in pointsStrs) {
            final a = point.split(",");
            points.add(Offset(double.tryParse(a.first)!, double.tryParse(a.last)!));
          }
        }
        String? rawData = '';
        if (call.arguments.containsKey("rawData")) {
          rawData = call.arguments["rawData"];
        }

        this.onQrBack(call.arguments["text"], points, rawData);
        break;
    }
  }

  // 打开手电筒
  Future<bool?> setFlashlight() async {
    return _channel.invokeMethod("flashlight");
  }

  // 开始扫码
  Future<bool?> startCamera(ReadChangeBack onQrBack) async {
    this.onQrBack = onQrBack;
    return _channel.invokeMethod("startCamera");
  }

  // 结束扫码
  Future<bool?> stopCamera() async {
    return _channel.invokeMethod("stopCamera");
  }
}
