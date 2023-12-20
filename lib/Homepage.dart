import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled25/Maps/Mapbox.dart';
import 'package:untitled25/Maps/polyline.dart';
import 'package:untitled25/Maps/polylinenew.dart';
import 'package:untitled25/Maps/trackingPage.dart';
import 'package:untitled25/Student_details/Add_student.dart';
import 'package:untitled25/Student_details/Edit_student.dart';
import 'package:untitled25/Utils/utils.dart';
import 'Appurl.dart';
import 'Login and signup/profile.dart';
import 'Notification.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<dynamic> tripDetails = [];

  Future<void> tripHistoryFunction( ) async {
    print('caaleddd....');
    Map<String, dynamic> data ={
      'id':Utils.userLoggedId
    };
    final response = await http.post(
      Uri.parse(AppUrl.stdDetails),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',

      },
      body: jsonEncode(data),
    );
    print(response);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var responsedata = jsonDecode(response.body);
      print(responsedata['data']);

        tripDetails.clear();
        tripDetails.addAll(responsedata['data']);
      print('hey....');
      // Successful API call
      print('API Response: ${response.body}');
    } else {
      // Error handling
      print('Error - Status Code: ${response.statusCode}');
      print('Error - Response Body: ${response.body}');
    }
  }

  @override
  void initState() {
    print('parent id is:${Utils.userLoggedId}');
    // TODO: implement initState
    tripHistoryFunction();
    super.initState();
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
              },
              child: Row(
                children: [
                  IconButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage(),));

                  }, icon: Icon(Icons.notifications,color: Colors.black,)),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1480455624313-e'
                          '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                          'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D',
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Hi ',
                      style: TextStyle(
                          color: textColor1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      'lala',
                      style: TextStyle(
                          color: openScanner,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Have a ',
                      style: TextStyle(
                          color: textColor1,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'QuickSand',
                          fontSize: 18),
                    ),
                    Text(
                      'good day...',
                      style: TextStyle(
                          color: scanColor,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'QuickSand',
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              Expanded(
                child: FutureBuilder(
                  future: tripHistoryFunction(),
                  builder: (context,index) {
                    return ListView.builder(
                        itemCount: tripDetails.length,
                        itemBuilder: (context, index) {
                          print(tripDetails.length);
                          print(tripDetails);
                          final tripDetail = tripDetails[index];

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: SizedBox(
                                    height: 200,
                                    width: 324.875,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Row(
                                              children: [
                                                // CircleAvatar(
                                                //   radius: 35.0,
                                                //   backgroundImage: NetworkImage(tripDetail['photo']),),
                                                CircleAvatar(
                                                  radius: 35.0,
                                                 ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                          const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            '${tripDetail['name'].toString().toUpperCase()}',),),
                                                          Text(
                                                            '${tripDetail['class_category'].toString().toUpperCase()}',
                                                            style: TextStyle(
                                                                color: Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            subtitle: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => polylineNew(),));
                                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => polyline(),));
                                                }, child: Text('polyline')),
                                                TextButton(
                                                    onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(),));
                                                }, child: Text('Track Your Kid'))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 55,
                                      width: 110,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: pinkColor),
                                          onPressed: () {
                                            print('for passing id:${tripDetails[0]['id']}');
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditStudent(stdId:int.parse(tripDetails[0]['id'].toString())),));
                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => EditStudent(stdId:tripDetail[0]['id'] ),));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Edit',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 55,
                                      width: 180,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: openScanner),
                                          onPressed: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Call Driver',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  }
                ),
              ),
              Row(
                children: [
                  CircleAvatar(radius: 25),
                  SizedBox(width: 30,),
                  SizedBox(
                    height: 55,
                    width: 230,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: addNow),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudent(),));

                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Add New',
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ),
                ],
              )

            ],
          ),
        ),
      )
    );
  }
}
