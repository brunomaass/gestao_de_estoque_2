import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_de_estoque_2/pagina/tela_de_edicao_produto.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String productName = '';
  double currentQuantity = 0;
  String unit = '';

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  // Método para carregar os dados do produto
  void _loadProductData() async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('Items').doc(widget.productId).get();

    setState(() {
      productName = productSnapshot['nome'];
      currentQuantity = productSnapshot['quantidade'];
      unit = productSnapshot['unidade'];
    });
  }

  // Método para navegar até a tela de edição
  void _navigateToEditProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(
          productId: widget.productId,
          productName: productName,
          currentQuantity: currentQuantity,
          unit: unit,
        ),
      ),
    );

    // Verifica se houve uma atualização
    if (result == true) {
      _loadProductData(); // Recarrega os dados do produto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Produto'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding:  EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nome: $productName', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Quantidade: $currentQuantity $unit', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _navigateToEditProduct,
                  child: Text('Editar Produto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
