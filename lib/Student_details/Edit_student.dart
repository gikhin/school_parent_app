import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:untitled25/Utils/utils.dart';
import '../Appurl.dart';
import '../Homepage.dart';
import '../Login and signup/Login.dart';
import '../Widgets/text_field.dart';
import '../Widgets/buttons.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class EditStudent extends StatefulWidget {
  int stdId;
  EditStudent({required this.stdId,Key? key}) : super(key: key);

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  File? _image;
  final stdName = TextEditingController();
  final schoolname = TextEditingController();
  final classCategory = TextEditingController();
  final locationName = TextEditingController();
  final vehicle = TextEditingController();
  final gender = TextEditingController();

  List<String> _predictions = [];
  List<String> _predictionsSchool = [];
  List<String> _Schoolpredictions = [];
  List<dynamic> locationEntrieses = [];
  List<dynamic> schoolEntrieses = [];
  List<String> _vehicleNumbers = ['kl09 7021', 'KL 55 A 124', 'KL 45 A 125', 'KL 35 A 126', 'KL 25 A 127'];
  TextEditingController autocompleteController = TextEditingController();

  Map<String, dynamic>? userData;

  bool isEditing = false;

  Future<void> fetchUserData() async {
    print('fetchUserData called');
    final url = Uri.parse(AppUrl.stdParentDetails);
    final requestBody = {
      "id": widget.stdId
      // int.parse(widget.stdId.toString())
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {

        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          userData = data;
          print('user data = ${data}');
        });

        setState(() {
          userData = data['data'][0];
          stdName.text = userData?['name'] ?? '';
          schoolname.text = userData?['school']['school_name'] ?? '';
          locationName.text = userData?['address']['place'] ?? '';
          vehicle.text = userData?['vehicle'] ?? '';
          classCategory.text = userData?['class_category'] ?? '';
          gender.text = userData?['gender'] ?? '';

        });

      } else {
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  Future<void> savedetails(int stdID) async {
    final url = Uri.parse(AppUrl.editchild);
    final requestBody = {
      "student_id": stdID,
      "name": stdName.text,
      "photo":"https://thumbs.dreamstime.com/b/basic-rgb-basic-rgb-219903843.jpg",
      "school":schoolname.text,
      "class_category": classCategory.text,
      "gender": gender.text.toUpperCase(),
      "parent_id":Utils.userLoggedId
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          final Map<String, dynamic> data = jsonDecode(response.body);
        });


        Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage(),));
        Fluttertoast.showToast(msg: 'Updated Successfully');

      } else {
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during HTTP request: $error');
    }
  }

  /// Google address Location
  void _onSearchChanged(String query) {
    // Call the Google Places API to get predictions
    _getPlacePredictions(query);
  }

  Future<void> _getPlacePredictions(String input) async {
    String apiKey = AppUrl.gKey;
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final predictions = json.decode(response.body)['predictions'];

      setState(() {
        _predictions = predictions.map((prediction) {
          return prediction['description'];
        }).cast<String>().toList();
      });

      // Extract latitude and longitude for each prediction
      for (var prediction in predictions) {
        String placeId = prediction['place_id'];
        await _getPlaceDetails(placeId);
      }
    } else {
      throw Exception('Failed to load place predictions');
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    String apiKey = AppUrl.gKey;
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final placeDetails = json.decode(response.body)['result'];

      if (placeDetails != null) {
        String address = placeDetails['formatted_address'];
        List<Location> locations = await locationFromAddress(address);

        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;

        print('School Name - Place ID: $placeId, Latitude: $latitude, Longitude: $longitude');
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }


  void _onPlaceSelected(String place) async {
    try {
      List<Location> locations = await locationFromAddress(place);

      if (locations.isNotEmpty) {
        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;

        setState(() {
          locationName.text = place;
          _predictions.clear();

          Map<String, dynamic> schoolEntry = {
            'name': place,
            'latitude': latitude,
            'longitude': longitude,
          };
          locationEntrieses.add({'school': schoolEntry, 'stops': []});
        });

        // Display information in the console
        print('Selected School:');
        print('Namesss: $place');
        print('Latitudeplace: $latitude');
        print('Longitudeplace: $longitude');
      }
    } catch (error) {
      print('Error while geocoding place: $error');
      // Handle the error as needed
    }
  }


  /// Google address Location School
  void _onSearchChangedSchool(String query) {
    // Call the Google Places API to get predictions
    _getPlacePredictionsSchool(query);
  }

  Future<void> _getPlacePredictionsSchool(String input) async {
    String apiKey = AppUrl.gKey;
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final predictions = json.decode(response.body)['predictions'];

      setState(() {
        _predictionsSchool = predictions.map((prediction) {
          return prediction['description'];
        }).cast<String>().toList();
      });

      // Extract latitude and longitude for each prediction
      for (var prediction in predictions) {
        String placeId = prediction['place_id'];
        await _getPlaceDetailsSchool(placeId);
      }
    } else {
      throw Exception('Failed to load place predictions');
    }
  }

  Future<void> _getPlaceDetailsSchool(String placeId) async {
    String apiKey = AppUrl.gKey;
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final placeDetails = json.decode(response.body)['result'];

      if (placeDetails != null) {
        String address = placeDetails['formatted_address'];
        List<Location> locations = await locationFromAddress(address);

        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;

        print('School Name - Place ID: $placeId, Latitude: $latitude, Longitude: $longitude');
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }


  void _onPlaceSelectedSchool(String place) async {
    try {
      List<Location> locations = await locationFromAddress(place);

      if (locations.isNotEmpty) {
        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;

        setState(() {
          schoolname.text = place;
          _predictionsSchool.clear();

          Map<String, dynamic> schoolEntry = {
            'name': place,
            'latitude': latitude,
            'longitude': longitude,
          };
          schoolEntrieses.add({'school': schoolEntry, 'stops': []});
        });

        // Display information in the console
        print('Selected School:');
        print('Namesss: $place');
        print('Latitudeplace: $latitude');
        print('Longitudeplace: $longitude');
      }
    } catch (error) {
      print('Error while geocoding place: $error');
      // Handle the error as needed
    }
  }

  void showVehicleNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Vehicle Number'),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), // Adjust the padding as needed
          content: Container(
            width: 200, // Adjust the width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min, // Set to min to reduce height
              children: _vehicleNumbers
                  .map((vehicleNumber) => ListTile(
                title: Text(vehicleNumber),
                onTap: () {
                  setState(() {
                    vehicle.text = vehicleNumber;
                    autocompleteController.text = vehicleNumber;
                  });
                  Navigator.pop(context); // Close the dialog
                },
              ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    print('passsed id is:${widget.stdId}');
    super.initState();
    fetchUserData();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    stdName.dispose();
    schoolname.dispose();
    locationName.dispose();
    classCategory.dispose();
    gender.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
              child:CircleAvatar(
                backgroundImage: NetworkImage(Utils.photUrl == null ?
                'https://images.unsplash.com/photo-1480455624313-e'
                    '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                    'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D':Utils.photUrl.toString(),
                ),
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(radius: 45,
                    backgroundImage: NetworkImage(Utils.photUrl == null ?
                    'https://images.unsplash.com/photo-1480455624313-e'
                        '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                        'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D':Utils.photUrl.toString(),
                    ),
                  ),
                  SizedBox(
                    width: 225,
                    child: MyTextFieldWidget(
                      enabled: isEditing,

                        labelName: 'Name', controller: stdName, validator: () {}),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 23.0),
                child: Text('School'),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(width: 323,
                          height: 40,
                          child:
                          TextFormField(enabled: isEditing,

                            controller: schoolname,
                            onChanged: _onSearchChangedSchool,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: fillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            ),
                          ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true, // Added to prevent a rendering error
                        itemCount: _predictionsSchool.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_predictionsSchool[index]),
                            onTap: () {
                              // Handle the selected place
                              _onPlaceSelectedSchool(_predictionsSchool[index]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextFieldWidget(
                    enabled: isEditing,labelName: 'Class', controller: classCategory, validator: () {}),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 23.0),
                child: Text('Location'),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(width: 323,
                          height: 40,
                          child:
                          TextFormField(
                            enabled: isEditing,

                            controller: locationName,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: fillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            ),
                          ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true, // Added to prevent a rendering error
                        itemCount: _predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_predictions[index]),
                            onTap: () {
                              // Handle the selected place
                              _onPlaceSelected(_predictions[index]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: MyTextFieldWidget(
              //       enabled: isEditing,labelName: 'Vehicle', controller: vehicle, validator: () {}),
              // ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(enabled: isEditing,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  ),
                  controller: vehicle,

                  onTap: () {
                    // Open the autocomplete overlay on tap
                    autocompleteController.text = vehicle.text;
                    showVehicleNumberDialog();
                  },
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextFieldWidget(
                    enabled: isEditing,labelName: 'Gender', controller: gender, validator: () {}),
              ),


              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.blue.shade100,
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: TextFormField(
              //     style: TextStyle(
              //       color: scanColor,
              //     ),
              //     controller: placeName,
              //     onTap:() async {
              //       var place = await PlacesAutocomplete.show(
              //           logo: Text(''),
              //           context: context,
              //           apiKey: AppUrl.gKey,
              //           mode: Mode.overlay,
              //           types: [],
              //           strictbounds: false,
              //           components: [
              //             Component(Component.country, 'ind'),
              //           ],
              //
              //           //google_map_webservice package
              //           onError: (err){
              //             print('error');
              //           }
              //       );
              //
              //       if(place != null){
              //         setState(() {
              //           placeName.text = place.description.toString();
              //         });
              //
              //         //form google_maps_webservice package
              //         final plist = GoogleMapsPlaces(apiKey:AppUrl.gKey,
              //           apiHeaders: await GoogleApiHeaders().getHeaders(),
              //           //from google_api_headers package
              //         );
              //         String placeid = place.placeId ?? "0";
              //         final detail = await plist.getDetailsByPlaceId(placeid);
              //         final geometry = detail.result.geometry!;
              //         // pickupLatitude = geometry.location.lat;
              //         // pickupLongitude = geometry.location.lng;
              //       }
              //     },
              //     decoration:InputDecoration(
              //       isDense: true,
              //       contentPadding: EdgeInsets.only(left: 10,top: 15),
              //       suffixIcon: Icon(Icons.location_on_outlined,color: Colors.green,),
              //       border: InputBorder.none,
              //       // focusedErrorBorder: OutlineInputBorder(
              //       //     borderSide:
              //       //     BorderSide(color: Colors.blue),
              //       //     borderRadius: BorderRadius.circular(20)),
              //       // errorBorder:OutlineInputBorder(
              //       //     borderSide:
              //       //     BorderSide(color: Colors.blue),
              //       //     borderRadius: BorderRadius.circular(20)) ,
              //       // enabledBorder: OutlineInputBorder(
              //       //     borderRadius: BorderRadius.circular(20.0),
              //       //     borderSide: BorderSide(color: Color(0xfff05acff),width: 1)
              //       // ),
              //
              //       // focusedBorder: OutlineInputBorder(
              //       //     borderSide:
              //       //     BorderSide(color: Colors.blue),
              //       //     borderRadius: BorderRadius.circular(20)),
              //     ),
              //     validator: (value) =>
              //     value!.isEmpty ? 'invalid data' : null,
              //   ),
              // ),

              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            // Toggle the editing state when the "Edit" button is pressed
                            isEditing = !isEditing;
                          });

                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: pinkColor),
                        ),
                        child: Text('Edit', style: TextStyle(color: pinkColor)),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: "Save",
                        bgColor: openScanner,
                        onPressed: () {
                         savedetails(int.parse(userData!['id'].toString()));
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          ),
        ),
    );
  }
}
