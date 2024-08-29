import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEChatHomePage extends StatefulWidget {
  const BLEChatHomePage({super.key});
  @override
  State<BLEChatHomePage> createState() => _BLEChatHomePageState();
}

class _BLEChatHomePageState extends State<BLEChatHomePage> {
  //FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? chatCharacteristic;

  List<BluetoothDevice> availableDevices = [];
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  void scanForDevices() async {
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 4),
    );

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        availableDevices = results.map((r) => r.device).toList();
      });
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    discoverServices();
  }

  void disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    }
  }

  void discoverServices() async {
    List<BluetoothService> services = await connectedDevice!.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.uuid.toString() == "<Your-Characteristic-UUID>") {
          chatCharacteristic = characteristic;
          listenForMessages();
        }
      });
    });
  }

  void listenForMessages() {
    chatCharacteristic?.value.listen((value) {
      String receivedMessage = utf8.decode(value);
      setState(() {
        messages.add("Received: $receivedMessage");
      });
    });
  }

  void sendMessage(String message) {
    String jsonString = jsonEncode({"message": message});
    List<int> utf8Message = utf8.encode(jsonString);
    chatCharacteristic?.write(utf8Message);

    setState(() {
      messages.add("Sent: $message");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Chat App'),
        actions: [
          connectedDevice == null
              ? IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: scanForDevices,
                )
              : IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: disconnectDevice,
                ),
        ],
      ),
      body: connectedDevice == null ? buildDeviceList() : buildChatScreen(),
    );
  }

  Widget buildDeviceList() {
    return ListView.builder(
      itemCount: availableDevices.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(availableDevices[index].name),
          onTap: () => connectToDevice(availableDevices[index]),
        );
      },
    );
  }

  Widget buildChatScreen() {
    TextEditingController messageController = TextEditingController();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages[index]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: "Enter message",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage(messageController.text);
                  messageController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
