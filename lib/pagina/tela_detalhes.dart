// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_de_estoque_2/widgets/my_app_bar.dart';

class ProductDetails extends StatelessWidget {
  final String productId;

  ProductDetails({super.key, required this.productId});

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MyAppBar(
        title: 'Detalhes do Produto'
        ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('items').doc(productId).get(), 
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar detalhes')
          );

          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),
          );

          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Produto não encontrado'),
          );

          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData['nome'],
                ),
                SizedBox(height: 16,),
                Text('Código: ${productData['codigo']}'),
                SizedBox(height: 8,),
                Text('Unidade de Medida: ${productData['unidade']}'),
                SizedBox(height: 8,),
                Text('Quantidade em Estoque: ${productData['quantidade']}'),
                SizedBox(height: 16,),

                // botão de edição
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                   
                  }, 
                  child: Text('Editar Produto'),
                ),
              ],
            ),
          );
        }
      ),  
    );
  }
}