import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled25/Maps/Mapbox.dart';
import 'package:untitled25/Maps/livelocationofstudent.dart';
import 'package:untitled25/Maps/polyline.dart';
import 'package:untitled25/Maps/polylinenew.dart';
import 'package:untitled25/Maps/trackingPage.dart';
import 'package:untitled25/Student_details/Add_student.dart';
import 'package:untitled25/Student_details/Edit_student.dart';
import 'package:untitled25/Utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
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
  List<Map<String, dynamic>> respData = [];
  Map<String,dynamic> tripDetailsmap ={};
  bool isLoading = true;

  String capitalize(String s) {
    if (s == null || s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }


  Future<void> tripHistoryFunction() async {
    isLoading = false;
    Map<String, dynamic> data = {'parent_id': Utils.userLoggedId};
    final response = await http.post(
      Uri.parse(AppUrl.stdDetails),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),

    );
    if (response.statusCode == 200) {
      print(respData);
      var responsedata = jsonDecode(response.body);
      setState(() {
        isLoading = true;
        respData.clear();
        respData.add(Map<String, dynamic>.from(responsedata['data']));
      });

    } else {
      isLoading = true;
      // Error handling
      print('Error - Status Code: ${response.statusCode}');
      print('Error - Response Body: ${response.body}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // tripHistoryFunction();
    loadData();
    super.initState();
  }
  Future<void> loadData() async {
    await tripHistoryFunction();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {print("Aaaa");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddStudent()),
            );
          },
          tooltip: 'Add',
          child: Icon(Icons.add),
          backgroundColor:openScanner,
        ),

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
                    backgroundImage: NetworkImage(Utils.photUrl == null ?
                      'https://images.unsplash.com/photo-1480455624313-e'
                          '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                          'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D':Utils.photUrl.toString(),
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
                    // Text(
                    //   '${Utils.userLoggedName.toString()}',
                    //   style: TextStyle(
                    //       color: openScanner,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 18),
                    // ),
                    Text(
                      '${capitalize(Utils.userLoggedName.toString())}',
                      style: TextStyle(
                        color: openScanner,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                child:
                    isLoading == false
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                : FutureBuilder(
                      future: loadData(),
                  builder: (context,index) {
                    return ListView.builder(
                        itemCount: respData[0]['studentWithDriverData'].length,
                        itemBuilder: (context, index) {
                          // print(tripDetails);
                          // final tripDetail = respData[index]['studentWithDriverData'];

                          return Column(
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration:BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 10.0,
                                        spreadRadius: -15,
                                        offset: Offset(
                                          -2,
                                          -2,
                                        ),
                                      )
                                    ]
                                  ),
                                  child: Card(
                                    child: SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Row(mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 35.0,
                                                  child: Text('${respData[0]['studentWithDriverData'][index]['studentData']['name'].toString().toUpperCase().trim().substring(0,1)}',style: TextStyle(
                                                    fontWeight: FontWeight.bold,fontSize: 18
                                                  ),),),
                                                  // CircleAvatar(
                                                  //   radius: 35.0,
                                                  //   backgroundImage: NetworkImage(respData[0]['studentWithDriverData'][index]['studentData']['photo']),),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                            padding:
                                                            const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              '${respData[0]['studentWithDriverData'][index]['studentData']['name'].toString().toUpperCase()}',style: TextStyle(fontWeight: FontWeight.bold),),),
                                                            Text(
                                                              '${respData[0]['studentWithDriverData'][index]['studentData']['class_category'].toString().toUpperCase()}',
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
                                                  if (respData[0]['studentWithDriverData'][index]['driverData'] != null)
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => polylineNew(
                                                              lat: double.parse(respData[0]['studentWithDriverData'][index]['driverData']['latitude'].toString()),
                                                              long: double.parse(respData[0]['studentWithDriverData'][index]['driverData']['longitude'].toString()),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Text('Track Your Vehicle'),
                                                    ),
                                                  // TextButton(
                                                  //     onPressed: () {
                                                  //       Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(),));
                                                  //       },
                                                  //     child: Text('Track Your Kid')),
                                                  // TextButton(
                                                  //     onPressed: () {
                                                  //       Navigator.push(context, MaterialPageRoute(builder: (context) => LiveLocStudent(
                                                  //
                                                  //         latitude:respData[0]['studentWithDriverData'][index]['driverData']['latitude'],
                                                  //         longitude:respData[0]['studentWithDriverData'][index]['driverData']['longitude'],
                                                  //
                                                  //       ),
                                                  //       ));
                                                  //     }, child: Text('Live'))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: SizedBox(
                                      height: 45,
                                      width: 100,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: scanColor),
                                          onPressed: () {
                                            print('for passing id:${respData[0]['studentWithDriverData'][index]['studentData']['id']}');
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditStudent(stdId: respData[0]['studentWithDriverData'][index]['studentData']['id'],),));
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
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 13),
                                    child: SizedBox(
                                      height: 45,
                                      width: 200,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: openScanner),
                                          onPressed: () {
                                            launch("tel://${respData[0]['studentWithDriverData'][index]['driverData']['phone_no'].toString()}");
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Call Driver',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                  }
                ),
              ),
              // Row(
              //   children: [
              //     CircleAvatar(radius: 25),
              //     SizedBox(width: 30,),
              //     SizedBox(
              //       height: 55,
              //       width: 230,
              //       child: ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //               backgroundColor: addNow),
              //           onPressed: () {
              //             Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudent(),));
              //           },
              //           child: Padding(
              //             padding: const EdgeInsets.all(8.0),
              //             child: Text(
              //               'Add New',
              //               style: TextStyle(
              //                   fontWeight: FontWeight.bold),
              //             ),
              //           )),
              //     ),
              //   ]
              // )

            ],
          ),
        ),
      )
    );
  }
}
