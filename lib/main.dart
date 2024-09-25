import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestao_de_estoque_2/firebase_options.dart';
import 'package:gestao_de_estoque_2/pagina/home_page.dart';
import 'package:gestao_de_estoque_2/pagina/tela%20_resumo_semanal.dart';
import 'package:gestao_de_estoque_2/pagina/tela_detalhes.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MaterialApp(
    home: ProductDetails(productId: productId)
  ));
}