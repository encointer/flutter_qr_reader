import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_qr_scan/flutter_qr_scan.dart';
import 'package:flutter_qr_scan_example/scanViewDemo.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QrReaderViewController? _controller;
  bool isOk = false;
  String? data;
  String? rawData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text("请求权限"),
              onPressed: () async {
                final status = await Permission.camera.request();
                log(status.toString());
                if (status.isGranted) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(child: Text("ok")),
                  );
                  setState(() {
                    isOk = true;
                  });
                }
              },
            ),
            ElevatedButton(
              child: Text("独立UI"),
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ScanViewDemo()));
              },
            ),
            ElevatedButton(
              onPressed: () async {
                var image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image == null) return;
                final rest = await FlutterQrReader.imgScan(File(image.path));
                setState(() {
                  data = rest;
                });
              },
              child: Text("识别图片"),
            ),
            ElevatedButton(
              child: Text("切换闪光灯"),
              onPressed: () {
                assert(_controller != null);
                _controller?.setFlashlight();
              },
            ),
            ElevatedButton(
              child: Text("开始扫码（暂停后）"),
              onPressed: () {
                assert(_controller != null);
                _controller?.startCamera(onScan);
              },
            ),
            if (data != null) Text('$data\nrawData: $rawData'),
            if (isOk)
              Container(
                width: 320,
                height: 350,
                child: QrReaderView(
                  width: 320,
                  height: 350,
                  callback: (container) {
                    this._controller = container;
                    _controller?.startCamera(onScan);
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  void onScan(String? v, List<Offset> offsets, String? raw) {
    debugPrint('${[v, offsets, raw]}');
    setState(() {
      data = v;
      rawData = raw;
    });
    _controller?.stopCamera();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
