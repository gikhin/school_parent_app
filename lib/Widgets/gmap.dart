import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Gmap extends StatelessWidget {
  String buttonName;
  Color bgColor ;
  Function? onPressed;
  double lat;
  double long;

  Gmap({required this.lat,required this.long,required this.buttonName,required this.bgColor,required this.onPressed,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(0, 0), // Initial map center
        zoom: 15.0, // Initial zoom level
      ),
      markers: Set<Marker>.from([
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarker,
        ),
      ]),
    );
  }
}
