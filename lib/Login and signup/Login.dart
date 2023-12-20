import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:untitled25/Appurl.dart';
import 'package:untitled25/Utils/utils.dart';
import '../Homepage.dart';
import '../Widgets/buttons.dart';
import '../Widgets/text_field.dart';
import '../constants.dart';
import 'Signup.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final userName = TextEditingController();
  final password = TextEditingController();

  Future<void> loginUser() async {
    final Map<String, String> data = {
      'userid': userName.text,
      'password': password.text,
    };

    try {
      final response = await http.post(
        Uri.parse(AppUrl.login),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        var responsedata = jsonDecode(response.body);
        print('uuuuuuu${responsedata['data']['id']}');
        Utils.userLoggedId = int.parse(responsedata['data']['id'].toString());
        print('aaaaa${Utils.userLoggedId}');

        print(result);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
        Fluttertoast.showToast(msg: 'Welcome back!.');

      } else {

        print('Error - Status Code: ${response.statusCode}');
        print('Error - Response Body: ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'User ID Or Password Is Incorrect.');


      print('Login failed: Exception: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:       Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextFieldWidget(labelName: 'Email or username', controller: userName, validator: (){},),
            MyTextFieldWidget(labelName: 'Password', controller: password, validator: (){},),
            MyButtonWidget(buttonName: 'Login', bgColor: openScanner, onPressed: (){
              loginUser();
            }),

            TextButton(onPressed: () {

            }, child: TextButton(onPressed: () {
             loginUser();

            }, child: Text('Dont have an account?'))),
            Column(
              children: [
                Text('Sign in with google'),
                SizedBox(height: 50,
                  child: IconButton(onPressed: () {
                  }, icon: Image.network('https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png')),
                ),
              ],
            )
          ],

        ),
      ),
    );
  }
}
