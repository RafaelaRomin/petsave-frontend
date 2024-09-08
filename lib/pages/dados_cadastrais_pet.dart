import 'dart:convert';
import 'package:PetSave/pages/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../repository/donor_repository.dart';
import '../repository/tipo_repository.dart';
import '../shared/image/colors.dart';
import '../shared/image/text_label.dart';

class DadosCadastraisPet extends StatefulWidget {
  const DadosCadastraisPet({
    Key? key,
  }) : super(key: key);

  @override
  State<DadosCadastraisPet> createState() => _DadosCadastraisPetState();
}

class _DadosCadastraisPetState  extends State<DadosCadastraisPet> {
  var nomeController = TextEditingController(text: "");
  var idadePetController = TextEditingController(text: "");
  var pesoPetController = TextEditingController(text: "");
  var racaController = TextEditingController(text: "");
  var descricaoController = TextEditingController(text: "");

//  DateTime? dataNascimento;
  var tipoRepository = TipoRepository();
  var donorRepository = DonorRepository();
  var tipo = [];
  var tipoSelecionado; // Inicializado com 0
  var opcaoSelecionada = "";
  String? userToken;
  String? userId;
  bool loading = false;

  @override
  void initState() {
    tipo = tipoRepository.retornaTipo;
    _loadUserData();
    super.initState();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
      userId = prefs.getString('userId');
    });
  }

  Future<void> cadastrarPet() async {
    if (userToken == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para cadastrar um pet.')),
      );
      return;
    }

    final url = Uri.parse('$API_BASE_URL/v1/pets');

    final body = jsonEncode({
      'name': nomeController.text,
      'race': racaController.text,
      'species': tipoSelecionado == 0 ? 'Canine' : 'Feline',
      'weight': double.parse(pesoPetController.text),
      'age': int.parse(idadePetController.text),
      'description': descricaoController.text,
      'idTutor': userId
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sucesso'),
              content: const Text('Pet cadastrado com sucesso'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o AlertDialog
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar pet: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar na API: $e')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  List<DropdownMenuItem<int>> returnItens(int quantidademaxima) {
    var itens = <DropdownMenuItem<int>>[];
    for (var i = 0; i <= quantidademaxima; i++) {
      itens.add(DropdownMenuItem(
        value: i, //recebe o valor em cada loop
        child: Text(
            i.toString()), //retorna esse valor como texto dentro do dropdown
      ));
    }
    return itens;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligthCoral,
        title: const Text(
          "Dados do Pet",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            const TextLabel(texto: "Nome do Pet"),
            TextField(
              controller: nomeController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: darkGreyColor),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: darkGreyColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ligthCoral,
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const TextLabel(texto: "Idade do Pet"),
            TextField(
              controller: idadePetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: darkGreyColor),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: darkGreyColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ligthCoral,
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const TextLabel(texto: "Peso"),
            TextField(
              controller: pesoPetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: darkGreyColor),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: darkGreyColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ligthCoral,
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const TextLabel(texto: "Raça"),
            TextField(
              controller: racaController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: darkGreyColor),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: darkGreyColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ligthCoral,
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const TextLabel(texto: "Especie"),
            Column(
              children: tipo.map((tipo) {
                int value = tipo == 'Canino' ? 0 : 1;
                return RadioListTile(
                  activeColor: ligthCoral,
                  title: Text(tipo.toString()),
                  dense: true,
                  value: value,
                  groupValue: tipoSelecionado,
                  selected: true,
                  onChanged: (selectedValue) {
                    setState(() {
                      tipoSelecionado = selectedValue;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 15,
            ),
            const TextLabel(texto: "Fale um pouco sobre seu pet: "),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              maxLines: 5,
              controller: descricaoController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: darkGreyColor),
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: darkGreyColor),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: ligthCoral,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
                filled: true,
                fillColor: whiteColor,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  loading = true;
                });

                if (userToken == null || userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Você precisa estar logado para cadastrar um pet.')),
                  );
                  setState(() {
                    loading = false;
                  });
                  return;
                }

                if (nomeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: errorColor,
                      content: Text(
                        'O nome precisa ser preenchido',
                        style: TextStyle(
                            fontSize: 20, fontStyle: FontStyle.normal),
                      ),
                    ),
                  );
                  setState(() {
                    loading = false;
                  });
                  return;
                } else {
                  print(nomeController.text);
                }
                if (tipoSelecionado != 0 && tipoSelecionado != 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: errorColor,
                      content: Text(
                        'Selecione uma espécie',
                        style: TextStyle(
                            fontSize: 20, fontStyle: FontStyle.normal),
                      ),
                    ),
                  );
                  setState(() {
                    loading = false;
                  });
                  return;
                } else {
                  print(tipoSelecionado);
                }
                // Chama a função para cadastrar o pet
                cadastrarPet();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(ligthCoral),
              ),
              child: const Text(
                "Cadastrar",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}