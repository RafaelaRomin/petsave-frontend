import 'package:flutter/material.dart';
import 'package:PetSave/shared/image/colors.dart';

class CardPage extends StatelessWidget {
  const CardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _buildInfoCard(
            "assets/images/perfil3.jpg",
            'Os cães têm um olfato extremamente aguçado, cerca de 40 vezes mais potente que o dos humanos. Eles podem detectar doenças, como câncer, através do cheiro.',
          ),
          const SizedBox(height: 30),
          _buildInfoCard(
            "assets/images/perfil2.png",
            'Gatos passam cerca de 70% de suas vidas dormindo. Eles também têm uma excelente visão noturna, sendo capazes de enxergar com apenas 1/6 da luz que os humanos precisam.',
          ),
          const SizedBox(height: 30),
          _buildInfoCard(
            "assets/images/perfiltutor.png",
            'A doação de sangue animal pode salvar vidas em casos de emergência, cirurgias e doenças. Assim como humanos, animais também precisam de transfusões sanguíneas em situações críticas.',
          ),
          const SizedBox(height: 30),
          _buildInfoCard(
            "assets/images/perfil3.jpg",
            'Para doar sangue, cães devem ter entre 1 e 8 anos, pesar mais de 25kg e estar em boa saúde. Gatos doadores devem ter entre 1 e 8 anos, pesar mais de 4kg e também estar saudáveis. Consulte sempre um veterinário antes de doar.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String imagePath, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.amber,
          radius: 40,
          child: CircleAvatar(
            radius: 38,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ligthCoral,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                text,
                style: const TextStyle(color: whiteColor, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}