import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final String productName;
  final double currentQuantity;
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

  // formatar o nome
  String formatNomeItem(String input) {
    return input.trim().split(' ').map((word) {
      if (word.isEmpty) return ' ';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // mostra mensagem de sucesso
  void _showSucessDialog(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // fecha a tela após sucesso
                },
                child: const Text('OK'),
              )
            ],
          );
        });
  }

  // mostra mensagem de erro
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        });
  }


  // Método para atualizar os dados do item no Firestore
  void _updateProduct() async {
    try {
      CollectionReference items = FirebaseFirestore.instance.collection('Items');
      String newName = _nameController.text;
      int? newQuantity = int.tryParse(_quantityController.text);
      String newUnit = _unitController.text;

        // Verifique se já existe um item com o mesmo nome no banco de dados
        final QuerySnapshot querySnapshot = await items
            .where('nome', isEqualTo: formatNomeItem(newName.trim()))
            .get();

        // Se o nome do item já existir em outro documento, e o ID for diferente, impedir a edição
        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          if (doc.id != widget.productId) {
            _showErrorDialog('Já existe um item com este nome.');
            return;
          }
        }  

      if (newName.isNotEmpty && newQuantity != null && newUnit.isNotEmpty) {
        // Atualiza os dados do produto no Firestore
        await FirebaseFirestore.instance.collection('Items').doc(widget.productId).update({
          'nome': formatNomeItem(newName.trim()),
          'quantidade': newQuantity,
          'unidade': newUnit,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto atualizado com sucesso!')),
        );
        _showSucessDialog('Item atualizado com sucesso!');

        // Retorna true ao voltar
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, preencha todos os campos corretamente.')),
        );
        _showErrorDialog('Por favor preencha todos os campos.');
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
