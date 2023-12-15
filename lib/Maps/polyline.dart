import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class polyline extends StatefulWidget {
  @override
  _polylineState createState() => _polylineState();
}

class _polylineState extends State<polyline> {
  MapController mapController = MapController();
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  LatLng startPoint = LatLng(11.2754584, 75.780497) ;
  LatLng endPoint = LatLng(11.2756921, 75.7802376);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Your Child',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu, color: Colors.black),
        elevation: 0,
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: startPoint ?? LatLng(0, 0),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/chaavie4uat/clq4saeke003m01pq96r2djfq/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY2hhYXZpZTR1YXQiLCJhIjoiY2t3b3NleGMyMDV6cTJ2cG10Y2Rma3dmYyJ9.QfqK1jEXt-aLBf-wwuYYDw',
            additionalOptions: {
              'accessToken':
              'pk.eyJ1IjoiY2hhYXZpZTR1YXQiLCJhIjoiY2t3b3NleGMyMDV6cTJ2cG10Y2Rma3dmYyJ9.QfqK1jEXt-aLBf-wwuYYDw',
              'id': 'mapbox.satellite',
            },
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylineCoordinates,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: startPoint ?? LatLng(0, 0),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
              ),
              Marker(
                width: 40.0,
                height: 40.0,
                point: endPoint,
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        startPoint = LatLng(position.latitude, position.longitude);
      });

      _getPolyline();
    } catch (e) {
      print('Error getting location: $e');
      // Handle error, show a message to the user, etc.
    }
  }

  void _getPolyline() async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'pk.eyJ1IjoiY2hhYXZpZTR1YXQiLCJhIjoiY2t3b3NleGMyMDV6cTJ2cG10Y2Rma3dmYyJ9.QfqK1jEXt-aLBf-wwuYYDw',
        PointLatLng(startPoint.latitude, startPoint.longitude),
        PointLatLng(endPoint.latitude, endPoint.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {});
      }
    } catch (e) {
      print('Error getting polyline: $e');
      // Handle error, show a message to the user, etc.
    }
  }
}
