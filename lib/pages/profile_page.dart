import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:provider/provider.dart';
import 'package:swifty/store/store.dart';
import 'package:http/http.dart' as http;

class MyProfilePage extends StatefulWidget {
  final String? loginSender;
  const MyProfilePage({super.key, this.loginSender});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late Future<Map<String, dynamic>> _userDetail;
  @override
  void initState() {
    final store = Provider.of<StoreProvider>(context, listen: false);
    if (store.user == null) {
      Navigator.of(context).pop();
    }
    super.initState();
    _userDetail =
        getUserDetail(store.searchName ?? store.user?["login"], store.token);
  }

  void printLongMessage(String message) {
    const int chunkSize = 1000; // Define a safe chunk size
    for (int i = 0; i < message.length; i += chunkSize) {
      print(message.substring(
          i, i + chunkSize > message.length ? message.length : i + chunkSize));
    }
  }

  Future<Map<String, dynamic>> getUserDetail(login, token) async {
    final response = await http.get(
      Uri.parse('https://api.intra.42.fr/v2/users/$login'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      printLongMessage('User detail fetched successfully: ${response.body}');
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user detail');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: FutureBuilder<Map<String, dynamic>>(
      future: _userDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}', // Display error message here
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                width: MediaQuery.of(context).size.width, // Full width
                height: MediaQuery.of(context).size.height,
                color: const Color.fromARGB(255, 232, 233, 234),
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),

                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                          15), // Adjust the radius as needed
                    ),

                    /// i need the rounded

                    child: Stack(children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(
                              snapshot.data?['image']["link"] ??
                                  'https://cdn.intra.42.fr/users/medium_default.png',
                            ),
                          ),

                          // const SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data?['first_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  snapshot.data?['last_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ]),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                snapshot.data?['email'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      snapshot.data?['login'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      snapshot.data?['kind'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.wallet_outlined,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    snapshot.data?['wallet'].toString() ?? '0',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${snapshot.data!['correction_point']}          ",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (snapshot.data?['phone'] != null &&
                              snapshot.data?['phone'] != 'hidden')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  snapshot.data?['phone'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 18,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: 0.2 / 21,
                                    backgroundColor: const Color.fromARGB(
                                        255, 184, 188, 188),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color.fromARGB(255, 27, 143, 73)),
                                  ),
                                ),
                              ),
                              Text(
                                "${snapshot.data?['level']?.toString() ?? ''}%",
                                style: const TextStyle(
                                  color: Colors.black26,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Projects',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(completed)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 155,
                    color: const Color.fromARGB(255, 207, 209, 207),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: ListView.builder(
                          itemCount: snapshot.data?['projects_users']
                              .where(
                                  (project) => project['status'] == 'finished')
                              .length,
                          itemBuilder: (context, index) {
                            final finishedProjects = snapshot
                                .data?['projects_users']
                                .where((project) =>
                                    project['status'] == 'finished')
                                .toList();

                            final project = finishedProjects[index];
                            return ListTile(
                              title: Text(project['project']['name']),
                              subtitle: Text(project['status']),
                              trailing: Text(
                                project['final_mark'] != null
                                    ? project['final_mark'].toString()
                                    : 'Not graded',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 29, 176, 39),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Projects',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(in progress)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 155,
                    color: const Color.fromARGB(255, 207, 209, 207),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: ListView.builder(
                          itemCount: snapshot.data?['projects_users']
                              .where(
                                  (project) => project['status'] != 'finished')
                              .length,
                          itemBuilder: (context, index) {
                            final finishedProjects = snapshot
                                .data?['projects_users']
                                .where((project) =>
                                    project['status'] != 'finished')
                                .toList();

                            final project = finishedProjects[index];
                            return ListTile(
                              title: Text(project['project']['name']),
                              subtitle: Text(project['status']),
                              trailing: Text(
                                project['final_mark'] != null
                                    ? project['final_mark'].toString()
                                    : 'Not graded',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 29, 176, 39),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Skills',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 175,
                    color: const Color.fromARGB(255, 207, 209, 207),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: RadarChart.light(
                        ticks: (snapshot.data?['cursus_users'][0]['skills']
                                as List)
                            .map<int>(
                                (skill) => (skill['level'] as num).toInt())
                            .toList(),
                        features: (snapshot.data?['cursus_users'][0]['skills']
                                as List)
                            .map<String>((skill) => skill['name'].toString())
                            .toList(),
                        data: [
                          (snapshot.data?['cursus_users'][0]['skills'] as List)
                              .map<int>(
                                  (skill) => (skill['level'] as num).toInt())
                              .toList()
                        ],
                        reverseAxis: true,
                        useSides: true,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    )));
  }
}
