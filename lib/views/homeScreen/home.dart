import 'package:flutter/material.dart';
import '../chatScreen/connection.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Offset> _elementAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds:20),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
          ..addListener(() {
            setState(() {});
          });
    _elementAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1, 1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 50.0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1.0,
              child: Column(
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10), // Adjust as needed
                  Text(
                    'Tour Mate',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 80,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: GestureDetector(
              onTap: () {
                // Navigate to Bluetooth device screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BluetoothDeviceView()),
                );
              },
              child: Icon(
                Icons.warning,
                size: 120.0,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        color: Colors.transparent,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Color.fromARGB(255, 248, 0, 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  // Navigate to Home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.white),
                onPressed: () {
                  // Navigate to Chat screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BluetoothDeviceView()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // Navigate to Settings screen
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const ""()),
                  // );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
