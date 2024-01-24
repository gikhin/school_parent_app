import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled25/Utils/utils.dart';
import 'package:untitled25/Widgets/customDropdown.dart';
import '../Appurl.dart';
import '../Homepage.dart';
import '../Widgets/text_field.dart';
import '../Widgets/buttons.dart';
import '../constants.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({Key? key}) : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudentState();
}
enum Gender { Male, Female, Other }
extension GenderExtension on Gender {
  String get stringValue {
    switch (this) {
      case Gender.Male:
        return 'male';
      case Gender.Female:
        return 'female';
      case Gender.Other:
        return 'other';
    }
  }
}
class _AddStudentState extends State<AddStudent> {
  File? _image;
  final stdName = TextEditingController();
  final schoolname = TextEditingController();
  final classCategory = TextEditingController();
  final locationName = TextEditingController();
  final vehicle = TextEditingController();
  Gender selectedGender = Gender.Male;
  List<String> _predictions = [];
  List<String> _predictionsSchool = [];
  List<String> _Schoolpredictions = [];
  List<dynamic> locationEntrieses = [];
  List<dynamic> schoolEntrieses = [];

  List<String> _vehicleNumbers = ['kl09 7021', 'KL 55 A 124', 'KL 45 A 125', 'KL 35 A 126', 'KL 25 A 127'];
  TextEditingController autocompleteController = TextEditingController();

  // void showVehicleNumberDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select a Vehicle Number'),
  //         content: Column(
  //           children: _vehicleNumbers
  //               .map((vehicleNumber) => ListTile(
  //             title: Text(vehicleNumber),
  //             onTap: () {
  //               setState(() {
  //                 vehicle.text = vehicleNumber;
  //                 autocompleteController.text = vehicleNumber;
  //               });
  //               Navigator.pop(context); // Close the dialog
  //             },
  //           ))
  //               .toList(),
  //         ),
  //       );
  //     },
  //   );
  // }

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


  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> addStudent(context) async {
    final apiUrl = AppUrl.std_register;

    final data = {
      "name": stdName.text,
      "photo": _image != null ? _image!.path : "",
      "school": {
        "school_name": schoolname.text,
        "place": locationName.text,
      },
      "class_category": classCategory.text,
      "parent_id": Utils.userLoggedId,
      "address":{
        "home_name":locationName.text,
        "place":locationName.text
      },
      "vehicle":vehicle.text,
      "gender":selectedGender.stringValue
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print("Vvvvvvvv${jsonEncode(data)}");

    if (response.statusCode == 200) {
      print('successs...');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(),));
      Fluttertoast.showToast(msg: 'Child Added Successfully');

      print('API Response: ${response.body}');


    } else {
      print('Error - Status Code: ${response.statusCode}');
      print('Error - Response Body: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getData() async {
    try {
      // Make the GET request
      final response = await http.get(Uri.parse(AppUrl.completeDrivers));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response JSON
        Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody;
      } else {
        // Handle the error if the request was not successful
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to get data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      throw Exception('Failed to get data');
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


  Future<void> getVehiclenum() async {
    try {
      final apiUrl = AppUrl.findingVehicleno;

      final data = {
        "school_name": [
          {
            "name": schoolname,
            "address": schoolname,
          }
        ]
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successful POST request
        print('POST request successful');
        print('Responseeeee: ${response.body}');
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to make POST request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error making POST request: $error');
      // Handle the error as needed
    }
  }



  // List<String> vehicles = [
  //   '',
  // ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // List<String> getSuggestions(String query) {
  //   // You can replace this with your own logic to fetch suggestions
  //   return suggestions
  //       .where((element) =>
  //       element.toLowerCase().contains(query.toLowerCase()))
  //       .toList();
  // }


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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(),));
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
                  CircleAvatar(radius: 45),
                  SizedBox(
                    width: 225,
                    child: MyTextFieldWidget(labelName: 'Name', controller: stdName, validator: () {}),
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
                          TextFormField(

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
                child: MyTextFieldWidget(labelName: 'Class', controller: classCategory, validator: () {}),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Vehicle'),
                  // Autocomplete<String>(
                  //   optionsBuilder: (TextEditingValue textEditingValue) {
                  //     return vehicles.where(
                  //           (String suggestion) => suggestion
                  //           .toLowerCase()
                  //           .contains(textEditingValue.text.toLowerCase()),
                  //     );
                  //   },
                  //   onSelected: (String selected) {
                  //     vehicle.text = selected;
                  //   },
                  //   fieldViewBuilder: (BuildContext context,
                  //       TextEditingController fieldTextEditingController,
                  //       FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                  //     return Container(
                  //       child: TextField(
                  //         controller: vehicle,
                  //
                  //         decoration: InputDecoration(
                  //           filled: true,
                  //           fillColor: fillColor,
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(6.0),
                  //             borderSide: BorderSide.none,
                  //           ),
                  //           contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  //         ),
                  //       ),
                  //
                  //     );
                  //   },
                  //   optionsViewBuilder: (BuildContext context,
                  //       AutocompleteOnSelected<String> onSelected,
                  //       Iterable<String> options) {
                  //     return Material(
                  //       elevation: 4.0,
                  //       child: ListView(
                  //         children: options
                  //             .map(
                  //               (String option) => GestureDetector(
                  //             onTap: () {
                  //               onSelected(option);
                  //             },
                  //             child: ListTile(
                  //               title: Text(option),
                  //             ),
                  //           ),
                  //         ).toList(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MyTextFieldWidget(
                        //
                        //   labelName: 'Vehicle',
                        //   controller: vehicle,
                        //   validator: () {},
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Text('Vehicle'),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
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
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Radio(activeColor: openScanner,
                        value: Gender.Male,
                        groupValue: selectedGender,
                        onChanged: (Gender? value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      Text('Male'),
                      Radio(activeColor: openScanner,
                        value: Gender.Female,
                        groupValue: selectedGender,
                        onChanged: (Gender? value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      Text('Female'),
                      Radio(activeColor: openScanner,
                        value: Gender.Other,
                        groupValue: selectedGender,
                        onChanged: (Gender? value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      Text('Other'),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Homepage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: pinkColor),
                        ),
                        child: Text('Cancel', style: TextStyle(color: pinkColor)),
                      ),
                    ),

                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: "Save",
                        bgColor: openScanner,
                        onPressed: () {
                          print("Aaaaaaaa");
                          addStudent(context);
                          Navigator.pop(context);


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
