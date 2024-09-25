import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRegistrationPage extends StatefulWidget {
  @override
  _ProductRegistrationPageState createState() => _ProductRegistrationPageState();
}

class _ProductRegistrationPageState extends State<ProductRegistrationPage> {
  // Controladores de texto para os campos do formulário
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  // Função para cadastrar o produto no Firestore
  void _registerProduct() async {
    String name = _nameController.text;
    String unit = _unitController.text;
    int? quantity = int.tryParse(_quantityController.text);

    if (name.isNotEmpty && unit.isNotEmpty && quantity != null) {
      // Adiciona o produto ao Firebase Firestore
      await FirebaseFirestore.instance.collection('items').add({
        'nome': name,
        'unidade': unit,
        'quantidade': quantity,
        'seg_mat': 0,
        'seg_vesp': 0,
        'ter_mat': 0,
        'ter_vesp': 0,
        'qua_mat': 0,
        'qua_vesp': 0,
        'qui_mat': 0,
        'qui_vesp': 0,
        'sex_mat': 0,
        'sex_vesp': 0,
      });

      // Limpa os campos após o cadastro
      _nameController.clear();
      _unitController.clear();
      _quantityController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto cadastrado com sucesso!'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos corretamente.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Produto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Unidade de Medida (ex: kg, un)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade Inicial',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _registerProduct,
                child: Text('Cadastrar Produto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
