import 'dart:convert';

class NativeMsg {
  static int _id = 0;

  final String id = (++_id).toString();
  final String type;
  final String? _data;
  final Map<String, dynamic>? _jsonData;

  NativeMsg({required this.type, void Function(Map<String, dynamic> out)? out})
      : _data = null,
        _jsonData = _collectJson(out);

  NativeMsg.data({required this.type, String? data})
      : _data = data,
        _jsonData = null;

  String get pack => _createMsg(this);

  static Map<String, dynamic>? _collectJson(void Function(Map<String, dynamic> out)? out) {
    if (out != null) {
      Map<String, dynamic> data = {};
      out(data);
      return data;
    } else {
      return null;
    }
  }

  static String _createMsg(NativeMsg msg) {
    final jsonData = msg._jsonData;
    return jsonEncode({
      "id": msg.id,
      "type": msg.type,
      "data": msg._data ?? (jsonData != null ? jsonEncode(jsonData) : null),
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NativeMsg && runtimeType == other.runtimeType && type == other.type && _data == other._data;

  @override
  int get hashCode => type.hashCode ^ _data.hashCode;
}
