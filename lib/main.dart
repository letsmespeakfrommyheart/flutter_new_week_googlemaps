import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MapPage());
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location location = Location();
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  Set<Polyline> polyline = {};

  void _onMapCreated(GoogleMapController mapController) {
    _controller.complete(mapController);
    _mapController = mapController;
  }

  _checkLocationPermission() async {
    bool locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        return;
      }
    }

    PermissionStatus locationForAppStatus = await location.hasPermission();
    if (locationForAppStatus == PermissionStatus.denied) {
      await location.requestPermission();
      locationForAppStatus = await location.hasPermission();
      if (locationForAppStatus != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _addMarkerFirst(LatLng position) {
    markers.add(Marker(
        markerId: const MarkerId("start"),
        infoWindow: const InfoWindow(title: "Start"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: position));

    setState(() {});
  }

  void _addMarkerSecond(LatLng position) {
    markers.add(Marker(
        markerId: const MarkerId("finish"),
        infoWindow: const InfoWindow(title: "Finish"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        position: const LatLng(37.78590137034642, -122.40644507211299)));

    polyline.add(Polyline(
      polylineId: const PolylineId("polyline"),
      color: Colors.white,
      width: 5,
      points: markers.map((marker) => marker.position).toList(),
    ));

    setState(() {});
  }

  @override
  initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map page"),
      ),
      body: Stack(alignment: Alignment.center, children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.78590137034642, -122.40644507211299),
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: _onMapCreated,
          mapType: MapType.satellite,
          markers: markers,
          polylines: polyline,
          onTap: _addMarkerFirst,
          tiltGesturesEnabled: true,
        ),
        const Icon(
          Icons.beenhere_rounded,
          color: Colors.red,
          size: 60,
        ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Row(
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _addMarkerSecond(
                    const LatLng(37.78590137034642, -122.40644507211299));
              });
            },
            label: const Text("Проложить"),
          ),
          const SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                markers.clear();
                polyline.clear();
              });
            },
            child: const Text("Сброс"),
          ),
        ],
      ),
    );
  }
}
