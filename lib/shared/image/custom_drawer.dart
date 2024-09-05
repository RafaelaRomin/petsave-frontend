import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/cadastro_novo_pet.dart';
import '../../pages/dados_pet.dart';
import '../../pages/dados_tutor.dart';
import '../../pages/login_page.dart';
import '../../pages/termos_de_uso.dart';
import 'colors.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'No Name';
      userEmail = prefs.getString('userEmail') ?? 'No Email';
    });
    print('UserName: $userName');
    print('UserEmail: $userEmail');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/images/PETSAVE.png',
                fit: BoxFit.contain,
              ),
            ),
            decoration: BoxDecoration(
              color: ligthCoral,
            ),
          ),
          // Resto dos itens do drawer
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Dados do tutor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DadosTutor()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Dados do Pet'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DadosPet()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Cadastrar novo Pet'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroNovoPet()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Termos de uso'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermosDeUso()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: () async {
              bool confirm = await showLogoutConfirmationDialog(context);
              if (confirm) {
                await _logout(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Saída'),
        content: Text('Tem certeza que deseja sair?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Sair'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;
}

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Limpa todas as preferências salvas

  // Navega para a tela de login e remove todas as rotas anteriores
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
  );
}