import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:horizontal_scroll_view/horizontal_scroll_view.dart';
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
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 80, 77, 84),
                      borderRadius: BorderRadius.circular(
                          15), // Adjust the radius as needed
                    ),
                    child: Stack(children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                              snapshot.data?['image']["link"] ??
                                  'https://cdn.intra.42.fr/users/medium_default.png',
                            ),
                          ),
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
                                    value: snapshot.data?['cursus_users'][0]
                                                ["level"] -
                                            snapshot.data?['cursus_users'][0]
                                                    ["level"]
                                                ?.floorToDouble() ??
                                        0,
                                    backgroundColor: const Color.fromARGB(
                                        255, 184, 188, 188),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color.fromARGB(255, 27, 143, 73)),
                                  ),
                                ),
                              ),
                              Text(
                                "${snapshot.data?['cursus_users']?[1]["level"]?.toString() ?? ''}%",
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
                  const SizedBox(height: 10),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 180, // Slightly increased height for better spacing
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data?['projects_users']
                            .where((project) =>
                                project['status'] == 'finished' &&
                                project['final_mark'] != null &&
                                project['final_mark'] > 10)
                            .length,
                        itemBuilder: (context, index) {
                          final project = snapshot.data?['projects_users']
                              .where((project) =>
                                  project['status'] == 'finished' &&
                                  project['final_mark'] != null &&
                                  project['final_mark'] > 10)
                              .toList()[index];
                          return Container(
                            width: 160, // Adjusted card width
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project['project']['name'] ??
                                        'Unnamed Project',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${project['status'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    project['final_mark'] != null
                                        ? 'Grade: ${project['final_mark']}'
                                        : 'Not graded',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 29, 176, 39),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 200, // Slightly increased height for better spacing
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data?['projects_users']
                            .where((project) =>
                                project['status'] != 'finished' &&
                                project['final_mark'] == null)
                            .length,
                        itemBuilder: (context, index) {
                          final project = snapshot.data?['projects_users']
                              .where((project) =>
                                  project['status'] != 'finished' &&
                                  project['final_mark'] == null)
                              .toList()[index];
                          return Container(
                            width: 160, // Adjusted card width
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project['project']['name'] ??
                                        'Unnamed Project',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${project['status'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    project['final_mark'] != null
                                        ? 'Grade: ${project['final_mark']}'
                                        : 'Not graded',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 29, 176, 39),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                    height: 200,
                    color: const Color.fromARGB(255, 246, 248, 246),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: RadarChart.light(
                        ticks: (snapshot.data?['cursus_users'][1]['skills']
                                as List)
                            .map<int>(
                                (skill) => (skill['level'] as num).toInt())
                            .toList(),
                        features: (snapshot.data?['cursus_users'][1]['skills']
                                as List)
                            .map<String>((skill) => skill['name'].toString())
                            .toList(),
                        data: [
                          (snapshot.data?['cursus_users'][1]['skills'] as List)
                              .map<int>((skill) =>
                                  (skill['level'] / 1000 as num).toInt())
                              .toList()
                        ],
                        reverseAxis: true,
                        useSides: true,

                        /// text size of the axis
                        // fontSize: 12, not working
                        // text size of the axis
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
