import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:untitled25/Appurl.dart';
import 'package:untitled25/Utils/utils.dart';

import 'Login and signup/profile.dart';
import 'constants.dart';

class NotificationPage extends StatefulWidget {

  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // List<String> messages = [];
  // List<Map<String, dynamic>> apiResponse = [];

  // var notificationData = [];




  bool isLoading = true;


  var notification;
  @override
  void initState() {
    super.initState();
    // fetchMessages();
    getmynotifications();
  }
  Future<void> getmynotifications() async {
    print('get notification called.....');
    try {
      String urls = AppUrl.notification;
      // API endpoint URL
      final url = Uri.parse(urls);

      // Request payload data
      final Map<String, dynamic> data = {
        "parent_id": Utils.userLoggedId,
      };

      // Convert data to JSON format
      final jsonData = jsonEncode(data);

      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set content type to JSON
          // Add any additional headers if needed
        },
        body: jsonData,
      );
      print('body is :${jsonEncode(data)}');
      print('status code is :${response.statusCode}');
      // Check the response status code
      if (response.statusCode == 200) {
        print('its successs....');
        setState(() {
          Utils.mynotifications.clear();
          Utils.mynotifications = jsonDecode(response.body);
        });
        print('0000000000');
        print(Utils.mynotifications);
        print(Utils.mynotifications['data'][0]);
        // Successful response
        print('Response data: ${response.body}');
      } else {
        print('i got a error...');
        // Handle error response
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error: $e');
    }
  }

  // Future<void> fetchMessages() async {
  //   final url = Uri.parse("http://52.66.145.37:3005/parent/get_notification");
  //   final data = {"notification_id": Utils.userLoggedId};
  //
  //   final response = await http.post(url, body: json.encode(data));
  //
  //   if (response.statusCode == 200) {
  //     apiResponse = List<Map<String, dynamic>>.from(json.decode(response.body)["data"]);
  //
  //     if (apiResponse.isNotEmpty) {
  //       final List<String> messagesList = apiResponse.map((item) => item["message"].toString()).toList();
  //
  //       setState(() {
  //         messages = messagesList;
  //       });
  //     }
  //   }
  // }



  // Future<void> markNotificationAsRead(int notificationId) async {
  //   final url = Uri.parse("http://52.66.145.37:3005/parent/notification");
  //   final data = {
  //     "notification_id": notificationId,
  //     "read": "true"
  //   };
  //
  //   print('sending body is:${jsonEncode(data)}');
  //
  //   final response = await http.post(
  //       url,
  //       body: jsonEncode(data));
  //
  //   if (response.statusCode == 200) {
  //     // Handle success, maybe update UI or show a success message
  //     print("Notification marked as read successfully");
  //   } else {
  //     // Handle error, show error message or retry logic
  //     print("Error marking notification as read. Status code: ${response.statusCode}");
  //   }
  // }
  // Future<void> changenotificationstatus(int noti_id) async{
  //
  //   final url = Uri.parse(AppUrl.readNotification);
  //
  //   final data = {
  //       "notification_id": noti_id,
  //       "read": "true"
  //     };
  //
  //   final response = await http.post(
  //             url,
  //             body: jsonEncode(data));
  // }


  Future<Map<String, dynamic>> changeNotificationStatus(int noti_id) async {
    print('Function called with noti_id: $noti_id');
    Map<String,dynamic> jsonData = {
      "notification_id":noti_id,
      "read":"true"
    };
    try {
      print('tryyyy');
      // Make the POST request
      final response = await http.post(
        Uri.parse(AppUrl.readNotification),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData),
      );
      print('check in body:${jsonEncode(jsonData)}');
      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        print('notifiiii');
        Fluttertoast.showToast(msg: 'Successfully readed notification');
        Navigator.pop(context);
        // Parse the response JSON
        Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody;
      } else {
        // Handle the error if the request was not successful
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to post data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      throw Exception('Failed to post data');
    }
  }

  ///delete notification
  Future<Map<String, dynamic>> deleteNoti(int noti_id) async {
    print('delete trip funciton called.....');
    print('noti id :${noti_id}');
    Map<String, dynamic> data = {"notification_id": noti_id};
    try {
      // Make the POST request
      final response = await http.delete(
        Uri.parse(AppUrl.deletenotification),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        print('weeeeee');
        Fluttertoast.showToast(msg: 'Notification Deleted !');
        // Parse the response JSON
        Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody;
      } else {
        // Handle the error if the request was not successful
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to post data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      throw Exception('Failed to post data');
    }
  }

  void _showAlertDialog(int notificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mark Notification as Read?"),
          content: Text("Do you want to mark this notification as read?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // await markNotificationAsRead(notification["id"] as int);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Mark as Read"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Notification'),
        backgroundColor: Colors.white,

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
              },
              child:CircleAvatar(
                backgroundImage: NetworkImage(Utils.photUrl == null ?
                'https://images.unsplash.com/photo-1480455624313-e'
                    '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                    'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D':Utils.photUrl.toString(),
                ),
              ),
            )
          )
        ],
        elevation: 0,
      ),
    body:
    SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // FutureBuilder(
          //   future: getmynotifications(),
          //   builder: (context,snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     } else if (snapshot.hasError) {
          //       return Center(
          //         child: Text("Error: ${snapshot.error}"),
          //       );
          //     } else {
          //       return ListView.builder(
          //           itemCount: mynotifications['data'].length,
          //           shrinkWrap: true,
          //           itemBuilder: (context, index) {
          //             return Card(
          //                 color: mynotifications['data'][index]['read'] == true
          //                     ? Colors.blue.shade50
          //                     : Colors.white,
          //                 child:
          //                 Dismissible(
          //                   key: Key(mynotifications['data'][index]['id']
          //                       .toString()),
          //                   // Provide a unique key for each item
          //                   onDismissed: (direction) {
          //                     // Remove the item from the data source (mynotifications)
          //                     setState(() {
          //                       mynotifications['data'].removeAt(index);
          //                     });
          //
          //                     // You can also perform additional actions here, such as making an API call to delete the item on the server
          //                     // For simplicity, I'll call a function that simulates the deletion
          //                     // deleteNotification(mynotifications['data'][index]['id']);
          //                     deleteNoti(mynotifications['data'][index]['id']);
          //                   },
          //                   background: Container(
          //                     color: Colors.red,
          //                     // Customize the background color for swipe
          //                     child: Icon(
          //                       Icons.delete,
          //                       color: Colors.white,
          //                     ),
          //                     alignment: Alignment.centerRight,
          //                     padding: EdgeInsets.only(right: 16.0),
          //                   ),
          //                   child: ListTile(
          //                       onTap: () {
          //                         print('Baaa');
          //                         // changeNotificationStatus(int.parse(mynotifications['data'][index]['id'].toString()));
          //                         showDialog(
          //                           context: context,
          //                           builder: (BuildContext context) {
          //                             return AlertDialog(
          //                               title: Text(
          //                                   "Mark Notification as Read?"),
          //                               content: Text(
          //                                   "Do you want to mark this notification as read?"),
          //                               actions: [
          //                                 TextButton(
          //                                   onPressed: () {
          //                                     Navigator.of(context).pop();
          //                                   },
          //                                   child: Text("Cancel"),
          //                                 ),
          //                                 TextButton(
          //                                   onPressed: () async {
          //                                     changeNotificationStatus(
          //                                         int.parse(
          //                                             mynotifications['data'][index]['id']
          //                                                 .toString()));
          //                                     Navigator.of(context)
          //                                         .pop(); // Close the dialog
          //                                   },
          //                                   child: Text("Mark as Read"),
          //                                 ),
          //                               ],
          //                             );
          //                           },
          //                         );
          //                       },
          //                       leading: Icon(Icons.notifications_active,
          //                           color: Colors.black),
          //                       title: Text(
          //                           '${mynotifications['data'][0]['message']}')),
          //                 ));
          //           }
          //       );
          //     }
          //   })
          Utils.mynotifications['data'] != null && Utils.mynotifications['data'].isNotEmpty?
          ListView.builder(
              itemCount: Utils.mynotifications['data'] != null ? Utils.mynotifications['data'].length : 0,
                shrinkWrap: true,
                itemBuilder: (context,index) {
                  return Card(
                      color: Utils.mynotifications['data'][index]['read'] == true
                      ? Colors.blue.shade50
                          : Colors.white,
                      child:
                      Dismissible(
                        key: UniqueKey(), // Use UniqueKey to ensure uniqueness
                        onDismissed: (direction) async {
                          try {
                            await deleteNoti(Utils.mynotifications['data'][index]['id']);
                            setState(() {
                              Utils.mynotifications['data'].removeAt(index);
                            });
                          } catch (e) {
                            print('Error deleting notification: $e');
                            // Handle error (show a snackbar, toast, etc.)
                          }
                        },
                        background: Container(
                          color: Colors.red,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16.0),
                        ),
                    child: ListTile(
                        onTap: () {
                          print('Baaa');
                          // changeNotificationStatus(int.parse(mynotifications['data'][index]['id'].toString()));
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    "Mark Notification as Read?"),
                                content: Text(
                                    "Do you want to mark this notification as read?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      changeNotificationStatus(
                                          int.parse(
                                              Utils.mynotifications['data'][index]['id']
                                                  .toString()));
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text("Mark as Read"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        leading: Icon(Icons.notifications_active,
                            color: Colors.black),
                        title:  Text('${Utils.mynotifications['data'][index]['message']}')),
                  ));
                }
            )
              : Center(
            child: Text('No Notification here'),
          ),
        ],
      ),
    ),
    //  body:isLoading == false? Center(child: CircularProgressIndicator(),) :
    //  ListView.builder(
    //   itemCount: mynotifications['data'].length,
    //   itemBuilder: (context, index) {
    //     // final reversedIndex = messages.length - 1 - index;
    //     // notification = apiResponse[reversedIndex];
    //     // final notificationId = notification["id"] as int;
    //
    //     return Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child:Card(
    //         // color: mynotifications[index]['read'] == true ? Colors.blue.shade50 : Colors.white,
    //         child: ListTile(
    //           onTap:(){
    //             // changenotificationstatus(int.parse(mynotifications[index]['id'].toString()));
    //             showDialog(
    //               context: context,
    //               builder: (BuildContext context) {
    //                 return AlertDialog(
    //                   title: Text("Mark Notification as Read?"),
    //                   content: Text("Do you want to mark this notification as read?"),
    //                   actions: [
    //                     TextButton(
    //                       onPressed: () {
    //                         Navigator.of(context).pop();
    //                       },
    //                       child: Text("Cancel"),
    //                     ),
    //                     TextButton(
    //                       onPressed: () async {
    //                         // await markNotificationAsRead(notification["id"] as int);
    //                         Navigator.of(context).pop(); // Close the dialog
    //                       },
    //                       child: Text("Mark as Read"),
    //                     ),
    //                   ],
    //                 );
    //               },
    //             );
    //           },
    //           // markNotificationAsRead();
    //
    //           leading: Icon(Icons.notifications_active, color: Colors.black),
    //           title: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               // Text("ID: ${notificationData[0][index]['id']}", style: TextStyle(color: Colors.black)),
    //               Text('${mynotifications[index]['message'] ?? ''}', style: TextStyle(color: Colors.black)),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // ),
    );
  }
}

