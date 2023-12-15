import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


// const String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your API key

class TrackingPage extends StatefulWidget {
  const  TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(10.7898404, 76.6932198);
  static const LatLng destination = LatLng(10.788125, 76.6950658);

  List<LatLng> polylineCoordinates = [];
  Position? currentLocation;
  void getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = position;
      });
    } else {
      // Handle permission denied
      print("Location permission denied");
    }
  }


  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //
  //   if (currentLocation != null) {
  //     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       googleApiKey,
  //       PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //       PointLatLng(destination.latitude, destination.longitude),
  //     );
  //
  //     if (result.points.isNotEmpty) {
  //       setState(() {
  //         result.points.forEach((PointLatLng point) {
  //           polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //         });
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    // getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking page'),
      ),
      body: currentLocation == null
          ? Center(child: const Text('Loading'))
          : GoogleMap(
        polylines: Set<Polyline>.from([
          Polyline(
            polylineId: PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 6,
          ),
        ]),
        initialCameraPosition: CameraPosition(
          target: LatLng(
            currentLocation!.latitude,
            currentLocation!.longitude,
          ),
          zoom: 14.5,
        ),
        markers: Set<Marker>.from([
          Marker(
            markerId: MarkerId('source'),
            position: sourceLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'Source Location'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'Destination'),
          ),
          Marker(
            markerId: MarkerId('current Location'),
            position: LatLng(
              currentLocation!.latitude,
              currentLocation!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'Current Location'),
          ),
        ]),
      ),
    );
  }
}
