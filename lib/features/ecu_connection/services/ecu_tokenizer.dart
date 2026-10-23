
class EcuTokenizer {
  final StringBuffer _buffer = StringBuffer();

  /// Memproses potongan byte ASCII dari Bluetooth.
  /// Token dianggap lengkap saat ditemukan ';' atau '\n'.
  List<String> addBytes(List<int> bytes) {
    final tokens = <String>[];

    for (final byte in bytes) {
      final char = String.fromCharCode(byte);

      if (char == ';' || char == '\n') {
        final token = _buffer.toString().replaceAll('\r', '').trim();
        _buffer.clear();

        if (token.isNotEmpty) {
          tokens.add(token);
        }
      } else {
        _buffer.write(char);
      }
    }

    return tokens;
  }

  void reset() {
    _buffer.clear();
  }
}
