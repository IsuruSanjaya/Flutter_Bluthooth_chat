import 'dart:async';
import 'package:app_scope/views/homeScreen/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_scope/views/chatScreen/chat.dart';

class BluetoothDeviceView extends StatefulWidget {
  @override
  _BluetoothDeviceViewState createState() => _BluetoothDeviceViewState();
}

class _BluetoothDeviceViewState extends State<BluetoothDeviceView> {
  List<BluetoothDiscoveryResult> _scanResults = [];
  BluetoothConnection? _connection;
  late StreamSubscription<BluetoothDiscoveryResult> _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartScan();
  }

  @override
  void dispose() {
    _stopScan();
    _connection?.dispose();
    super.dispose();
  }

  void _checkPermissionsAndStartScan() async {
    PermissionStatus locationPermission = await Permission.location.request();
    if (locationPermission.isGranted) {
      _startScan();
    } else {
      // Handle permission denial
      print('Location permission denied');
    }
  }

  void _startScan() {
    _scanSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      setState(() {
        if (_isSerialBluetoothDevice(result)) {
          _scanResults.add(result);
        }
      });
    });

    _scanSubscription.onDone(() {
      setState(() {});
    });
  }

  void _stopScan() {
    _scanSubscription.cancel();
  }

  bool _isSerialBluetoothDevice(BluetoothDiscoveryResult result) {
    final deviceName = result.device.name?.toLowerCase() ?? '';
    return deviceName.contains('hc-05') ||
        deviceName.contains('hc-06') ||
        deviceName.contains('serial');
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (_connection != null) {
      await _connection?.close();
      _connection = null;
    }

    FlutterBluetoothSerial.instance.cancelDiscovery();

    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatScreen(device: device, connection: connection),
        ),
      );
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
        title: Padding(
          padding: const EdgeInsets.all(5.0), // Adds padding around the text
          child: Text(
            'Bluetooth Devices',
            style: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, // Set the back arrow color to black
        ),
      ),
      body: _scanResults.isEmpty
          ? Center(child: Text('No devices found'))
          : ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final device = result.device;
                final deviceName = device.name?.isNotEmpty ?? false
                    ? device.name!
                    : 'Unknown Device';
                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(device.address),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToDevice(device),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
    );
  }
}
