import 'dart:convert';

import 'package:flutter/material.dart';
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
  List<String> messages = [];
  List<Map<String, dynamic>> apiResponse = [];

  var notificationData = [];

  bool isLoading = true;


  var notification;
  @override
  void initState() {
    super.initState();
    // fetchMessages();
    getNotifications();
  }

  Future<void> getNotifications() async {
    print('get notification called.....');
    print(Utils.userLoggedId);
    isLoading = false;
    final url = Uri.parse(AppUrl.notification);
    final data = {
        "parent_id": Utils.userLoggedId
    };
    final response = await http.post(url,body: jsonEncode(data));
    print(jsonEncode(data));

    if(response.statusCode == 200){
      var responseData = jsonDecode(response.body);
      print('0000000000000');
      print(responseData);
      setState(() {
        isLoading = true;
        notificationData.clear();
        notificationData.add(responseData['data']);
        print('notificationdata is:${notificationData}');
      });
    }else{
      setState(() {
        isLoading = false;
        print('else is working...');
      });
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
  Future<void> changenotificationstatus(int noti_id) async{

    final url = Uri.parse('http://52.66.145.37:3005/parent/notification');

    final data = {
        "notification_id": noti_id,
        "read": "true"
      };

    final response = await http.post(
              url,
              body: jsonEncode(data));
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
        leading: Icon(Icons.menu, color: textColor1),
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
     body:isLoading == false? Center(child: CircularProgressIndicator(),) :ListView.builder(
      itemCount: notificationData[0].length,
      itemBuilder: (context, index) {
        // final reversedIndex = messages.length - 1 - index;
        // notification = apiResponse[reversedIndex];
        // final notificationId = notification["id"] as int;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child:Card(
            color: notificationData[0][index]['read'] == true ? Colors.blue.shade50 : Colors.white,
            child: ListTile(
              onTap:(){
                changenotificationstatus(int.parse(notificationData[0][index]['id'].toString()));
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Mark Notification as Read?"),
                      content: Text("Do you want to mark this notification as read?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
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
              },
              // markNotificationAsRead();

              leading: Icon(Icons.notifications_active, color: Colors.black),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("ID: ${notificationData[0][index]['id']}", style: TextStyle(color: Colors.black)),
                  Text('${notificationData[0][index]['message']}', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        );
      },
    ),
    );
  }
}

