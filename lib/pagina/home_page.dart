// ignore_for_file: prefer_const_constructors



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_de_estoque_2/pagina/tela_detalhes.dart';
import 'package:gestao_de_estoque_2/widgets/my_app_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Estoque'),
      body: Column(
        children: [
          // barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome ou código',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search)
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('items').snapshots(), 
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar dados'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                    );
                }
              final products = snapshot.data!.docs;

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    child: ListTile(
                      title: Text(product['nome']),
                      subtitle: Text('Unidade: ${product['unidade']}, Estoque: ${product['quantidade']}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {

                        },
                        itemBuilder: (BuildContext context) {
                          return {'Detalhes', 'Entrada', 'Saída'}
                          .map((String choice) {
                            return PopupMenuItem(
                              value: choice,
                              child: Text(choice),
                              onTap: (){
                                if (choice == 'Detalhes') {
                                  Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => ProductDetails(productId: product.id))
                                );
                                }
                              
                              },
                            );
                          }).toList();
                        },
                      ),            
                    ),
                  );
                });
              }           
            )
          )
        ],
      ),
      //Botão para adicionar Produto
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        
        tooltip: 'Adicionar Produto',
        child:Icon(Icons.add),
        ),
    );
  } 
}