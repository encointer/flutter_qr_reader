import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_qr_scan/qrcode_reader_view.dart';

class ScanViewDemo extends StatefulWidget {
  const ScanViewDemo({Key? key}) : super(key: key);

  @override
  State<ScanViewDemo> createState() => _ScanViewDemoState();
}

class _ScanViewDemoState extends State<ScanViewDemo> {
  final GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QrcodeReaderView(
        key: _key,
        onScan: onScan,
        headerWidget: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
    );
  }

  Future onScan(String? data, String? rawData) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Scanning result"),
          content: Text('$data\n$rawData'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Confirm"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
    _key.currentState?.startScan();
  }
}
