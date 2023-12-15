import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled25/Utils/utils.dart';
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

class _AddStudentState extends State<AddStudent> {
  File? _image;
  final stdName = TextEditingController();
  final schoolname = TextEditingController();
  final classCategory = TextEditingController();
  final place = TextEditingController();

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> addStudent() async {
    final apiUrl = AppUrl.std_register;

    final data = {
      "parent_id": Utils.userLoggedId,
      "name": stdName.text,
      "photo": _image != null ? _image!.path : "",
      "school": {
        "school_name": schoolname.text,
        "place": place.text,
      },
      "class_category": classCategory.text,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {

      print('API Response: ${response.body}');

    } else {
      print('Error - Status Code: ${response.statusCode}');
      print('Error - Response Body: ${response.body}');

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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(),));
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
                    child: MyTextFieldWidget(labelName: 'Name', controller: stdName, validator: () {}),
                  ),
                ],
              ),

              SizedBox(height: 20),
              MyTextFieldWidget(labelName: 'School', controller: schoolname, validator: () {}),
              MyTextFieldWidget(labelName: 'Place', controller: place, validator: () {}),
              MyTextFieldWidget(labelName: 'Class', controller: classCategory, validator: () {}),
              SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: "Cancel",
                        bgColor: pinkColor,
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(),));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: "Save",
                        bgColor: openScanner,
                        onPressed: () {
                          addStudent();
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
