import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';

import '../Login and signup/profile.dart';
import '../constants.dart';



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Your child',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu, color: textColor1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1480455624313-e'
                      '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                      'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D',
                ),
              ),
            ),
          )
        ],
        elevation: 0,
      ),

      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(51.509364, -0.128928),
              zoom: 3.2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/chaavie4uat/clq4saeke003m01pq96r2djfq/tiles/256/{z}/{x}'
                    '/{y}@2x?access_token=pk.eyJ1IjoiY2hhYXZpZTR1YXQiLCJhIjoiY2t3b3NleGMyMDV6cTJ2cG10Y2Rma3dmYyJ9.QfqK1jEXt'
                    '-aLBf-wwuYYDw',
                additionalOptions: {'accessToken':'pk.eyJ1IjoiY2hhYXZpZTR1YXQiLCJhIjoiY2t3b3NleGMyMDV6cTJ2cG10Y2Rma3dmYyJ9.QfqK1jEXt-aLBf-wwuYYDw',
                  'id':'mapbox.satellite'
                },
              ),

            ],
          ),
        ],
      ),
    );
  }
}







//additionalOptions: {'accessToken':'pk.eyJ1IjoiY2hhYXZpZTR1YXQiLCJhIjoiY2t3b3NleGMyMDV6cTJ2cG10Y2Rma3dmYyJ9.QfqK1jEXt-aLBf-wwuYYDw',
//                   'id':'mapbox.satellite'
//                 },