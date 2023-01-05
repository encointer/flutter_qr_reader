import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/flutter_qr_reader.dart';

class ScanViewDemo extends StatefulWidget {
  const ScanViewDemo({super.key});

  @override
  State<ScanViewDemo> createState() => _ScanViewDemoState();
}

class _ScanViewDemoState extends State<ScanViewDemo> {
  final GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScanViewDemo')),
      body: SafeArea(
        child: QrcodeReaderView(
          key: _key,
          onScan: onScan,
        ),
      ),
    );
  }

  Future<void> onScan(String? data, String? rawData) async {
    if (data != null && data.contains('eldiiar')) {
      Navigator.pop(context, data);
    } else {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('扫码结果'),
            content: Text('$data\n$rawData'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('确认'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    }
  }
}
