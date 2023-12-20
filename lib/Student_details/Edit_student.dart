import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled25/Utils/utils.dart';
import '../Appurl.dart';
import '../Homepage.dart';
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
  final place = TextEditingController();

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
          place.text = userData?['school']['place'] ?? '';
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


        // if (!data['error'] && data['success']) {
        //   print('Data updated successfully');
        // } else {
        //   print('Error updating data: ${data['message']}');
        // }
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
    place.dispose();
    classCategory.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: CircleAvatar(
                backgroundColor: checkIncolor,
                child: Icon(Icons.home_filled, color: Colors.white),
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
                  Row(
                    children: [
                      CircleAvatar(radius: 45),
                      SizedBox(
                        width: 225,
                        child: MyTextFieldWidget(
                          labelName: 'Name',
                          controller: stdName,
                          validator: () {},
                          enabled: isEditing,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  MyTextFieldWidget(
                    labelName: 'School',
                    controller: schoolname,
                    validator: () {},
                    enabled: isEditing,
                  ),
                  MyTextFieldWidget(
                    labelName: 'Place',
                    controller: place,
                    validator: () {},
                    enabled: isEditing,
                  ),
                  MyTextFieldWidget(
                    labelName: 'Class',
                    controller: classCategory,
                    validator: () {},
                    enabled: isEditing,
                  ),
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
                              setState(() {
                                isEditing = true;
                                // savedetails();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, color: pinkColor),
                                Text(
                                  'Edit',
                                  style: TextStyle(color: pinkColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 52,
                          width: 156,
                          child: MyButtonWidget(
                            buttonName: "Save",
                            bgColor: openScanner,
                            onPressed: () {
                              print('555555555555555:${userData!['id'].toString()}');
                              setState(() {
                                savedetails(int.parse(userData!['id'].toString()));
                                isEditing = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
          ),
        ),
    );
  }
}
