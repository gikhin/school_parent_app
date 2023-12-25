import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Appurl.dart';
import '../Homepage.dart';
import '../Widgets/buttons.dart';
import '../Widgets/text_field.dart';
import '../constants.dart';
import 'Login.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final guardianController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> _registerUser() async {
    try {
      final Map<String, dynamic> requestData = {
        "name": nameController.text,
        "email": emailController.text,
        "password":passwordController.text,
        "mobile": mobileController.text,
        "guardian":guardianController.text,
        "address": addressController.text,
      };

      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(AppUrl.signUp),
        headers: requestHeaders,
        body: jsonEncode(requestData),
      );
      print(requestData);

      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage(),));
        Fluttertoast.showToast(msg: 'User signup was successful.');
        
        print('successfullyyyyyy');
        final responseJson = json.decode(response.body);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error');
      print('Error fetching customer details: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:   SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Sign Up',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                MyTextFieldWidget(labelName: 'User Name', controller: nameController, validator: (){},),
                MyTextFieldWidget(labelName: 'Email', controller: emailController, validator: (){},),

                MyTextFieldWidget(labelName: 'Phone', controller: mobileController, validator: (){},),
                MyTextFieldWidget(labelName: 'Guardian', controller: guardianController, validator: (){},),
                MyTextFieldWidget(labelName: 'Password', controller: passwordController, validator: (){},),
                MyButtonWidget(buttonName: 'Sign Up', bgColor: openScanner, onPressed: (){
                 _registerUser();
                }),
            
                TextButton(onPressed: () {
            
                }, child: TextButton(onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginpage(),));
            
                }, child: Text('Already have an account?'))),
                // Column(
                //   children: [
                //     Text('Sign in with google'),
                //     IconButton(onPressed: () {
                //
                //     }, icon: Image.network('https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png')),
                //   ],
                // )
              ],
            
            ),
          ),
        ),
      ),
    );
  }
}
