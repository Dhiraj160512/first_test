import 'package:ble_chat_app/Services/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});
  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  List<BluetoothDevice> devicesList = [];

   

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  void _scanForDevices() {
    final bleService = Provider.of<BLEService>(context, listen: false);
    bleService.startScan();
    bleService.flutterBlue.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devicesList[index].name),
            onTap: () async {
              final bleService = Provider.of<BLEService>(context, listen: false);
              await bleService.connect(devicesList[index]);
              Navigator.pushNamed(context, '/chat', arguments: devicesList[index]);
            },
          );
        },
      ),
    );
  }
}
