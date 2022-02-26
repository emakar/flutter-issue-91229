import 'package:flutter/material.dart';
import 'package:flutter_playground/MapChannel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map',
      home: MapWidget(),
    );
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapChannel? _channel;

  @override
  void initState() {
    super.initState();
    _channel = TextureMapChannel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _channel?.initialize(mapSize: MediaQuery.of(context).size);
  }

  @override
  void dispose() {
    _channel?.dispose();
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = _channel!;
    return FutureBuilder(
        future: channel.mapId,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Texture(textureId: snapshot.data as int);
          } else {
            return const SizedBox.expand();
          }
        });
  }
}
