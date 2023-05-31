import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login/Screen/SavedPage.dart';
import 'package:login/Screen/TripsPage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ProfilePage.dart';

class Map_Screen extends StatefulWidget {
  const Map_Screen({Key? key}) : super(key: key);

  @override
  State<Map_Screen> createState() => _Map_ScreenState();
}

class _Map_ScreenState extends State<Map_Screen> {
  CameraPosition? _initialCameraPosition;
  late GoogleMapController _googleMapController;
  bool _locationPermissionGranted = false;
  Completer<GoogleMapController> _controllerCompleter = Completer();
  int _selectedIndex = 0;
  Set<Marker> _markers = {};
  bool _showAddStationHint = false;
  Marker? lastAddedMarker;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _checkLocationPermission().then((granted) {
      setState(() {
        _locationPermissionGranted = granted;
      });
      if (!_locationPermissionGranted) {
        _requestLocationPermission();
      }
    });
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text(
                  'The app needs access to your location to function properly. Please enable location permission in the app settings.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permission Denied Forever'),
            content: const Text(
                'The app can\'t be used without location permission. Please enable location permission in the app settings to continue.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      );
    });
  }

  Future<bool> _checkLocationPermission() async {
    var status = await Permission.location.status;
    return status.isGranted;
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    setState(() {
      _locationPermissionGranted = status.isGranted;
    });
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMapScreen = _selectedIndex == 0;
    bool showAppBar = isMapScreen;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
        title: _selectedIndex == 0 ? const Text('Easy Charge') : null,
      )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Stack(
            children: [
              if (_initialCameraPosition != null)
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition!,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerCompleter.complete(controller);
                    _googleMapController = controller;
                  },
                  mapType: MapType.normal,
                  markers: _markers,
                  onTap: (LatLng position) {
                    _addMarker(position);
                    setState(() {
                      _showAddStationHint = true;
                    });
                  },
                )
              else
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (_showAddStationHint && _markers.isNotEmpty)
                ..._markers.map((marker) {
                  final position = marker.position;
                  return Positioned(
                    top: position.latitude,
                    left: position.longitude,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAddStationDialog();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: const Text(
                          'Add a new station',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
          SavedPage(),
          TripsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueAccent,
        selectedItemColor: Colors.greenAccent,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.electric_car_sharp),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng position) {
    final MarkerId markerId = MarkerId(position.toString());
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers.add(marker);
      lastAddedMarker = marker; // Assign the last added marker
    });
  }

  void _showAddStationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String stationName = '';

        return AlertDialog(
          title: const Text('Add a new station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  stationName = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Station Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // Remove the last added marker if it exists
                if (lastAddedMarker != null) {
                  _removeMarker(lastAddedMarker!);
                  lastAddedMarker = null; // Reset the last added marker
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // Process the entered station name here
                // You can add the necessary logic to store the station information
                // For now, let's just print the station name
                print('New station name: $stationName');

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeMarker(Marker marker) {
    setState(() {
      _markers.remove(marker);
    });
  }
}
