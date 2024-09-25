// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_de_estoque_2/widgets/my_app_bar.dart';

class WeeklySumaryPage extends StatelessWidget {
  const WeeklySumaryPage({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MyAppBar(title: 'Resumo Semanal'),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(), 
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao Carregar'),);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }

          final products = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Produto')),
                DataColumn(label: Text('Seg Mat')),
                DataColumn(label: Text('Seg Vesp')),
                DataColumn(label: Text('Ter Mat')),
                DataColumn(label: Text('Ter Vesp')),
                DataColumn(label: Text('Qua Mat')),
                DataColumn(label: Text('Qua Vesp')),
                DataColumn(label: Text('Qui Mat')),
                DataColumn(label: Text('Qui Vesp')),
                DataColumn(label: Text('Sex Mat')),
                DataColumn(label: Text('Sex Vesp')),
                DataColumn(label: Text('Consumo Total')),
              ], 
              rows: products.map((product) {
                return DataRow(
                  cells:[
                    DataCell(Text(product['nome'] ?? '')),
                    DataCell(Text(product['seg_mat'].toString() ?? '0')),
                    DataCell(Text(product['seg_vesp'].toString() ?? '0')),
                    DataCell(Text(product['ter_mat'].toString() ?? '0')),
                    DataCell(Text(product['ter_vesp'].toString() ?? '0')),
                    DataCell(Text(product['qua_mat'].toString() ?? '0')),
                    DataCell(Text(product['qua_vesp'].toString() ?? '0')),
                    DataCell(Text(product['qui_mat'].toString() ?? '0')),
                    DataCell(Text(product['qui_vesp'].toString() ?? '0')),
                    DataCell(Text(product['sex_mat'].toString() ?? '0')),
                    DataCell(Text(product['sex_vesp'].toString() ?? '0')),
                    DataCell(Text(_calculateTotal(product))),
                  ]
                );
              }).toList(),
            ),
          );
        }
      ),
    );
  }

 
  // Função para calcular o consumo total de um produto durante a semana
  String _calculateTotal(QueryDocumentSnapshot product) {
    num total = 0;
    total += product['seg_mat'] ?? 0;
    total += product['seg_vesp'] ?? 0;
    total += product['ter_mat'] ?? 0;
    total += product['ter_vesp'] ?? 0;
    total += product['qua_mat'] ?? 0;
    total += product['qua_vesp'] ?? 0;
    total += product['qui_mat'] ?? 0;
    total += product['qui_vesp'] ?? 0;
    total += product['sex_mat'] ?? 0;
    total += product['sex_vesp'] ?? 0;

    return total.toString();
  }
}


