import 'dart:developer';

import 'package:example/scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QrReaderViewController? _controller;
  bool isOk = false;
  String? data;
  String? rawData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(),
            ElevatedButton(
              child: const Text('请求权限'),
              onPressed: () async {
                final status = await Permission.camera.request();
                log(status.toString());
                if (status.isGranted) {
                  await showDialog<void>(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text('ok'),
                        content: Text('ok'),
                      );
                    },
                  );
                }
              },
            ),
            ElevatedButton(
              child: const Text('独立UI'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<String?>(
                    builder: (context) => const ScanViewDemo(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: const Text('切换闪光灯'),
              onPressed: () => _controller?.setFlashlight(),
            ),
            ElevatedButton(
              child: const Text('开始扫码（暂停后)'),
              onPressed: () => _controller?.startCamera(onScan),
            ),
            if (data != null) Text('$data\nrawData: $rawData'),
            ElevatedButton(
              child: const Text('Start scan'),
              onPressed: () {
                setState(() {
                  isOk = !isOk;
                });
              },
            ),
            if (isOk)
              SizedBox(
                width: 320,
                height: 350,
                child: QrReaderView(
                  width: 320,
                  height: 350,
                  callback: (val) {
                    _controller = val;
                    _controller?.startCamera(onScan);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onScan(String? v, List<Offset> offsets, String? raw) {
    log('${[v, offsets, raw]}');
    setState(() {
      data = v;
      rawData = raw;
    });
    _controller?.stopCamera();
  }
}
