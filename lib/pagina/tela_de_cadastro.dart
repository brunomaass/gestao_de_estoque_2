import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Importa o pacote de UUID

class ProductRegistrationPage extends StatefulWidget {
  const ProductRegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductRegistrationPageState createState() => _ProductRegistrationPageState();
}

class _ProductRegistrationPageState extends State<ProductRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Instância de UUID para gerar o código
  var uuid = Uuid();
  
   // função para formatar o nome do item
  String formatNomeItem(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return ' ';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(" ");
  }

  // função para exibir mensagem de sucesso
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

  // função exibire mensagem de erro
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

  // Função para cadastrar o produto no banco Firestore com código único gerado
  void _registerProduct() async {
    CollectionReference items = FirebaseFirestore.instance.collection('Items');
    String name = _nameController.text;
    String unit = _unitController.text;
    double? quantity = double.tryParse(_quantityController.text);

    if (name.isNotEmpty && unit.isNotEmpty && quantity != null) {
      try {

        final QuerySnapshot todosNomes = await items.get();

      List<String> nomesArmazenados =
          todosNomes.docs.map((doc) => doc['nome'].toString()).toList();

      if (nomesArmazenados.contains(formatNomeItem(name).trim())) {
        _showErrorDialog('Produto já cadastrado, use a tela de edição');
        return;
      }
        // Gerar um UUID aleatório
        String productCode = uuid.v4();

        // Adiciona o produto ao Firestore com o UUID gerado
        await FirebaseFirestore.instance.collection('Items').add({
          'codigo': productCode, // Código gerado para o produto
          'nome': formatNomeItem(name.trim()),
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
         const  SnackBar(content: Text('Produto cadastrado com sucesso!'))
        );
        _showSucessDialog("Produto cadastrado com sucesso!");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar o produto: $e'))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Preencha todos os campos corretamente.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Produto')),
      body: Padding(
        padding: EdgeInsets.all(16),
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
                labelText: 'Unidade de medida (ex: kg, un, pct)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number, // Teclado numérico
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
