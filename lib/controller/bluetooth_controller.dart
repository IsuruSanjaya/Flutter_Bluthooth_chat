// import 'dart:async';

// import 'package:app_scope/views/chatScreen/chat.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class BluetoothDeviceView extends StatefulWidget {
//   @override
//   _BluetoothDeviceViewState createState() => _BluetoothDeviceViewState();
// }

// class _BluetoothDeviceViewState extends State<BluetoothDeviceView> {
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _selectedDevice;
//   late StreamSubscription<List<ScanResult>> _scanSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }

//   @override
//   void dispose() {
//     _stopScan();
//     super.dispose();
//   }

//   void _startScan() {
//     _scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
//       setState(() {
//         _scanResults = results;
//       });
//     });
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//   }

//   void _stopScan() {
//     _scanSubscription.cancel();
//     FlutterBluePlus.stopScan();
//   }

//   void _connectToDevice(BluetoothDevice device) async {
//     // Disconnect any existing connections
//     if (_selectedDevice != null) {
//       await _selectedDevice!.disconnect();
//     }

//     // Connect to the selected device
//     await device.connect();
//     setState(() {
//       _selectedDevice = device;
//     });

//     // Navigate to the ChatScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(device: device),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Devices'),
//       ),
//       body: ListView.builder(
//         itemCount: _scanResults.length,
//         itemBuilder: (context, index) {
//           final device = _scanResults[index].device;
//           final deviceName = device.name.isNotEmpty ? device.name : 'Unknown Device';
//           return ListTile(
//             title: Text(deviceName),
//             subtitle: Text(device.id.toString()),
//             trailing: ElevatedButton(
//               onPressed: () => _connectToDevice(device),
//               child: Text('Connect'),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
