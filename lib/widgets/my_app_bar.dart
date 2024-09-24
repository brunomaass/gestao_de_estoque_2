import 'package:flutter/material.dart';



class MyAppBar  extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? center;
  const MyAppBar({super.key, required this.title,  this.center});


@override
Widget build(BuildContext context) {

  return AppBar(
    title: Text(title),
    centerTitle: center,
  );
}

@override
Size get preferredSize =>  const Size.fromHeight(kToolbarHeight);
}

