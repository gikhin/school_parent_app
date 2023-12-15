import 'package:flutter/material.dart';



class MyButtonWidget extends StatelessWidget {
  String buttonName;
  Color bgColor ;
  Function? onPressed;

  MyButtonWidget({required this.buttonName,required this.bgColor,required this.onPressed,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 296,
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: bgColor
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: bgColor),
        onPressed: onPressed as void Function()?,
        child: Text(buttonName,style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
