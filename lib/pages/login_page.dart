import 'dart:convert';
import 'package:city/pages/api_config.dart';
import 'package:city/pages/dados_cadastrais.dart';
import 'package:city/pages/home_page.dart';
import 'package:city/shared/image/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  String errorMsg = '';

  String? validadeLogin(String? value) {
    if (emailController.text.isEmpty) {
      return 'entre com um valido';
    }
    if (senhaController.text.isEmpty) {
      return 'uma senha valida';
    }
    return null;
  }

  bool isObscureText = true;

  Future<void> login() async {
    const String url = '$API_BASE_URL/v1/users/login';

    if (emailController.text.isNotEmpty && senhaController.text.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': emailController.text,
            'password': senhaController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'] as String?;
          final userId = responseData['id'] as String?;
          final userEmail = responseData['email'] as String?;
          final userName = responseData['name'] as String?;

          if (token != null && userId != null && userEmail != null && userName != null) {
            // Save the token, userId, email, and name of the user
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            await prefs.setString('userId', userId);
            await prefs.setString('userEmail', userEmail);
            await prefs.setString('userName', userName);

            // Navigate to the HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            setState(() {
              errorMsg = 'Invalid login data. Please try again.';
            });
          }
        } else {
          setState(() {
            errorMsg = 'Login falhou. Por favor, verifique suas credenciais.';
          });
        }
      } catch (e) {
        setState(() {
          errorMsg = 'Ocorreu um erro ao tentar fazer login: $e';
        });
      }
    } else {
      setState(() {
        errorMsg = 'Por favor, preencha todos os campos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/PETSAVE.png',
                    width: 250,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Já tem uma conta?',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: darkGreyColor),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    print(value);
                  },
                  style: const TextStyle(color: darkGreyColor),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(
                          top: -5), 
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ligthCoral,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: ligthCoral,
                          )),
                      hintText: "Email",
                      hintStyle: TextStyle(color: darkGreyColor),
                      prefixIcon: Icon(
                        Icons.person,
                        color: ligthCoral,
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: senhaController,
                  obscureText: isObscureText,
                  onChanged: (value) {
                    print(senhaController);
                  },
                  style: const TextStyle(color: darkGreyColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: -5),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ligthCoral,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ligthCoral,
                        )),
                    hintText: "Senha",
                    hintStyle: const TextStyle(color: darkGreyColor),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: ligthCoral,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isObscureText = !isObscureText;
                        });
                      },
                      child: Icon(isObscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                if (errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      errorMsg,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(ligthCoral),
                    ),
                    onPressed: login,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(midleLightGreyColor),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DadosCadastrais(),
                        ),
                      );
                    },
                    child: const Text(
                      "Cadastre-se",
                      style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
