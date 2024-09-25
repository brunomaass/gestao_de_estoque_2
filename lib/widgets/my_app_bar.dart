import 'package:flutter/material.dart';



class MyAppBar  extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? center;
  final dynamic backColor;
  const MyAppBar({super.key, required this.title,this.backColor,  this.center});


@override
Widget build(BuildContext context) {

  return AppBar(
    title: Text(title),
    centerTitle: center,
    backgroundColor: backColor,
  );
}

@override
Size get preferredSize =>  const Size.fromHeight(kToolbarHeight);
}

