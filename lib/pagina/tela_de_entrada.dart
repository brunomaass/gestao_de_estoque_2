// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_de_estoque_2/widgets/my_app_bar.dart';
import 'package:intl/intl.dart';

class ProductEntryPage extends StatefulWidget {
  final String productId;
  final String productName;

  ProductEntryPage(
      {super.key, required this.productId, required this.productName});

  @override
  _ProductEntryPageState createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  // controladores para os campos
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // função para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  // função para mostrar mensagem de sucesso
  void _showSucessDialog(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        });
  }

  // função para mostrar mensagem de erro
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
  // função para salvar a entrada no Firebase
  void _saveEntry() async {
    String date = _dateController.text;
    int? quantity = int.tryParse(_quantityController.text);

    if (date.isNotEmpty && quantity != null) {
      // Atualiza a quantidade no Firestore
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(widget.productId)
          .update({
        'quantidade': FieldValue.increment(quantity), // incrementa a quantidade
      });

      // limpa os campos após salvar
      _dateController.clear();
      _quantityController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrada registrada com sucesso!")),
      );
      _showSucessDialog('Entrada registrada com sucesso');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      _showErrorDialog('Preencha todos os dados corretamente');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Registrar Entrada'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // campo de nome do produto (não editável)
            TextField(
              controller: TextEditingController(text: widget.productName),
              decoration: InputDecoration(labelText: 'Nome do Produto'),
              readOnly: true, // desabilida o preenchimento
            ),
            SizedBox(height: 10),

            // campo da data de entrada (com seletor de data)
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Data de Entrada',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    _selectDate(context);
                  }, 
                  icon: Icon(Icons.calendar_today)
                ),
              ),
              readOnly: true, // para não permitir a entrada manual
            ),
            SizedBox(height: 10),

            // campo para inserir a qunatidade de entrada
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantidade Entrada',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // apenas números
            ),
            SizedBox(height: 20),

            // botão para salvar a entrada
            Center(
              child: ElevatedButton(
                onPressed: _saveEntry, 
                child: Text('Salvar')
              ),
            )
          ],
        ),
      ),
    ); 
  }
}
