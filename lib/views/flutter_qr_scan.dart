import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_qr_scan/flutter_qr_reader.dart';

class QrReaderView extends StatefulWidget {
  const QrReaderView({
    super.key,
    this.width,
    this.height,
    this.callback,
    this.autoFocusIntervalInMs = 500,
    this.torchEnabled = false,
  });

  final void Function(QrReaderViewController)? callback;
  final int autoFocusIntervalInMs;
  final bool torchEnabled;
  final double? width;
  final double? height;

  @override
  State<QrReaderView> createState() => _QrReaderViewState();
}

class _QrReaderViewState extends State<QrReaderView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        viewType: 'me.hetian.flutter_qr_reader.reader_view',
        creationParams: {
          'width': (widget.width! * window.devicePixelRatio).floor(),
          'height': (widget.height! * window.devicePixelRatio).floor(),
          'extra_focus_interval': widget.autoFocusIntervalInMs,
          'extra_torch_enabled': widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'me.hetian.flutter_qr_reader.reader_view',
        creationParams: {
          'width': widget.width,
          'height': widget.height,
          'extra_focus_interval': widget.autoFocusIntervalInMs,
          'extra_torch_enabled': widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      );
    } else {
      return const Text('平台暂不支持');
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
