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

class _CameraIssueState extends State<CameraIssue> with WidgetsBindingObserver {
  CameraController? _controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _initCamera();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // @override
  // void didForeground() {
  //   _initCamera();
  // }

  // @override
  // void didBackground() {
  //   _controller?.dispose();
  //   _controller = null;
  // }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return controller != null && controller.value.isInitialized
        ? CameraPreview(controller)
        : SizedBox.expand();
  }

  Future<void> _initCamera() async {
    final camera = await availableCameras().then((cameras) {
      return cameras.firstWhereOrNull(
          (e) => e.lensDirection != CameraLensDirection.front);
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
