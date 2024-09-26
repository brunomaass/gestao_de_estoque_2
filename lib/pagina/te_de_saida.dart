import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductExitPage extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductExitPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  
  // ignore: library_private_types_in_public_api
  _ProductExitPageState createState() => _ProductExitPageState();
}

class _ProductExitPageState extends State<ProductExitPage> {
  DateTime? _selectedDate;
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedPeriod; // Variável para armazenar o período selecionado

  final List<String> periods = ['Matutino', 'Vespertino']; // Opções de períodos

  // Método para salvar a saída
  void _saveExit() async {
    try {
      double? exitQuantity = double.tryParse(_quantityController.text);
      if (exitQuantity != null && _selectedDate != null && _selectedPeriod != null) {
        // Obter o dia da semana (1 = segunda-feira, 7 = domingo)
        int weekday = _selectedDate!.weekday;
        String fieldToUpdate = '';

        // Mapear o dia da semana para o campo correspondente no Firestore
        switch (weekday) {
          case 1:
            fieldToUpdate = _selectedPeriod == 'Matutino' ? 'seg_mat' : 'seg_vesp';
            break;
          case 2:
            fieldToUpdate = _selectedPeriod == 'Matutino' ? 'ter_mat' : 'ter_vesp';
            break;
          case 3:
            fieldToUpdate = _selectedPeriod == 'Matutino' ? 'qua_mat' : 'qua_vesp';
            break;
          case 4:
            fieldToUpdate = _selectedPeriod == 'Matutino' ? 'qui_mat' : 'qui_vesp';
            break;
          case 5:
            fieldToUpdate = _selectedPeriod == 'Matutino' ? 'sex_mat' : 'sex_vesp';
            break;
          default:
            fieldToUpdate = ''; // Não tratar sábado e domingo
        }

        if (fieldToUpdate.isNotEmpty) {
          // Obter o documento do produto
          DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
              .collection('Items')
              .doc(widget.productId)
              .get();

          // Verificar se o campo do período existe, se não, inicializar como 0
          int currentStock = productSnapshot['quantidade'];
          int currentExit = productSnapshot[fieldToUpdate] ?? 0;

          // Verificar se a quantidade de saída é válida (não excede o estoque)
          if (exitQuantity <= currentStock) {
            // Atualizar a quantidade no Firestore
            await FirebaseFirestore.instance.collection('Items').doc(widget.productId).update({
              'quantidade': currentStock - exitQuantity,
              fieldToUpdate: currentExit + exitQuantity,
            });

            // Limpar campos e exibir mensagem de sucesso
            _quantityController.clear();
            setState(() {
              _selectedDate = null;
              _selectedPeriod = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saída registrada com sucesso!')),
            );

            Navigator.pop(context); // Voltar à tela anterior
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quantidade de saída excede o estoque disponível!')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, insira todos os campos corretamente.')),
        );
      }
    } catch (e) {
      // Exibir mensagem de erro em caso de exceção
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar saída: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saída de Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome do Produto: ${widget.productName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade de Saída',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Data de Saída:'),
                Spacer(),
                TextButton(
                  child: Text(_selectedDate == null
                      ? 'Selecione uma data'
                      : _selectedDate.toString()),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              items: periods.map((String period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Selecione o Período',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveExit,
              child: Text('Salvar Saída'),
            ),
          ],
        ),
      ),
    );
  }
}
