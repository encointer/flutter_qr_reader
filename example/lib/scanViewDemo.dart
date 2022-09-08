import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';

class ScanViewDemo extends StatefulWidget {
  const ScanViewDemo({Key? key}) : super(key: key);

  @override
  _ScanViewDemoState createState() => new _ScanViewDemoState();
}

class _ScanViewDemoState extends State<ScanViewDemo> {
  GlobalKey<QrcodeReaderViewState> _key = GlobalKey();

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
          title: Text("扫码结果"),
          content: Text('$data\n$rawData'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("确认"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
    _key.currentState?.startScan();
  }
}
