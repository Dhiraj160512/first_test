import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BLEService {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(timeout:const Duration(seconds: 4),);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<void> sendMessage(BluetoothCharacteristic characteristic, String message) async {
    final jsonString = json.encode({"message": message, "timestamp": DateTime.now().toIso8601String()});
    final utf8Message = utf8.encode(jsonString);
    await characteristic.write(utf8Message);
  }

  Future<String> receiveMessage(BluetoothCharacteristic characteristic) async {
    final data = await characteristic.read();
    final jsonString = utf8.decode(data);
    return jsonString;
  }
}
