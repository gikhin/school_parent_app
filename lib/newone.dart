import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Login and signup/profile.dart';
import 'Notification.dart';
import 'Utils/utils.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(),
                    ));
              },
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(),
                            ));
                      },
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.black,
                      )),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      Utils.photUrl == null
                          ? 'https://images.unsplash.com/photo-1480455624313-e'
                          '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                          'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D'
                          : Utils.photUrl.toString(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
        elevation: 0,
      ),
    );
  }
}
