import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Map_Screen.dart';
import 'ProfilePage.dart';
import 'Reservations_Screen.dart';

class Station_Owner_Map extends StatefulWidget {
  const Station_Owner_Map({Key? key}) : super(key: key);

  @override
  State<Station_Owner_Map> createState() => _Station_Owner_MapState();
}

class _Station_Owner_MapState extends State<Station_Owner_Map> {
  CameraPosition? _initialCameraPosition;
  late GoogleMapController _googleMapController;
  bool _locationPermissionGranted=false;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Completer<GoogleMapController> _controllerCompleter = Completer();
  int _selectedIndex = 0;
  final Map_Screen _mapScreen=Map_Screen();
  final ProfilePage _profilePage=ProfilePage();
  final Reservations_Screen _reservations_screen =Reservations_Screen();

  @override
  void initState() {
    getCurrentLocation();
    //addCustomIcon();
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

  Future <void> getCurrentLocation() async{
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text('The app needs access to your location to function properly. Please enable location permission in the app settings.'),
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
            title:  Text('Location Permission Denied Forever'),
            content:  Text('The app can\'t be used without location permission. Please enable location permission in the app settings to continue.'),
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

  // void addCustomIcon() {
  //   BitmapDescriptor.fromAssetImage(
  //     const ImageConfiguration(size: Size(48, 48)),
  //     'images/icon1.png',
  //   ).then(
  //         (icon) {
  //       setState(() {
  //         markerIcon = icon;
  //       });
  //     },
  //   );
  // }


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
    bool isMapScreen=_selectedIndex==0;
    bool showAppBar=isMapScreen;
    return Scaffold(
      appBar: showAppBar?AppBar(
        title: _selectedIndex==0?const Text('Easy Charge'):null,
      ):null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Container(
            child:_initialCameraPosition!=null? GoogleMap(
              initialCameraPosition: _initialCameraPosition!,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controllerCompleter.complete(controller);
                _googleMapController = controller;
              },
              mapType: MapType.normal,
            ) :const Center(child: CircularProgressIndicator()),
          ),
          _reservations_screen,
          _profilePage,
        ],
      ),

      floatingActionButton:isMapScreen? FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () async {
          final GoogleMapController controller = await _controllerCompleter.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition!));
        },
        child: const Icon(Icons.center_focus_strong),
      ):null,
      bottomNavigationBar: BottomNavigationBar(
        type:BottomNavigationBarType.fixed,
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
            label: 'Reservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

    );
  }


}
