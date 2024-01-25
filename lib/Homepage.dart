import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'Widgets/gmap.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {



  GlobalKey _qrKey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/storage/emulated/0/Download/Qr_code';
  List<dynamic> tripDetails = [];
  List<Map<String, dynamic>> respData = [];
  Map<String, dynamic> tripDetailsmap = {};
  bool isLoading = true;

  String capitalize(String s) {
    if (s == null || s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  // Future<void> _captureAndSavePng() async {
  //   try {
  //     RenderRepaintBoundary boundary =
  //         _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //     var image = await boundary.toImage(pixelRatio: 3.0);
  //
  //     //Drawing White Background because Qr Code is Black
  //     final whitePaint = Paint()..color = Colors.white;
  //     final recorder = PictureRecorder();
  //     final canvas = Canvas(recorder,
  //         Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
  //     canvas.drawRect(
  //         Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
  //         whitePaint);
  //     canvas.drawImage(image, Offset.zero, Paint());
  //     final picture = recorder.endRecording();
  //     final img = await picture.toImage(image.width, image.height);
  //     ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();
  //
  //     //Check for duplicate file name to avoid Override
  //     String fileName = 'qr_code';
  //     int i = 1;
  //     while (await File('$externalDir/$fileName.png').exists()) {
  //       fileName = 'qr_code_$i';
  //       i++;
  //     }
  //
  //     // Check if Directory Path exists or not
  //     dirExists = await File(externalDir).exists();
  //     //if not then create the path
  //     if (!dirExists) {
  //       await Directory(externalDir).create(recursive: true);
  //       dirExists = true;
  //     }
  //
  //     final file = await File('$externalDir/$fileName.png').create();
  //     await file.writeAsBytes(pngBytes);
  //
  //     if (!mounted) return;
  //     const snackBar = SnackBar(content: Text('QR code saved to gallery'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   } catch (e) {
  //     if (!mounted) return;
  //     const snackBar = SnackBar(content: Text('Something went wrong!!!'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  Future<void> saveQrCodeToFile(String filePath, String studentId) async {
    print('savecodeto file worked...');
    try {
      print('try worked..');
      RenderRepaintBoundary boundary =
      _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      print('bound:$boundary');
      ui.Image image = await boundary.toImage();
      print('hello:$image');
      ByteData? byteData =
      await (image.toByteData(format: ui.ImageByteFormat.png));
      if(ByteData != null){
        final result = await ImageGallerySaver.saveImage(byteData!.buffer.asUint8List());
        print('psss:$result');
      }

      // if (image != null) {
      //   print("image not null");
      //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      //
      //   if (byteData != null && byteData.buffer.asUint8List() != null) {
      //     Uint8List uint8List = byteData.buffer.asUint8List();
      //     await File(filePath).writeAsBytes(uint8List);
      //   } else {
      //     print('Error: ByteData or its buffer is null');
      //   }
      // } else {
      //   print('Error: Image is null');
      // }
    } catch (e) {
      print('catch worked...');
      print('Error saving QR code: $e');
    }
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

      print("Assss${respData}");
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

  ///delete student
  Future<Map<String, dynamic>> deleteStd(int stdid) async {
    print('delete trip funciton called.....');

    Map<String, dynamic> data = {"student_id": stdid};
    try {
      // Make the POST request
      final response = await http.delete(
        Uri.parse(AppUrl.deleteSTd),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Student Successfully Deleted !');

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

  //save
  _saveLocalImage() async {
    try {
      print('Attempting to save image...');

      // Check if _qrKey is not null and has a valid context
      if (_qrKey.currentContext != null) {
        print('Context is valid');

        // Find the RenderRepaintBoundary associated with _qrKey
        RenderRepaintBoundary boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

        // Convert the render boundary to an ui.Image
        ui.Image image = await boundary.toImage();

        // Convert the ui.Image to ByteData in PNG format
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        // Check if ByteData is not null
        if (byteData != null) {
          // Save the image to the device's image gallery
          final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());

          // Check the result of the save operation
          if (result != null && result.isNotEmpty) {
            print('Image saved successfully: $result');
          } else {
            print('Error saving image. Result is null or empty.');
          }
        } else {
          print('Error: ByteData is null');
        }
      } else {
        print('Error: _qrKey.currentContext is null');
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }



  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      print('Eeeeee');
      // Permission already granted
      return true;
    } else if (status.isDenied) {
      // Request location permission
      var result = await Permission.location.request();

      if (result.isGranted) {
        // Permission granted
        return true;
      } else {
        // Permission denied
        return false;
      }
    } else {
      // Permission already denied previously, user needs to enable manually
      return false;
    }
  }
  // void getNotificationsCount() async {
  //   // Assuming you have a function to fetch the count
  //   // You can replace this with your actual logic to get the count
  //   int count = await fetchNotificationsCount();
  //
  //   setState(() {
  //     totalNotifications = count;
  //   });
  // }
  Future<void> getNotificationsCount() async {
    print('get notification called.....');
    try {
      String urls = AppUrl.notification;
      final url = Uri.parse(urls);
      final Map<String, dynamic> data = {
        "parent_id": Utils.userLoggedId,
      };

      final jsonData = jsonEncode(data);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      print('body is :${jsonEncode(data)}');
      print('status code is :${response.statusCode}');

      if (response.statusCode == 200){
        print('its successs....');
          Utils.mynotifications.clear();
          Utils.mynotifications = jsonDecode(response.body);
           Utils.notificationCount = Utils.mynotifications['data'].length;
        print('0000000000');
        print(Utils.mynotifications);
        print(Utils.mynotifications['data'][0]);
      } else {
        print('i got an error...');
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  // Function to simulate fetching the notification count (replace with your actual logic)
  Future<int> fetchNotificationsCount() async {
    // Simulate fetching count from an API or database
    // You should replace this with your actual logic
    await Future.delayed(Duration(seconds: 2));
    return 5;  // Replace with the actual count
  }

  late Timer timer;
  @override
  void initState() {
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
    //   });
    // });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _saveLocalImage();
    });
    // TODO: implement initState
    // tripHistoryFunction();
    requestLocationPermission();
    loadData();
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _saveLocalImage();
      getNotificationsCount();
    });
  }

  Future<void> loadData() async {
    await tripHistoryFunction();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Aaaa");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddStudent()),
            );
          },
          tooltip: 'Add',
          child: Icon(Icons.add),
          backgroundColor: openScanner,
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {

                },
                child: Row(
                  children: [

                    SizedBox(
                      child: FutureBuilder(
                        future:getNotificationsCount(),
                        builder: (context,snapshot) {
                          return Stack(
                            children: [
                              InkWell(
                                onTap:(){
                                  Navigator.push(context, MaterialPageRoute(builder:(context) => NotificationPage(),));
                                },
                                  child: Icon(Icons.notifications,size: 30.0,color: Colors.black,)),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 10,
                                    minHeight: 5,
                                  ),
                                  child: Text(
                                    '${Utils.notificationCount}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                    SizedBox(width: 20,),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Stack(
                    //     alignment: Alignment.center,
                    //     children: [
                    //       IconButton(
                    //         icon: Icon(Icons.notifications,color: Colors.black,),
                    //         onPressed: () {
                    //           Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage(),));
                    //         },
                    //       ),
                    //       Positioned(
                    //         top: 8.0,
                    //         right: 8.0,
                    //         child: Container(
                    //           padding: EdgeInsets.all(4.0),
                    //           decoration: BoxDecoration(
                    //             color: Colors.red,
                    //             borderRadius: BorderRadius.circular(10.0),
                    //           ),
                    //           child: Text(
                    //             '${Utils.notificationCount}',
                    //             style: TextStyle(
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(),
                            ));
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          Utils.photUrl == null
                              ? 'https://images.unsplash.com/photo-1480455624313-e'
                                  '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                                  'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D'
                              : Utils.photUrl.toString(),
                        ),
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
                  child: isLoading == false
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : FutureBuilder(
                          future: loadData(),
                          builder: (context, index) {
                            return respData[0]['studentWithDriverData'].isEmpty
                                ? Center(
                                    child: Column(
                                      children: [
                                        Lottie.asset('assets/lottie/kids.json'),
                                        Text(
                                          'Add A Student',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: respData[0]
                                            ['studentWithDriverData']
                                        .length,
                                    itemBuilder: (context, index) {
                                      // print(tripDetails);
                                      // final tripDetail = respData[index]['studentWithDriverData'];
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 8.0,
                                                bottom: 4),
                                            child: Container(
                                              decoration:
                                                  BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black,
                                                  blurRadius: 10.0,
                                                  spreadRadius: -15,
                                                  offset: Offset(
                                                    -2,
                                                    -2,
                                                  ),
                                                )
                                              ]),
                                              child: Card(
                                                child: SizedBox(
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          ListTile(
                                                            title: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: CircleAvatar(
                                                                    radius: 32.0,
                                                                    child: Text(
                                                                      '${respData[0]['studentWithDriverData'][index]['studentData']['name'].toString().toUpperCase().trim().substring(0, 1)}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text('${respData[0]['studentWithDriverData'][index]['studentData']['name'].toString().toUpperCase()}', style:
                                                                                  TextStyle(fontWeight: FontWeight.bold),
                                                                                                                                                        ),
                                                                                IconButton(
                                                                                  onPressed:
                                                                                      () async {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: ((context) {
                                                                                          return Center(
                                                                                            child: RepaintBoundary(
                                                                                              key: _qrKey,
                                                                                              child: QrImageView(
                                                                                                version: QrVersions.auto,
                                                                                                data: "${respData[0]['studentWithDriverData'][index]['studentData']['id']}",
                                                                                                backgroundColor: Colors.white,
                                                                                                gapless: true,
                                                                                                errorStateBuilder: (ctx, err) {
                                                                                                  return const Center(
                                                                                                    child: Text(
                                                                                                      'Something went wrong!!!',
                                                                                                      textAlign: TextAlign.center,
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        }),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  icon:
                                                                                  Icon(Icons.qr_code_2, color: Colors.black),
                                                                                ),
                                                                                // IconButton(
                                                                                //   onPressed:
                                                                                //       _captureAndSavePng,
                                                                                //   icon:
                                                                                //       Icon(Icons.download),
                                                                                // ),
                                                                                // IconButton(
                                                                                //   onPressed: () async {
                                                                                //     print('Fff');
                                                                                //     _saveLocalImage();
                                                                                //     // // Get the path to the app's document directory
                                                                                //     // String directory = (await getApplicationDocumentsDirectory()).path;
                                                                                //     // print('sss:$directory');
                                                                                //     //
                                                                                //     // // Combine the directory path with a unique filename
                                                                                //     // String filePath = '/storage/emulated/0/Download/qr_code.png';
                                                                                //     //
                                                                                //     // String studentId = respData[0]['studentWithDriverData'][index]['studentData']['id'].toString();
                                                                                //     //
                                                                                //     // try {
                                                                                //     //   int parsedStudentId = int.parse(studentId);
                                                                                //     //   print('st id is:$studentId');
                                                                                //     //   Future.delayed(Duration(milliseconds: 100),(){
                                                                                //     //     saveQrCodeToFile(filePath, studentId);
                                                                                //     //   });
                                                                                //     //   // await saveQrCodeToFile(filePath, parsedStudentId.toString());
                                                                                //     // } catch (e) {
                                                                                //     //   print('Error parsing student ID: $e');
                                                                                //     // }
                                                                                //     //
                                                                                //     // // Save the image to the gallery
                                                                                //     // await ImageGallerySaver.saveFile(filePath);
                                                                                //
                                                                                //     // Optionally, you can display a message or perform any additional actions
                                                                                //     // after the QR code is successfully saved.
                                                                                //     print('QR code saved successfully!');
                                                                                //   },
                                                                                //   icon: Icon(Icons.download),
                                                                                // ),
                                                                              ],
                                                                            ),
                                                                      ),
                                                                      // Text(
                                                                      //   '${respData[0]['studentWithDriverData'][index]['studentData']['id'].toString().toUpperCase()}',
                                                                      //   style: TextStyle(fontWeight: FontWeight.bold),
                                                                      // ),
                                                                      Text('${respData[0]['studentWithDriverData'][index]['studentData']['class_category'].toString().toUpperCase()}',
                                                                        style: TextStyle(color: Colors.black),
                                                                      ),
                                                                      Text('${respData[0]['studentWithDriverData'][index]['studentData']['vehicle']}'),


                                                                      // Row(
                                                                      //   children: [
                                                                      //     IconButton(
                                                                      //       onPressed:
                                                                      //           () async {
                                                                      //         Navigator.push(
                                                                      //           context,
                                                                      //           MaterialPageRoute(
                                                                      //             builder: ((context) {
                                                                      //               return Center(
                                                                      //                 child: RepaintBoundary(
                                                                      //                   key: _qrKey,
                                                                      //                   child: QrImageView(
                                                                      //                     version: QrVersions.auto,
                                                                      //                     data: "${respData[0]['studentWithDriverData'][index]['studentData']['id']}",
                                                                      //                     backgroundColor: Colors.white,
                                                                      //                     gapless: true,
                                                                      //                     errorStateBuilder: (ctx, err) {
                                                                      //                       return const Center(
                                                                      //                         child: Text(
                                                                      //                           'Something went wrong!!!',
                                                                      //                           textAlign: TextAlign.center,
                                                                      //                         ),
                                                                      //                       );
                                                                      //                     },
                                                                      //                   ),
                                                                      //                 ),
                                                                      //               );
                                                                      //             }),
                                                                      //           ),
                                                                      //         );
                                                                      //       },
                                                                      //       icon:
                                                                      //           Icon(Icons.qr_code_2, color: Colors.black),
                                                                      //     ),
                                                                      //     // IconButton(
                                                                      //     //   onPressed:
                                                                      //     //       _captureAndSavePng,
                                                                      //     //   icon:
                                                                      //     //       Icon(Icons.download),
                                                                      //     // ),
                                                                      //     IconButton(
                                                                      //       onPressed: () async {
                                                                      //         print('Fff');
                                                                      //         _saveLocalImage();
                                                                      //         // // Get the path to the app's document directory
                                                                      //         // String directory = (await getApplicationDocumentsDirectory()).path;
                                                                      //         // print('sss:$directory');
                                                                      //         //
                                                                      //         // // Combine the directory path with a unique filename
                                                                      //         // String filePath = '/storage/emulated/0/Download/qr_code.png';
                                                                      //         //
                                                                      //         // String studentId = respData[0]['studentWithDriverData'][index]['studentData']['id'].toString();
                                                                      //         //
                                                                      //         // try {
                                                                      //         //   int parsedStudentId = int.parse(studentId);
                                                                      //         //   print('st id is:$studentId');
                                                                      //         //   Future.delayed(Duration(milliseconds: 100),(){
                                                                      //         //     saveQrCodeToFile(filePath, studentId);
                                                                      //         //   });
                                                                      //         //   // await saveQrCodeToFile(filePath, parsedStudentId.toString());
                                                                      //         // } catch (e) {
                                                                      //         //   print('Error parsing student ID: $e');
                                                                      //         // }
                                                                      //         //
                                                                      //         // // Save the image to the gallery
                                                                      //         // await ImageGallerySaver.saveFile(filePath);
                                                                      //
                                                                      //         // Optionally, you can display a message or perform any additional actions
                                                                      //         // after the QR code is successfully saved.
                                                                      //         print('QR code saved successfully!');
                                                                      //       },
                                                                      //       icon: Icon(Icons.download),
                                                                      //     ),
                                                                      //
                                                                      //   ],
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            subtitle: Column(
                                                              children: [
                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                  children: [
                                                                    Flexible(
                                                                      child: Column(
                                                                        children: [
                                                                          Icon(Icons.home,color: homeicon,),
                                                                          Text('${respData[0]['studentWithDriverData'][index]['studentData']['address']['place'].split(',')[0]}'
                                                                            ,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,),maxLines: 1),
                                                                      
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text('- - - - - - - - - -',style: TextStyle(color: homeicon),),



                                                                    Flexible(
                                                                      child: Column(
                                                                        children: [
                                                                          Icon(Icons.home_filled,color: homeicon,),
                                                                          Text('${respData[0]['studentWithDriverData'][index]['studentData']['school']['school_name'].split(',')[0]}'
                                                                          ,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                                                                        ],
                                                                      ),
                                                                    )

                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.end,
                                                                  children: [
                                                                    // if (respData[0]['studentWithDriverData'][index]['driverData'] != null)
                                                                    Visibility(
                                                                      visible: !(respData[0]['studentWithDriverData'][index]['studentData']['status'] == null ||
                                                                          respData[0]['studentWithDriverData'][index]['studentData']['status'] == 'reached'),
                                                                      child: TextButton(
                                                                        onPressed: () {
                                                                          print("liiiii");
                                                                          print('d id :${respData[0]['studentWithDriverData'][index]['driverData']['id']}');
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => polylineNew(
                                                                                driver_id: respData[0]['studentWithDriverData'][index]['driverData']['id'],
                                                                                lat: double.parse(respData[0]['studentWithDriverData'][index]['driverData']['latitude'].toString()),
                                                                                long: double.parse(respData[0]['studentWithDriverData'][index]['driverData']['longitude'].toString()),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          primary: Colors.black, // This sets the text color to black
                                                                        ),
                                                                        child: Row(
                                                                          children: [
                                                                            Text(
                                                                              'Track Your Vehicle',
                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                            Icon(
                                                                              Icons.arrow_forward_sharp,
                                                                              color: Colors.black, // This sets the icon color to black
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )

                                                                    ),

                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            // trailing: IconButton(
                                                            //   onPressed: () {
                                                            //     print('laaaaa:${respData[0]['studentWithDriverData'][index]['studentData']['id'] ?? ''}');
                                                            //     print('delete btn clicked');
                                                            //     deleteStd(respData[0]['studentWithDriverData'][index]['studentData']['id']);
                                                            //   },
                                                            //   icon: Icon(Icons.delete),
                                                            //   color: Colors.red,
                                                            // ),
                                                          ),
                                                          Positioned(
                                                              right: 0,
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color:
                                                                          scanColor,
                                                                      borderRadius:
                                                                          BorderRadius.only(
                                                                              bottomLeft: Radius.circular(15))),
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.all(1.0),
                                                                      child: IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          print(
                                                                              'laaaaa:${respData[0]['studentWithDriverData'][index]['studentData']['id'] ?? ''}');
                                                                          print(
                                                                              'delete btn clicked');
                                                                          deleteStd(respData[0]['studentWithDriverData'][index]['studentData']
                                                                              [
                                                                              'id']);
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .delete_rounded,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      )))),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: SizedBox(
                                                  height: 45,
                                                  width: 100,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  scanColor),
                                                      onPressed: () {
                                                        print(
                                                            'for passing id:${respData[0]['studentWithDriverData'][index]['studentData']['id']}');
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditStudent(stdId: respData[0]['studentWithDriverData'][index]['studentData']['id'],),));
                                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => EditStudent(stdId:tripDetail[0]['id'] ),));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text('Edit',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                              respData[0]['studentWithDriverData']
                                                              [index]
                                                          ['driverData'] ==
                                                      null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 13),
                                                      child: SizedBox(
                                                        height: 45,
                                                        width: 200,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        openScannerlight),
                                                            onPressed: () {
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          'Not in trip!');
                                                              // launch("tel://${respData[0]['studentWithDriverData'][index]['driverData']['phone_no'].toString()}");
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'Call Driver',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            )),
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 13),
                                                      child: SizedBox(
                                                        height: 45,
                                                        width: 200,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        openScanner),
                                                            onPressed: () {
                                                              launch(
                                                                  "tel://${respData[0]['studentWithDriverData'][index]['driverData']['phone_no'].toString()}");
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'Call Vehicle',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight.bold),
                                                              ),
                                                            )),
                                                      ))
                                            ],
                                          ),
                                        ],
                                      );
                                    });
                          }),
                ),
              ],
            ),
          ),
        ));
  }
}
