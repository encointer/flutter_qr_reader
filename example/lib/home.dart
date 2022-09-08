import 'dart:developer';
import 'dart:io';

import 'package:example/scan_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_qr_scan/flutter_qr_scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(),
          ElevatedButton(
            child: const Text("Request Permission"),
            onPressed: () async {
              final status = await Permission.camera.request();
              log(status.toString());
              if (status.isGranted) {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text("ok"),
                      content: Text("ok"),
                    );
                  },
                );
                setState(() {
                  isOk = true;
                });
              }
            },
          ),
          ElevatedButton(
            child: const Text("Standalone UI"),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanViewDemo(),
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text("Identify Pictures"),
            onPressed: () async {
              var image = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image == null) return;
              final rest = await FlutterQrReader.imgScan(File(image.path));
              setState(() {
                data = rest;
              });
            },
          ),
          ElevatedButton(
            child: const Text("Toggle Flash"),
            onPressed: () => _controller?.setFlashlight(),
          ),
          ElevatedButton(
            child: const Text("Start scanning code (after pause)"),
            onPressed: () => _controller?.startCamera(onScan),
          ),
          if (data != null) Text('$data\nrawData: $rawData'),
          isOk
              ? Center(
                  child: SizedBox(
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
                )
              : const SizedBox(),
        ],
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
