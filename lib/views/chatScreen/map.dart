import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  LatLng? selectedLocation;
  LatLng defaultLocation = LatLng(37.42796133580664, -122.085749655962);

  Location location = Location();

  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async {
    try {
      LocationData locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
      });
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newLatLng(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!)));
      }
    } catch (e) {
      print('Could not get the location: $e');
    }
  }

  void onSendLocation() {
    if (selectedLocation != null) {
      Navigator.pop(context, {
        "latitude": selectedLocation!.latitude,
        "longitude": selectedLocation!.longitude
      });
    } else if (currentLocation != null) {
      Navigator.pop(context, {
        "latitude": currentLocation!.latitude,
        "longitude": currentLocation!.longitude
      });
    } else {
      Navigator.pop(context, {
        "latitude": defaultLocation.latitude,
        "longitude": defaultLocation.longitude
      });
    }
  }

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      selectedLocation = tappedPoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (currentLocation != null) {
                mapController.animateCamera(CameraUpdate.newLatLng(LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!)));
              }
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            onTap: _onMapTapped,
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('selected-location'),
                      position: selectedLocation!,
                    )
                  }
                : {},
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: selectedLocation != null || currentLocation != null
                  ? onSendLocation
                  : null,
              child: Icon(Icons.send),
            ),
          ),
          if (currentLocation == null)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
