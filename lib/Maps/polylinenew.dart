import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:untitled25/Appurl.dart';
import '../constants.dart';
import 'Mapbox.dart';

class polylineNew extends StatefulWidget {
  double lat;
  double long;
  polylineNew({required this.lat,required this.long,Key? key}) : super(key: key);
  @override
  _polylineNewState createState() => _polylineNewState();
}

class _polylineNewState extends State<polylineNew> {
  MapController mapController = MapController();
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [
    LatLng(11.27964, 75.7817756),
    LatLng(11.2756921, 75.7802376)
  ];
  LatLng startPoint = LatLng(11.2795266, 75.7817756);
  // LatLng? startPoint;
  // LatLng? endPoint;
  LatLng endPoint = LatLng(11.27964, 75.7817756);
//////////
  Future<void> getDriverData() async {
    Map<String, dynamic> data = {
      "id":0000
    };
    try {
      // Encode the data to JSON
      String jsonData = jsonEncode(data);

      // Make the POST request
      final response = await http.post(
        Uri.parse(AppUrl.singleDriverDetails),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Request successful, do something with the response
        print('POST request successful');
        print('Response: ${response.body}');
      } else {
        // Request failed, handle the error
        print('POST request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      // Handle any exceptions that occur during the process
      print('Error during POST request: $error');
    }
  }
  //end of functions.....

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // setState(() {
        startPoint = LatLng(position.latitude, position.longitude);
        print("current location is: ${startPoint}");
      // });


      _getPolyline();
    } catch (e) {
      print('Error getting location: $e');
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
          print(polylineCoordinates);
        });
        setState(() {});
      }
    } catch (e) {
      print('Error getting polyline: $e');

      // Handle error, show a message to the user, etc.
    }
  }


  @override
  void initState() {
    super.initState();
    endPoint = LatLng(widget.lat, widget.long);
    _getCurrentLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Your Child',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconButton( color: textColor1, onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(),));
        }, icon: Icon(Icons.menu),),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context,index) {
          return FlutterMap(
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
                    strokeWidth: 6.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(11.2849971, 75.7817756) ?? LatLng(0, 0),
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
          );
        }
      ),
    );
  }

}
