
// Konstanta protokol berdasarkan ECUProtocol.kt
// dari APK Juken 5 Live by KKRXAG.
//
// Catatan:
// - Nilai konstanta berasal dari hasil dekompilasi.
// - Urutan komunikasi tetap perlu diuji pada ECU.
// - Race Panel hanya untuk membaca data ECU.

class EcuProtocol {
  EcuProtocol._();

  // Perintah komunikasi
  static const String getVariable = '1607\r\n';
  static const String getMap = '1617\r\n';
  static const String readSensor = '1609\r\n';
  static const String openLive = '160A\r\n';
  static const String stopLive = '160B\r\n';
  static const String ping = '1B00\r\n';

  // Respons
  static const String ack = '1A00';
  static const String pingResponse = '1B01';

  // Header data
  static const String diagnosticHeader = 'A602';
  static const String liveHeader = 'A603';
  static const String variableHeader = '9606';
  static const String baseMapHeader = '9601';
  static const String fuelMapHeader = '9602';
  static const String injectorHeader = '9603';
  static const String ignitionHeader = '9605';
  static const String historyHeader = '9610';
  static const String modelHeader = '9616';
  static const String autoMappingHeader = '9614';

  // Tidak digunakan oleh Race Panel.
  // Jangan kirim perintah ini ke ECU.
  static const String execute = '5009\r\n';

  // Perintah ini belum diperlukan untuk pengujian Live.
  static const String diagnostic = '4602\r\n';
}
