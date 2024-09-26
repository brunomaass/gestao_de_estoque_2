import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductExitPageEdit extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductExitPageEdit({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProductExitPageState createState() => _ProductExitPageState();
}

class _ProductExitPageState extends State<ProductExitPageEdit> {
  DateTime? _selectedDate;
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedPeriod;

  final List<String> periods = ['Matutino', 'Vespertino']; // Opções de períodos
  Map<String, TextEditingController> dayControllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializando os controladores para cada dia da semana
    dayControllers = {
      'seg_mat': TextEditingController(),
      'seg_vesp': TextEditingController(),
      'ter_mat': TextEditingController(),
      'ter_vesp': TextEditingController(),
      'qua_mat': TextEditingController(),
      'qua_vesp': TextEditingController(),
      'qui_mat': TextEditingController(),
      'qui_vesp': TextEditingController(),
      'sex_mat': TextEditingController(),
      'sex_vesp': TextEditingController(),
    };
    _loadCurrentData();
  }

  // Carrega os dados atuais do produto
  Future<void> _loadCurrentData() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Items')
          .doc(widget.productId)
          .get();

      setState(() {
        // Atualiza os controladores com as quantidades atuais
        dayControllers.forEach((key, controller) {
          controller.text = (productSnapshot[key] ?? 0).toString();
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  // Método para salvar a saída
  void _saveExit() async {
    try {
      if (_selectedDate != null && _selectedPeriod != null) {
        int weekday = _selectedDate!.weekday;
        String fieldToUpdate = '';
        double? exitQuantity = double.tryParse(dayControllers[fieldToUpdate]?.text ?? '0');

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
          DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
              .collection('Items')
              .doc(widget.productId)
              .get();

          int currentStock = productSnapshot['quantidade'];
          int currentExit = productSnapshot[fieldToUpdate] ?? 0;

          // Verificar se a quantidade a ser salva é menor que a atual
          double? enteredQuantity = double.tryParse(dayControllers[fieldToUpdate]?.text ?? '0');
          
          if (enteredQuantity != null) {
            if (enteredQuantity > currentExit) {
              // Saída de produto
              if (enteredQuantity <= currentStock) {
                await FirebaseFirestore.instance.collection('Items').doc(widget.productId).update({
                  'quantidade': currentStock - (enteredQuantity - currentExit),
                  fieldToUpdate: enteredQuantity,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saída registrada com sucesso!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Quantidade de saída excede o estoque disponível!')),
                );
              }
            } else if (enteredQuantity < currentExit) {
              // Retorno ao estoque
              await FirebaseFirestore.instance.collection('Items').doc(widget.productId).update({
                'quantidade': currentStock + (currentExit - enteredQuantity),
                fieldToUpdate: enteredQuantity,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Quantidade retornada ao estoque com sucesso!')),
              );
            }
            // Limpar campos e atualizar a tela
            dayControllers[fieldToUpdate]?.clear();
            setState(() {
              _selectedDate = null;
              _selectedPeriod = null;
            });

            Navigator.pop(context); // Voltar à tela anterior
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, insira todos os campos corretamente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar saída: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Libera os controladores ao destruir o widget
    dayControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saída de Produto'),
      ),
      body: SingleChildScrollView( // Adiciona o Scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome do Produto: ${widget.productName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),

            // Campos para os dias da semana
            for (var entry in dayControllers.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: TextStyle(fontSize: 16)),
                  TextField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),

            SizedBox(height: 16),
            Row(
              children: [
                Text('Data de Saída:'),
                Spacer(),
                TextButton(
                  child: Text(_selectedDate == null
                      ? 'Selecione uma data'
                      : _selectedDate.toString().split(' ')[0]), // Formatação de data
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
