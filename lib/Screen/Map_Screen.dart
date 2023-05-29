import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _showCancelHint=false;
  Marker? _lastAddedMarker;

  @override
  void initState() {
    getCurrentLocation();
    _checkLocationPermission().then((granted) {
      setState(() {
        _locationPermissionGranted = granted;
      });
      if (!_locationPermissionGranted) {
        _requestLocationPermission();
      }
    });
    super.initState();
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
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    } else {
      setState(() {
        _locationPermissionGranted = false;
      });
    }
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
              Container(
                child: _initialCameraPosition != null
                    ? GoogleMap(
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
                    : const Center(child: CircularProgressIndicator()),
              ),
              if (_showAddStationHint)
                ..._markers.map((marker) {
                  final position = marker.position;
                  return Positioned(
                    top: position.latitude,
                    left: position.longitude,
                    child: GestureDetector(
                      onTap: (){
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
      _lastAddedMarker = marker; // Assign the last added marker
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
                if (_lastAddedMarker != null) {
                  _removeMarker(_lastAddedMarker!);
                  _lastAddedMarker = null;
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
      _markers = _markers.where((m) => m != marker).toSet();
    });
  }
}


