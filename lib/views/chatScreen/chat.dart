import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutterBluePlus;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as flutterBluetoothSerial;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_scope/views/chatScreen/map.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import LatLng
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import font_awesome_flutter

class ChatScreen extends StatefulWidget {
  final flutterBluetoothSerial.BluetoothDevice device;
  final flutterBluetoothSerial.BluetoothConnection connection;

  ChatScreen({required this.device, required this.connection});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    widget.connection.input?.listen(_onDataReceived).onDone(() {
      print('Disconnected by remote request');
    });
    _requestLocationPermission();
  }

  void _onDataReceived(Uint8List data) {
    setState(() {
      String message = String.fromCharCodes(data).trim();
      _messages.add({
        "message": message,
        "sender": widget.device.name ?? 'Unknown Device'
      });
      _saveMessages();
    });
  }

  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messages = prefs.getStringList('messages');
    if (messages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(messages
            .map((msg) => Map<String, String>.from(jsonDecode(msg)))
            .toList());
      });
    }
  }

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      try {
        widget.connection.output
            .add(Uint8List.fromList(utf8.encode(message + "\r\n")));
        await widget.connection.output.allSent;
        setState(() {
          _messages.add({"message": message, "sender": "Me"});
          _saveMessages();
        });
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messages = _messages.map((msg) => jsonEncode(msg)).toList();
    await prefs.setStringList('messages', messages);
  }

  void _requestLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _navigateToMapScreen() async {
    final Map<String, dynamic>? locationData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );
    if (locationData != null) {
      double latitude = locationData['latitude'];
      double longitude = locationData['longitude'];
      _sendMessage('Location: $latitude, $longitude');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.device.name ?? 'Unknown Device'}'),
        backgroundColor: Colors.red, // Set app bar color to red
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: MessageBubble(
                    message: message['message']!,
                    isSentByMe: message['sender'] == 'Me',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                      FontAwesomeIcons.mapMarkerAlt), // Use Google Maps icon
                  onPressed: _navigateToMapScreen,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _textController.text;
                    _sendMessage(message);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;

  const MessageBubble({
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isSentByMe ? Color.fromARGB(255, 248, 0, 0) : Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft:
                    isSentByMe ? Radius.circular(20) : Radius.circular(0),
                bottomRight:
                    isSentByMe ? Radius.circular(0) : Radius.circular(20),
              ),
            ),
            child: Wrap(
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
