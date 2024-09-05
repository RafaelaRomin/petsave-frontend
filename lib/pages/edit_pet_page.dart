import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:city/pages/api_config.dart';
import '../shared/image/colors.dart';

class EditPetPage extends StatefulWidget {
  final Map<String, dynamic> pet;
  final String userId;
  final String userToken;

  const EditPetPage({
    Key? key,
    required this.pet,
    required this.userId,
    required this.userToken,
  }) : super(key: key);

  @override
  _EditPetPageState createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _raceController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _descriptionController;
  late TextEditingController _daysUnavailableController;
  bool isPetActive = true; // Novo: para controlar o estado do switch

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet['name'] ?? '');
    _raceController = TextEditingController(text: widget.pet['race'] ?? '');
    _weightController =
        TextEditingController(text: widget.pet['weight']?.toString() ?? '');
    _ageController =
        TextEditingController(text: widget.pet['age']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.pet['description'] ?? '');
    _daysUnavailableController = TextEditingController();
    isPetActive = widget.pet['donationStatus'] == 'Available';
    _updatePetStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _raceController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _daysUnavailableController.dispose();
    super.dispose();
  }

  Future<void> _updatePet() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse(
        '$API_BASE_URL/v1/pets/${widget.pet['id']}/tutor/${widget.userId}');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.userToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'race': _raceController.text,
        'weight': _weightController.text.isNotEmpty
            ? double.parse(_weightController.text)
            : null,
        'age': _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        'description': _descriptionController.text,
      }),
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet atualizado com sucesso')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao atualizar pet: ${response.statusCode}')),
      );
    }
  }

  Future<void> _setUnavailable() async {
    if (!isPetActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O pet já está inativo no momento.')),
      );
      return;
    }

    if (_daysUnavailableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira o número de dias')),
      );
      return;
    }

    // Mostrar diálogo de confirmação
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Inativação'),
          content: Text('Deseja realmente inativar o pet por ${_daysUnavailableController.text} dias?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm) return;

    final url = Uri.parse('$API_BASE_URL/v1/pets/${widget.pet['id']}?daysUnavailable=${_daysUnavailableController.text}');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.userToken}',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 204) {
      await _updatePetStatus();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pet Indisponível'),
            content: Text('O pet foi definido como indisponível com sucesso. '
                'Ele será reativado automaticamente após ${_daysUnavailableController.text} dia(s).'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao definir pet como indisponível: ${response.statusCode}')),
      );
    }
  }

  Future<void> _updatePetStatus() async {
    final url = Uri.parse('$API_BASE_URL/v1/pets/${widget.pet['id']}');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.userToken}',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final updatedPet = json.decode(response.body);
      setState(() {
        isPetActive = updatedPet['donationStatus'] == 'Available';
      });
    }
  }

  Future<void> _togglePetStatus() async {
    final newStatus = isPetActive ? 'Unable' : 'Available';
    final url = Uri.parse(
        '$API_BASE_URL/v1/pets/activate/${widget.pet['id']}?donationStatus=$newStatus');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.userToken}',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        isPetActive = !isPetActive;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isPetActive ? 'Pet Ativado' : 'Pet Desativado'),
            content: Text(isPetActive
                ? 'O pet foi reativado com sucesso. Ele está agora disponível para doação.'
                : 'O pet foi desativado com sucesso. Você pode reativá-lo a qualquer momento quando necessário.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erro ao alterar o status do pet: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligthCoral, // Usando a cor coral clara para o AppBar
        title: Text('Editar ${widget.pet['name']}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira um nome' : null,
              ),
              TextFormField(
                controller: _raceController,
                decoration: InputDecoration(labelText: 'Raça'),
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePet,
                child: Text(
                  'Atualizar Pet',
                  style:
                      TextStyle(fontSize: 15), // Ajuste o tamanho da fonte aqui
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ligthCoral, // Cor de fundo coral clara
                  foregroundColor: Colors.white, // Texto branco
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text('Definir como indisponível',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _daysUnavailableController,
                      decoration: InputDecoration(
                        labelText: 'Número de dias',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _setUnavailable,
                    child: Text('Definir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ligthCoral, // Cor laranja para destaque
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text('Status do Pet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isPetActive ? 'Ativo' : 'Inativo'),
                  Switch(
                    value: isPetActive,
                    onChanged: (bool value) {
                      _togglePetStatus();
                    },
                    activeColor: ligthCoral, // Cor coral clara quando ativo
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
