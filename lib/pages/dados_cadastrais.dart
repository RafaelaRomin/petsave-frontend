import 'dart:convert';
import 'package:city/pages/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'login_page.dart';
import 'package:flutter/services.dart';

import '../shared/image/colors.dart';
import '../shared/image/text_label.dart';
import 'apresentacao.dart';

class DadosCadastrais extends StatefulWidget {
  const DadosCadastrais({Key? key}) : super(key: key);

  @override
  State<DadosCadastrais> createState() => _DadosCadastraisState();
}

class _DadosCadastraisState extends State<DadosCadastrais> {
  final _formKey = GlobalKey<FormState>();
  var nomeController = TextEditingController(text: "");
  var cidadeController = TextEditingController(text: "");
  var estadoController = TextEditingController(text: "");
  var phoneController = TextEditingController(text: "");
  var emailController = TextEditingController(text: "");
  var senhaController = TextEditingController(text: "");
  var repitaSenhaController = TextEditingController(text: "");

  bool loading = false;
  bool isObscureText = true;
  String _senha = '';

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', 
    filter: { "#": RegExp(r'[0-9]') }
  );

  final List<String> estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
    'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  final List<String> cidadesParana = [
    'Curitiba', 'Londrina', 'Maringá', 'Ponta Grossa', 'Cascavel', 'São José dos Pinhais',
    'Foz do Iguaçu', 'Colombo', 'Guarapuava', 'Paranaguá'
  ];

  Future<void> cadastrarUsuario() async {
    final url = Uri.parse('$API_BASE_URL/v1/users');

    final body = jsonEncode({
      'fullName': nomeController.text,
      'city': cidadeController.text,
      'state': estadoController.text,
      'email': emailController.text,
      'password': senhaController.text,
      'phoneNumber': phoneController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário cadastrado com sucesso'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar usuário: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar na API: $e'),
        ),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    List<String>? suggestions,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        if (suggestions != null && suggestions.isNotEmpty)
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return suggestions.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              controller.text = selection;
              if (onChanged != null) onChanged(selection);
            },
            fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
              return _buildTextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                isPassword: isPassword,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                validator: validator,
                onChanged: onChanged,
              );
            },
          )
        else
          _buildTextFormField(
            controller: controller,
            isPassword: isPassword,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: onChanged,
          ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    FocusNode? focusNode,
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword ? isObscureText : false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ligthCoral),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isObscureText = !isObscureText;
                  });
                },
                child: Icon(isObscureText ? Icons.visibility_off : Icons.visibility),
              )
            : null,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligthCoral,
        title: const Text("Cadastro do tutor"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Nome Completo',
                controller: nomeController,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              _buildTextField(
                label: 'Estado',
                controller: estadoController,
                suggestions: estados,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              _buildTextField(
                label: 'Cidade',
                controller: cidadeController,
                suggestions: cidadesParana,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              _buildTextField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  // Adicione uma validação de formato de email se necessário
                  return null;
                },
              ),
              _buildTextField(
                label: 'Telefone',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMask],
              ),
              _buildTextField(
                label: 'Senha',
                controller: senhaController,
                isPassword: true,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onChanged: (value) {
                  setState(() {
                    _senha = value;
                  });
                },
              ),
              _buildTextField(
                label: 'Repita a Senha',
                controller: repitaSenhaController,
                isPassword: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Campo obrigatório';
                  if (value != _senha) return 'As senhas não coincidem';
                  return null;
                },
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print('Email: ${emailController.text}'); // Adicione este print para debug
                      setState(() {
                        loading = true;
                      });
                      cadastrarUsuario();
                    }
                  },
                  child: Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
