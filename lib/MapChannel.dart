import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'NativeMsg.dart';

const _initChannel = BasicMessageChannel("map_view_factory", StringCodec());

abstract class MapChannel {
  Future<int> get mapId;

  Future<BasicMessageChannel<String>> get channel;

  void initialize({required Size mapSize});

  void dispose();
}

class PlatformMapChannel extends MapChannel {

  final String id;

  PlatformMapChannel({required this.id});

  final _channel = Completer<BasicMessageChannel<String>>();

  @override
  Future<BasicMessageChannel<String>> get channel => _channel.future;

  @override
  Future<int> get mapId => Future.value(0);

  @override
  void dispose() {}

  @override
  void initialize({required Size mapSize}) {}

  void didPlatformViewMapInitialize() {
    _channel.complete(Future.value(BasicMessageChannel(id, const StringCodec())));
  }
}

class TextureMapChannel extends MapChannel {
  var _initCalled = false;
  var _disposed = false;

  final _mapId = Completer<int>();
  final _channel = Completer<BasicMessageChannel<String>>();

  @override
  Future<int> get mapId => _mapId.future;

  @override
  Future<BasicMessageChannel<String>> get channel => _channel.future;

  @override
  void initialize({required Size mapSize}) async {
    if (_disposed) return;
    if (_initCalled) {
      _configure(mapSize);
      return;
    }
    _initCalled = true;
    final message = NativeMsg(type: "initialize", out: (out) => _putSize(out, mapSize)).pack;
    final id = await _initChannel.send(message) ?? "";
    if (!_disposed) {
      _mapId.complete(int.parse(id));
      _channel.complete(BasicMessageChannel("map_view_$id", const StringCodec()));
    }
  }

  Future<void> _configure(Size mapSize) async {
    if (_disposed) return;
    _mapId.future.then((mapId) async {
      final message = NativeMsg(
          type: "configure",
          out: (out) {
            _putId(out, mapId);
            _putSize(out, mapSize);
          }).pack;
      if (!_disposed) {
        _initChannel.send(message);
      }
    });
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_initCalled) {
      _mapId.future.then((id) async {
        final message = NativeMsg(type: "dispose", out: (out) => _putId(out, id)).pack;
        _initChannel.send(message);
      });
    }
  }
}

void _putId(Map<String, dynamic> out, int id) => out["mapId"] = id;

void _putSize(Map<String, dynamic> out, Size mapSize) {
  out["width"] = mapSize.width;
  out["height"] = mapSize.height;
}
