import 'dart:convert';
import 'package:city/pages/api_config.dart';
import 'package:city/shared/image/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> petsList = [];
  bool isLoading = false;
  String? userToken;
  String selectedSpecies = 'All'; // New variable for species filter

  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }

  Future<void> _loadUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
    });
    getAllPets();
  }

  Future<void> getAllPets({String query = ''}) async {
    if (userToken == null) {
      print('User token is null');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String urlString = '$API_BASE_URL/v1/pets';
      if (query.isNotEmpty) {
        urlString += '?filter=$query';
      }
      if (selectedSpecies != 'All') {
        urlString += urlString.contains('?') ? '&' : '?';
        urlString += 'specieSelected=$selectedSpecies';
      }
      final url = Uri.parse(urlString);
      print('Fetching pets from URL: $url');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          petsList = jsonDecode(response.body);
          isLoading = false;
        });
        print('Pets loaded successfully');
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

  Future<void> refreshPets() async {
    await getAllPets();
  }

  void searchPets() {
    String query = searchController.text;
    getAllPets(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pets Disponíveis'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshPets,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Pesquisar',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: searchPets,
                      ),
                    ),
                    onSubmitted: (_) => searchPets(),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedSpecies,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'All',
                      child: Row(
                        children: [
                          Icon(Icons.pets, color: ligthCoral),
                          SizedBox(width: 8),
                          Text('Todos'),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Canine',
                      child: Row(
                        children: [
                          Icon(Icons.pets, color: ligthCoral),
                          SizedBox(width: 8),
                          Text('Cães'),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Feline',
                      child: Row(
                        children: [
                          Icon(Icons.pets, color: ligthCoral),
                          SizedBox(width: 8),
                          Text('Gatos'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedSpecies = newValue;
                      });
                      searchPets();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: refreshPets,
                    child: ListView.builder(
                      itemCount: petsList.length,
                      itemBuilder: (context, index) {
                        final pet = petsList[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          color: Colors.pink[50], // Light pink background
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet['name'],
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                    'Espécie: ${pet['specie'] == 'Canine' ? 'Canino' : pet['specie'] == 'Feline' ? 'Felino' : pet['specie'] ?? 'Não especificada'}',
                                    style: TextStyle(fontSize: 16)),
                                Text('Peso: ${pet['weight']} kg',
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    'Status de Doação: ${pet['donationStatus'] == 'Available' ? 'Disponível' : pet['donationStatus'] == 'Unable' ? 'Indisponível' : pet['donationStatus'] ?? 'Não especificado'}',
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8),
                                Text('Tutor: ${pet['tutorName']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                Text('Telefone: ${pet['tutorPhoneNumber']}',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
