import 'package:flutter/services.dart';

typedef ReadChangeBack = void Function(String?, List<Offset>, String?);

class QrReaderViewController {
  QrReaderViewController(this.id) : _channel = MethodChannel('me.hetian.flutter_qr_reader.reader_view_$id') {
    _channel.setMethodCallHandler(_handleMessages);
  }
  final int id;
  final MethodChannel _channel;
  late ReadChangeBack onQrBack;

  Future<void> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onQRCodeRead':
        final points = <Offset>[];
        if ((call.arguments as Map).containsKey('points')) {
          final pointsStrs = (call.arguments as Map)['points'] as List;
          // ignore: cascade_invocations
          pointsStrs.map((e) {
            if (e is String) {
              final a = e.split(',');
              points.add(Offset(double.tryParse(a.first)!, double.tryParse(a.last)!));
            }
          });
        }
        String? rawData = '';
        if ((call.arguments as Map).containsKey('rawData')) {
          rawData = (call.arguments as Map)['rawData'] as String;
        }

        onQrBack((call.arguments as Map)['text'] as String?, points, rawData);
        break;
    }
  }

  // 打开手电筒
  Future<bool?> setFlashlight() async {
    return _channel.invokeMethod('flashlight');
  }

  // 开始扫码
  Future<bool?> startCamera(ReadChangeBack onQrBack) async {
    this.onQrBack = onQrBack;
    return _channel.invokeMethod('startCamera');
  }

  // 结束扫码
  Future<bool?> stopCamera() async {
    return _channel.invokeMethod('stopCamera');
  }

  // Future<bool?> dispose() async {
  //   return _channel.invokeMethod("dispose");
  // }
}
