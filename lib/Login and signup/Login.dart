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
        Utils.userLoggedNewID = responsedata['data']['id'].toString();
        Utils.userLoggedName = responsedata['data']['name'].toString();
        print('aaaaa${Utils.userLoggedId}');
        print('aaaaa${Utils.userLoggedName}');

        print(result);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
        Fluttertoast.showToast(msg: 'Welcome back!.');

      } else {
        Fluttertoast.showToast(msg: 'User ID Or Password Is Incorrect.');
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
    return Scaffold(backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.0,),
              CircleAvatar(backgroundColor: Colors.transparent,radius: 150,child: Image.asset('assets/login.jpg')),
              Text('Login',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,fontFamily: 'QuickSand'),),
              MyTextFieldWidget(labelName: 'Email Id', controller: userName, validator: (){},),
              MyTextFieldWidget(labelName: 'Password', controller: password, validator: (){},),
              MyButtonWidget(buttonName: 'Login', bgColor: openScanner, onPressed: (){
                loginUser();
              }),
          
              TextButton(onPressed: () {
              }, child: TextButton(onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage(),));
          
              }, child: Text('Dont have an account?'))),
              Column(
                children: [
                  Text('Sign in with google'),
                  SizedBox(height: 50,
                    child: IconButton(onPressed: () {
                      Utils.signInWithGoogle(context);
                    }, icon: Image.network('https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png')),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
