import 'dart:async';

import 'package:flutter/widgets.dart';

import 'MapChannel.dart';
import 'NativeMsg.dart';

enum MapStyle {
  common,
  ride,
  carAreas,
  scanner,
}

enum MapType { vector, satellite }

class MapController {

  late final MapChannel _channel = TextureMapChannel();
  final _messages = StreamController<Map<String, dynamic>>.broadcast();

  Future<int> get mapId => _channel.mapId;

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Size? _mapSize;

  Size? get mapSize => _mapSize;

  MapController();

  void initialize({required Size mapSize}) {
    _channel.initialize(mapSize: mapSize);
  }

  void dispose() {
    _channel.dispose();
    _channel.channel.then((channel) => channel.setMessageHandler(null));
    _messages.close();
  }

  final Map<String, Completer<String?>> _callbacks = {};

  Future<String?> send(NativeMsg msg) async {
    final completer = Completer<String?>();
    _callbacks[msg.id] = completer;
    final channel = await _channel.channel;
    channel.send(msg.pack);
    final result = await completer.future;
    _callbacks.remove(msg.id);
    return result;
  }
}
