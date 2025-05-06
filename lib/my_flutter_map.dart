import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  final MapController _mapController = MapController();
  LatLng? selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Map ')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(33.8938, 35.5018),
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedPosition = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              if (selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: selectedPosition!,
                      child: Column(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 40),
                          Text(
                            '${selectedPosition!.latitude.toStringAsFixed(4)}, ${selectedPosition!.longitude.toStringAsFixed(4)}',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(33.8938, 35.5018),
                      child:
                          Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
              bottom: 165,
              right: 5,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom + 1);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )),
          Positioned(
              bottom: 115,
              right: 5,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom - 1);
                },
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                ),
              )),
          Positioned(
            bottom: 50,
            right: 5,
            child: FloatingActionButton(
              heroTag: "btn3",
              backgroundColor: Colors.white,
              onPressed: () async {
                _determinePosition().then(
                  (currentPosition) {
                    LatLng center = LatLng(
                        currentPosition.latitude, currentPosition.longitude);
                    _animatedMapMove(center, 18);
                  },
                );
              },
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    selectedPosition = destLocation;
    _mapController.move(LatLng(destLocation.latitude, destLocation.longitude),
        _mapController.camera.zoom);
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      const error = PermissionDeniedException("Location Permission is denied");

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(error);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const error =
          PermissionDeniedException("Location Permission is denied forever");

      return Future.error(error);
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      while (!await Geolocator.isLocationServiceEnabled()) {}
    }
    return await Geolocator.getCurrentPosition();
  }
}
