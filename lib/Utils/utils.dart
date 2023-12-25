import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../Appurl.dart';
import '../Homepage.dart';

class Utils{
  static int? userLoggedId;
  static String? userLoggedNewID;
  static String? userLoggedName;
  static String? photUrl;
  static String? userLoggedEmail;

  static toastMessage(String message){
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red
    );
  }
  static flushBarErrorMessage(String message , BuildContext context,Color color){
    showFlushbar(context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        positionOffset: 20,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(20),
        icon: const Icon(Icons.error ,size: 28,color: Colors.white,),
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        backgroundColor: color,
        messageColor: Colors.white,
        duration: const Duration(seconds: 3),
      )..show(context),
    );}

  static snackBar(String message , BuildContext context ) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(message))
    );

  }

  //google sign in

  static bool signedwithgoogle = false;

  // static final GoogleSignIn googleSignIn = GoogleSignIn();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  //signout function
  static Future<void> signoutgoogle(BuildContext context) async{
    await _googleSignIn.signOut();
    Utils.userLoggedName = '';
    Utils.userLoggedEmail = '';
    Utils.userLoggedId = -1;
    Utils.userLoggedNewID;
    Utils.photUrl = null;
  }


  //check email is already registered, if not registered store it as a new user,
  static Future<void> checkingEmail(String email,String gID,String name)async{
    final Map<String,dynamic> requestBody = {
      'name':name.toString(),
      'google_id':gID.toString(),
      'email':email.toString(),
    };
    try{
      print('check in with google called.....');
      print('App url : ${AppUrl.checkEmail}');
      final response =await http.post(Uri.parse(AppUrl.checkEmail),
          headers: <String,String>{'Content-Type':'application/json',},
          body: jsonEncode(requestBody));
      print('sending body is${jsonEncode(requestBody)}');
      print(AppUrl.checkEmail);
      if(response.statusCode == 200){
        final responsedata =jsonDecode(response.body);
        // print(response.body);
        print('google sign in daaata:${responsedata['data']}');
        Utils.userLoggedId = responsedata['data']['id'];
      }else{
        print('else is worked,,,,0');
        print('${response.body}');
        var responsedata = jsonDecode(response.body);
        print('response is:${responsedata['data']['id']}');
        Utils.userLoggedId = responsedata['data']['id'];
        print('${response.body}');

        print('Failed.Status code ${response.statusCode}');
      }
    }catch(e){
      print('Error occured:$e');
    }
  }

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      print('email is:${googleSignInAccount!.email}');

      if (googleSignInAccount != null) {
        print('hey picked email is:${googleSignInAccount.email}');
        checkingEmail(
            googleSignInAccount.email.toString(),
            googleSignInAccount.id.toString(),
            googleSignInAccount.displayName.toString()
        );

        print('User email:${googleSignInAccount.email}');
        print('User ID:${googleSignInAccount.id}');
        // Util.userLogedID = int.tryParse(googleSignInAccount.id.trim()) ?? 0;
        Utils.userLoggedEmail = googleSignInAccount.email.toString();
        Utils.userLoggedName = googleSignInAccount.displayName.toString();
        Utils.userLoggedNewID = googleSignInAccount.id.toString();
        print('--------------------');
        print('${Utils.userLoggedEmail}');
        print('${Utils.userLoggedName}');
        print('${Utils.userLoggedNewID}');
        print(('${Utils.photUrl}'));
        print('----------------------');
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      print('user issss...${user}');
      if (user == null) {
        signedwithgoogle = false;
        print('error');
      }
      if (user != null) {
        Utils.photUrl = user.photoURL.toString();
        signedwithgoogle = true;

        print(user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      }
    } catch (e) {
      print('Error: $e'); // Print the error message for debugging
      signoutgoogle(context);
      Utils.flushBarErrorMessage(
          'Error occurred while signing in with Google!', context,Colors.red);
    }
  }


}
