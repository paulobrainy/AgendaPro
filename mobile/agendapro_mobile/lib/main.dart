import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location location = Location();
  LatLng? currentPosition;
  Set<Marker> markers = {};

  final String baseUrl = "http://192.168.0.97:8000";

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final loc = await location.getLocation();
    currentPosition = LatLng(loc.latitude!, loc.longitude!);
    await _loadEstablishments();
    setState(() {});
  }

  Future<void> _loadEstablishments() async {
    final url =
        "$baseUrl/establishments/nearby?lat=${currentPosition!.latitude}&lng=${currentPosition!.longitude}&radius_km=5";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    markers = data.map<Marker>((item) {
      return Marker(
        markerId: MarkerId(item['id']),
        position: LatLng(
          item['location']['coordinates'][1],
          item['location']['coordinates'][0],
        ),
        infoWindow: InfoWindow(title: item['name']),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition!,
          zoom: 14,
        ),
        myLocationEnabled: true,
        markers: markers,
      ),
    );
  }
}
