import 'dart:convert';
import 'package:city/pages/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/image/colors.dart';
import 'package:city/pages/edit_tutor_screen.dart';

class DadosTutor extends StatefulWidget {
  const DadosTutor({super.key});

  @override
  State<DadosTutor> createState() => _DadosTutorState();
}

class _DadosTutorState extends State<DadosTutor> {
  Map<String, dynamic> tutorData = {};
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
    if (userToken != null && userId != null) {
      getTutorData();
    } else {
      print('User token or ID is null');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getTutorData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('$API_BASE_URL/v1/users/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          tutorData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          tutorData = {};
        });
        print('Failed to load tutor data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        tutorData = {};
      });
      print('Error loading tutor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text(
          "Perfil tutor",
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: ligthCoral,
                              borderRadius: BorderRadius.circular(20)),
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                        ),
                        const CircleAvatar(
                          backgroundColor: whiteColor,
                          radius: 55,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage("assets/images/PETSAVE.png"),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Informações do tutor",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Nome'),
                            subtitle: Text(tutorData['fullName'] ?? 'N/A'),
                          ),
                          Divider(color: midleLightGreyColor),
                          ListTile(
                            title: Text('Cidade/Estado'),
                            subtitle: Text(
                                '${tutorData['city'] ?? 'N/A'} - ${tutorData['state'] ?? 'N/A'}'),
                          ),
                          Divider(color: midleLightGreyColor),
                          ListTile(
                            title: Text('Telefone'),
                            subtitle: Text(tutorData['phoneNumber'] ?? 'N/A'),
                          ),
                          Divider(color: midleLightGreyColor),
                          ListTile(
                            title: Text('E-mail'),
                            subtitle: Text(tutorData['email'] ?? 'N/A'),
                          ),
                          Divider(color: midleLightGreyColor),
                          ListTile(
                            title: Text('Pets'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  (tutorData['pets'] as List<dynamic>? ?? [])
                                      .map((pet) {
                                return Text(
                                    '${pet['name']} (${pet['specie']})');
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTutorScreen(
                            tutorData: {
                              'fullName': tutorData['fullName'],
                              'city': tutorData['city'],
                              'state': tutorData['state'],
                              'email': tutorData['email'],
                              'phoneNumber': tutorData['phoneNumber'],
                            },
                            userToken: userToken!,
                            userId: userId!,
                          ),
                        ),
                      ).then((_) => getTutorData());
                    },
                    child: Text(
                      'Editar Perfil',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ligthCoral,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
