import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../constants.dart';

class MyTextFieldWidget extends StatelessWidget{
  String labelName;
  TextEditingController controller;
  Function? validator;
  bool? enabled;
  MyTextFieldWidget({required this.labelName,required this.controller,required this.validator,this.enabled,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(labelName),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 323.0,
                height: 40.0,
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  validator:  (value) {

                  },

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  ),
                ),
              )

          ),
        ],
      ),
    );
  }
}
