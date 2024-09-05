import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../shared/image/colors.dart';

class TermosDeUso extends StatefulWidget {
  const TermosDeUso({super.key});

  @override
  State<TermosDeUso> createState() => _TermosDeUsoState();
}

class _TermosDeUsoState extends State<TermosDeUso> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligthCoral,
        title: const Text("Termos de uso"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 30, right: 20, top: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: const Text(
                    'Esse aplicativo tem o intuito de ajudar animais que precisam de doaçāo de sangue!',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGreyColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  //padding: const EdgeInsets.all(15),
                  child: Container(
                    child: RichText(
                      //textAlign: TextAlign.justify,
                      text: const TextSpan(
                        text: 'Confira algumas informações importantes:\n',
                        style: TextStyle(color: darkGreyColor, fontSize: 18),
                        children: [
                          TextSpan(
                            text:
                                '\n• A idade ideal de doadores é de 2 à 8 anos;\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                '\n• O peso ideial é de (Cāes: min 25kg) e (Gatos: min 4kg);\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                '\n• Estar em dia com o controle de pulgas, carrapatos e vacinaçāo em dia;\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                '\n• Nāo ter passado por transfusāo de sangue recentemente;\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                '\n• Nāo tomar medicaçāo continua e nāo estar gestante ou lactante;\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                '\n• Nāo ter passado por nenhuma cirurgia ou procedimento cirurgico recente;\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                '\n• Para garantir o bem estar dos tutores e animais consideramos esses topicos termos a seguir para evitar eventuais problemas;\n',
                            style:
                                TextStyle(color: darkGreyColor, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/PETSAVE.png',
                        width: 250,
                      ),
                    ],
                  ),
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
