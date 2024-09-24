import 'package:flutter/material.dart';
import 'package:gestao_de_estoque_2/widgets/my_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  
@override
Widget build (BuildContext context) {

  return const Scaffold(
    appBar: MyAppBar(title: 'Reumo de Estoque', center: true,),
    
  );
}

}