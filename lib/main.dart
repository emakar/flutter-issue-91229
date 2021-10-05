import 'dart:math';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'ForegroundStateObserver.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera',
      home: CameraIssue(),
    );
  }
}

class CameraIssue extends StatefulWidget {
  const CameraIssue({Key? key}) : super(key: key);

  @override
  _CameraIssueState createState() => _CameraIssueState();
}

class _CameraIssueState extends State<CameraIssue> with ForegroundStateObserver {
  CameraController? _controller;

  @override
  void didForeground() {
    _initCamera();
  }

  @override
  void didBackground() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return controller != null && controller.value.isInitialized
        ? CameraPreview(controller)
        : SizedBox.expand();
  }

  Future<void> _initCamera() async {
    final camera = await availableCameras().then((cameras) {
      return cameras.firstWhereOrNull((e) => e.lensDirection != CameraLensDirection.front);
    }).onError((error, stackTrace) {
      debugPrint("camera: availableCameras error: ${error?.toString()}");
      return null;
    });
    if (!mounted || camera == null) {
      return;
    }
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller?.initialize().then((_) {
      if (_controller == null) {
        return;
      }
      setState(() {});
    }).onError((error, stackTrace) {
      debugPrint("camera: initialize error: ${error?.toString()}");
    });
  }
}
