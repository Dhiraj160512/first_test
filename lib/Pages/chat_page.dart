import 'package:ble_chat_app/Model/chat_message_model.dart';
import 'package:ble_chat_app/Services/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {
  final BluetoothDevice device;

 const  ChatPage({super.key,
  required this.device});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> messages = [];
  final TextEditingController messageController = TextEditingController();
  late BluetoothCharacteristic characteristic;

  @override
  void initState() {
    super.initState();
    _setupCharacteristic();
  }

  void _setupCharacteristic() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((c) {
        if (c.properties.write && c.properties.read) {
          characteristic = c;
        }
      });
    });
  }

  void _sendMessage() async {
    final messageText = messageController.text;
    final bleService = Provider.of<BLEService>(context, listen: false);
    await bleService.sendMessage(characteristic, messageText);
    setState(() {
      messages.add(ChatMessage(message: messageText, timestamp: DateTime.now()));
    });
    messageController.clear();
  }

  void _receiveMessage() async {
    final bleService = Provider.of<BLEService>(context, listen: false);
    final jsonString = await bleService.receiveMessage(characteristic);
    final message = ChatMessage.fromJson(jsonString);
    setState(() {
      messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.device.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index].message),
                  subtitle: Text(messages[index].timestamp.toString()),
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
                    decoration: const InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon:const  Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
