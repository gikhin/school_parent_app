import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu, color: textColor1),
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
          child: Column(
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
                    child: MyTextFieldWidget(labelName: 'Name', controller: stdName, validator: () {}),
                  ),
                ],
              ),

              SizedBox(height: 20),
              MyTextFieldWidget(labelName: 'School', controller: schoolname, validator: () {}),

              MyTextFieldWidget(labelName: 'Class', controller: classCategory, validator: () {}),
              MyTextFieldWidget(labelName: 'Location', controller: locationName, validator: () {}),
              MyTextFieldWidget(labelName: 'Vehicle', controller: vehicle, validator: () {}),


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

              SizedBox(height: 100),
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
