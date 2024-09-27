// ignore_for_file: prefer_const_constructors



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_de_estoque_2/pagina/te_de_saida.dart';
import 'package:gestao_de_estoque_2/pagina/tela%20_resumo_semanal.dart';
import 'package:gestao_de_estoque_2/pagina/tela_de_cadastro.dart';
import 'package:gestao_de_estoque_2/pagina/tela_de_entrada.dart';
import 'package:gestao_de_estoque_2/pagina/tela_detalhes.dart';
import 'package:gestao_de_estoque_2/pagina/tela_edicao_resumo.dart';
import 'package:gestao_de_estoque_2/widgets/my_app_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoque'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => WeeklySummaryPage(), 
                  )
                );
            }, 
            icon: Icon(Icons.assessment)
            )
        ],
      ),
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
              stream: FirebaseFirestore.instance.collection('Items').snapshots(), 
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
                          return {'Detalhes', 'Entrada', 'Saída', 'Editar'}
                          .map((String choice) {
                            return PopupMenuItem(
                              value: choice,
                              child: Text(choice),
                              onTap: (){
                                if (choice == 'Detalhes') {
                                  Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id))
                                );
                                }
                                if (choice == 'Entrada') {
                                  Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => ProductEntryPage(
                                    productId: product.id, 
                                    productName: product['nome']
                                  )
                                ));
                                }
                                if (choice == 'Saída') {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => ProductExitPage(
                                        productId: product.id, 
                                        productName: product['nome'],
                                        )
                                    )
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
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ProductRegistrationPage(),
            )
            );
        },
        
        tooltip: 'Adicionar Produto',
        child:Icon(Icons.add),
        ),
    );
  } 
}