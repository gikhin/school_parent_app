import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled25/Appurl.dart';
import 'package:untitled25/Utils/utils.dart';
import '../Homepage.dart';
import '../Widgets/buttons.dart';
import '../Widgets/text_field.dart';
import '../constants.dart';

import 'Login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final email = TextEditingController();
  final guardian = TextEditingController();
  final address = TextEditingController();


  Map<String, dynamic>? userData;


  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse(AppUrl.parentDetail);
    print(AppUrl.parentDetail);
    final requestBody = {"parent_id": Utils.userLoggedId};

    try {

      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );
      print('body is:${jsonEncode(requestBody)}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (!data['error'] && data['success']) {
          setState(() {
            userData = data['data'][0];
            // Update the text controllers with the fetched data
            name.text = userData?['name'] ?? '';
            phoneNumber.text = userData?['mobile'] ?? '';
            email.text = userData?['email'] ?? '';
            guardian.text = userData?['guardian'] ?? '';
            address.text = userData?['address'] ?? '';
          });
        } else {
         print('error');
        }
      } else {
        print(response.body);
      }
    } catch (error) {

    }
  }

  Future<void> saveUserData() async {
    final url = Uri.parse(AppUrl.parentEdit);
    print(AppUrl.parentEdit);
    final requestBody = {
      "parent_id": Utils.userLoggedId,
      "name": name.text,
      "email": email.text,
      "address": address.text,
      "guardian": guardian.text,
      "mobile":phoneNumber.text,
    };
    print('hey prabu:${jsonEncode(requestBody)}');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {"Content-Type": "application/json"},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('heeeeeeeee$data');
        // if (!data['error'] && data['success']) {
        //
        //   print('Data updated successfully');
        // } else {
        //
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
                      controller: name,
                      enabled: isEditing, // Enable or disable based on editing mode
                      validator: () {},
                    ),
                  ),
                ],
              ),
              MyTextFieldWidget(
                labelName: 'Phone Number',
                controller: phoneNumber,
                enabled: isEditing,
                validator: () {},
              ),
              MyTextFieldWidget(
                labelName: 'Email',
                controller: email,
                enabled: isEditing,
                validator: () {},
              ),
              MyTextFieldWidget(
                labelName: 'Guardian',
                controller: guardian,
                enabled: isEditing,
                validator: () {},
              ),
              MyTextFieldWidget(
                labelName: 'Address',
                controller: address,
                enabled: isEditing,
                validator: () {},
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
                      child: MyButtonWidget(
                        buttonName: "Log out",
                        bgColor: pinkColor,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Loginpage()),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      width: 156,
                      child: MyButtonWidget(
                        buttonName: isEditing ? "Save" : "Edit",
                        bgColor: isEditing ? Colors.teal : openScanner,
                        onPressed: () {
                          setState(() {
                            print(isEditing);
                            isEditing = !isEditing;
                            if (!isEditing) {
                              saveUserData();
                            }
                          });
                        },
                      ),
                    ),

                  ],
                ),
              ),
              // Display user details

            ],
          ),
        ),
      ),
    );
  }
}
