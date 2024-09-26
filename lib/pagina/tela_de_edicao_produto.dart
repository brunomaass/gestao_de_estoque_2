import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final String productName;
  final int currentQuantity;
  final String unit;

  const EditProductPage({
    Key? key,
    required this.productId,
    required this.productName,
    required this.currentQuantity,
    required this.unit,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.productName;
    _quantityController.text = widget.currentQuantity.toString();
    _unitController.text = widget.unit;
  }

  // Método para atualizar os dados do item no Firestore
  void _updateProduct() async {
    try {
      String newName = _nameController.text;
      int? newQuantity = int.tryParse(_quantityController.text);
      String newUnit = _unitController.text;

      if (newName.isNotEmpty && newQuantity != null && newUnit.isNotEmpty) {
        // Atualiza os dados do produto no Firestore
        await FirebaseFirestore.instance.collection('Items').doc(widget.productId).update({
          'nome': newName,
          'quantidade': newQuantity,
          'unidade': newUnit,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto atualizado com sucesso!')),
        );

        // Retorna true ao voltar
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, preencha todos os campos corretamente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar o produto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Unidade de Medida',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
