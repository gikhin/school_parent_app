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

  @override
  void initState() {
    print('passsed id is:$widget.stdId');
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse(AppUrl.stdParentDetails);
    final requestBody = {"parent_id": int.parse(widget.stdId.toString())};

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('hey data is :${data}');
        print('sssssssss:${data['data'][0]}');

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

  Future<void> saveUserData() async {
    final url = Uri.parse(AppUrl.parentEdit);
    final requestBody = {
      "parent_id": Utils.userLoggedId,
      "name": stdName.text,
      "class_category": classCategory.text,
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (!data['error'] && data['success']) {
          print('Data updated successfully');
        } else {
          print('Error updating data: ${data['message']}');
        }
      } else {
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during HTTP request: $error');
    }
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
                          });
                        },
                        child: Row(
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
                          saveUserData();
                          setState(() {
                            isEditing = false;
                          });
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
