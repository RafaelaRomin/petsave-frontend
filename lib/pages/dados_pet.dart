import 'dart:convert';
import 'package:city/pages/api_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/image/colors.dart';
import 'package:http/http.dart' as http;
import 'package:city/pages/edit_pet_page.dart'; // Add this import

class DadosPet extends StatefulWidget {
  const DadosPet({super.key});

  @override
  State<DadosPet> createState() => _DadosPetState();
}

class _DadosPetState extends State<DadosPet> {
  List<dynamic> petsList = [];
  bool isLoading = true;
  String? userToken;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
      userId = prefs.getString('userId');
    });
    print('Loaded userToken: $userToken');
    print('Loaded userId: $userId');
    if (userToken != null && userId != null) {
      getPetsByTutor();
    } else {
      print('User token or ID is null. Token: $userToken, ID: $userId');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getPetsByTutor() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('$API_BASE_URL/v1/pets/by-tutor/$userId');
      print('Fetching pets from URL: $url');
      print('Using token: $userToken');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decodedBody = jsonDecode(response.body);
        print('Decoded body: $decodedBody');

        setState(() {
          petsList = decodedBody.map((pet) {
            return {
              ...pet,
              'id': pet['id'].toString(), // Ensure ID is stored as a string
            };
          }).toList();
          isLoading = false;
        });
        print('Processed petsList: $petsList');
      } else {
        setState(() {
          isLoading = false;
          petsList = [];
        });
        print('Failed to load pets. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        petsList = [];
      });
      print('Error loading pets: $e');
    }
  }

  Future<void> deletePet(String? petId) async {
    print('Attempting to delete pet with ID: $petId');
    print('Current userToken: $userToken');

    if (petId == null || userToken == null) {
      print(
          'Error: petId or userToken is null. petId: $petId, userToken: $userToken');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erro: Informações do pet ou usuário não disponíveis')),
      );
      return;
    }

    try {
      final url = Uri.parse('$API_BASE_URL/v1/pets/$petId');
      print('Deleting pet with ID: $petId');
      print('URL: $url');
      print('Token: $userToken');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
          'accept': '*/*',
        },
      ).timeout(Duration(seconds: 10));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet deletado com sucesso')),
        );
        getPetsByTutor();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao deletar pet: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      print('Error deleting pet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar na API: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text("Meus Pets"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : petsList.isEmpty
              ? Center(child: Text("Nenhum pet encontrado"))
              : ListView.builder(
                  itemCount: petsList.length,
                  itemBuilder: (context, index) {
                    final pet = petsList[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet['name'] ?? 'Nome não disponível',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Espécie: ${
                                      pet['specie'] == 'Canine' ? 'Canino' :
                                      pet['specie'] == 'Feline' ? 'Felino' :
                                      pet['specie'] ?? 'Não especificada'
                                  }'),
                                  Text('Raça: ${pet['race'] ?? 'Não especificada'}'),
                                  Text('Peso: ${pet['weight'] ?? 'Não especificado'} kg'),
                                  Text('Idade: ${pet['age'] != null ? '${pet['age']} ano(s)' : 'Não especificada'}'),
                                  Text('Status: ${
                                      pet['donationStatus'] == 'Available' ? 'Disponível' :
                                      pet['donationStatus'] == 'Unable' ? 'Indisponível' :
                                      pet['donationStatus'] ?? 'Não especificado'
                                  }'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditPetPage(
                                      pet: Map<String, dynamic>.from(pet), // Modificação aqui
                                      userId: userId!,
                                      userToken: userToken!,
                                    ),
                                  ),
                                ).then((_) => getPetsByTutor());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmar exclusão'),
                                      content: Text(
                                          'Tem certeza que deseja excluir ${pet['name']}?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Excluir'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            final petId = pet['id'];
                                            print(
                                                'Attempting to delete pet: $petId');
                                            if (petId != null) {
                                              deletePet(petId);
                                            } else {
                                              print(
                                                  'Error: Pet ID is null. Full pet object: $pet');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Erro: ID do pet não disponível')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
