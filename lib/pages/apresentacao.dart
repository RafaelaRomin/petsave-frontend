import 'package:PetSave/pages/dados_cadastrais_pet.dart';
import 'package:flutter/material.dart';

import '../shared/image/colors.dart';

class Apresentacao extends StatefulWidget {
  const Apresentacao({super.key});

  @override
  State<Apresentacao> createState() => _ApresentacaoState();
}

class _ApresentacaoState extends State<Apresentacao> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligthCoral,
        title: const Text("Bem vindo"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 30, right: 20, top: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    'Estamos quase lá!',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: darkGreyColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/bem-vindo.png',
                        width: 500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  child: Container(
                    child: RichText(
                      //
                      text: const TextSpan(
                        text:
                            'Agora so falta você registrar seu pet para que ele possa ajudar doando sangue para um animal compativel ou encontre um doador para ele.',
                        style: TextStyle(color: darkGreyColor, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 400,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(ligthCoral),
                    ),
                    onPressed: () {
                      //pushreplacement pois nao pdoe voltar para a page de login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DadosCadastraisPet(),
                        ),
                      );
                    },
                    child: const Text(
                      "Cadastre seu pet",
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
                  height: 15,
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
