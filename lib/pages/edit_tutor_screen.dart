import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:city/pages/api_config.dart';
import '../shared/image/colors.dart';

class EditTutorScreen extends StatefulWidget {
  final Map<String, dynamic> tutorData;
  final String userToken;
  final String userId;

  const EditTutorScreen({
    Key? key,
    required this.tutorData,
    required this.userToken,
    required this.userId
  }) : super(key: key);

  @override
  _EditTutorScreenState createState() => _EditTutorScreenState();
}

class _EditTutorScreenState extends State<EditTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.tutorData['fullName']);
    _cityController = TextEditingController(text: widget.tutorData['city']);
    _stateController = TextEditingController(text: widget.tutorData['state']);
    _emailController = TextEditingController(text: widget.tutorData['email']);
    _phoneNumberController = TextEditingController(text: widget.tutorData['phoneNumber']);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateTutorData() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('$API_BASE_URL/v1/users/${widget.userId}');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.userToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': _fullNameController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
        }),
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar dados. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligthCoral,
        title: Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _updateTutorData,
                  child: Text(
                    'Atualizar Perfil',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ligthCoral,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
