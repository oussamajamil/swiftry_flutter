import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:swifty/auth/auth.dart';
import 'package:swifty/store/store.dart';
import 'package:http/http.dart' as http;

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late Future<Map<String, dynamic>> _userDetail;
  late StoreProvider store;
  final AuthService _authService = AuthService();
  bool show_loader = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = Provider.of<StoreProvider>(context, listen: false);
    store.addListener(_onStoreUpdated);
  }

  void _onStoreUpdated() {
    if (store.searchName != null && mounted) {
      setState(() {
        _userDetail = getUserDetail(store.searchName!, store.token);
      });
    }
  }

  @override
  void dispose() {
    store.removeListener(_onStoreUpdated);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    store = Provider.of<StoreProvider>(context, listen: false);
    if (store.user == null) {
      Navigator.of(context).pop();
    } else {
      _userDetail =
          getUserDetail(store.searchName ?? store.user?["login"], store.token);
    }
  }

  void printLongMessage(String message) {
    const int chunkSize = 1000; // Define a safe chunk size
    for (int i = 0; i < message.length; i += chunkSize) {
      print(message.substring(
          i, i + chunkSize > message.length ? message.length : i + chunkSize));
    }
  }

  Future<Map<String, dynamic>> getUserDetail(login, token) async {
    if (login == null || token == null) {
      return {};
    }
    final response = await http.get(
      Uri.parse('https://api.intra.42.fr/v2/users/$login'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401 && store.getRetry < 3) {
      final String token = await _authService.login();
      final Map<String, dynamic> user = await _authService.getUserInfo(token);
      store.setUser(user);
      store.setToken(token);
      store.setRetry(store.getRetry + 1);
      return getUserDetail(login, token);
    } else if (response.statusCode == 401) {
      /// redirect to login page
      Navigator.of(context).pop();
      store.clearUser();
      return {};
    } else if (response.statusCode == 429) {
      return Future.delayed(const Duration(seconds: 5), () {
        return getUserDetail(login, token);
      });
    } else {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On Snap!',
          message: 'Failed to load user details',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return {};
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: FutureBuilder<Map<String, dynamic>>(
      future: _userDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            show_loader) {
          return Center(
            child: LoadingAnimationWidget.twistingDots(
              leftDotColor: const Color.fromARGB(255, 196, 196, 203),
              rightDotColor: const Color.fromARGB(255, 7, 182, 191),
              size: 150,
            ),
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
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  show_loader = false;
                });
                await getUserDetail(
                        store.searchName ?? store.user?["login"], store.token)
                    .then((value) {
                  setState(() {
                    show_loader = true;
                  });
                  _userDetail = Future.value(value);
                  return value;
                });
              },
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Column(children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 80, 77, 84),
                        borderRadius: BorderRadius.circular(
                            15), // Adjust the radius as needed
                      ),
                      child: Stack(children: [
                        Positioned(
                          top: 10,
                          right: 8,
                          child: Container(
                            height: 30,
                            width: 130,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 151, 148, 155),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (snapshot.data?['location'] != null)
                                  Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 14, 241, 105),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        snapshot.data?['location'] ?? '',
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 14, 241, 105),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (snapshot.data?['location'] == null)
                                  Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 224, 156, 8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Unavailable',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 255, 175, 2),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(snapshot
                                        .data?['image']?["link"] ??
                                    'https://cdn.intra.42.fr/users/medium_default.png'),
                                child: snapshot.data?['image']?["link"] == null
                                    ? Text(
                                        'No Image',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : null,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.wallet_outlined,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        snapshot.data?['wallet'].toString() ??
                                            '0',
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
                              if (snapshot.data?['cursus_users'] is List &&
                                  (snapshot.data?['cursus_users'] as List)
                                      .isNotEmpty &&
                                  snapshot.data?['cursus_users'].length > 1 &&
                                  snapshot.data?['cursus_users'][1]?["level"] !=
                                      null)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: snapshot.data?['cursus_users']
                                                      [1]["level"] -
                                                  snapshot.data?['cursus_users']
                                                          [1]["level"]
                                                      ?.floorToDouble() ??
                                              0,
                                          backgroundColor: const Color.fromARGB(
                                              255, 130, 128, 128),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                      Color>(
                                                  Color.fromARGB(
                                                      255, 27, 143, 73)),
                                        ),
                                      ),
                                    ),
                                    if (snapshot.data?['cursus_users']
                                            is List &&
                                        (snapshot.data?['cursus_users'] as List)
                                            .isNotEmpty &&
                                        snapshot.data?['cursus_users'][1]
                                                ?["level"] !=
                                            null)
                                      Text(
                                        "${snapshot.data?['cursus_users']?[1]["level"]?.toStringAsFixed(2) ?? ''}%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                  ],
                                ),
                            ],
                          ),
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
                    SizedBox(
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Builder(
                          builder: (context) {
                            final projects =
                                snapshot.data?['projects_users'] as List? ?? [];
                            final filteredProjects = projects.where((project) {
                              return project['status'] == 'finished' &&
                                  project['final_mark'] != null &&
                                  project['final_mark'] > 10;
                            }).toList();

                            if (filteredProjects.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Data not found',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredProjects.length,
                              itemBuilder: (context, index) {
                                final project = filteredProjects[index];
                                return Container(
                                  width: 200, // Adjusted card width
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 29, 176, 39),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                      height:
                          200, // Slightly increased height for better spacing
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Builder(
                          builder: (context) {
                            final projects =
                                snapshot.data?['projects_users'] as List? ?? [];
                            final filteredProjects = projects.where((project) {
                              return project['status'] != 'finished' &&
                                  project['final_mark'] == null;
                            }).toList();

                            if (filteredProjects.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Data not found',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredProjects.length,
                              itemBuilder: (context, index) {
                                final project = filteredProjects[index];
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: Color.fromARGB(
                                                255, 29, 176, 39),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                      color: snapshot.data?['cursus_users'] is List &&
                              snapshot.data?['cursus_users'].length > 1
                          ? const Color.fromARGB(255, 246, 248, 246)
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Builder(
                          builder: (context) {
                            final cursusUsers = snapshot.data?['cursus_users'];
                            if (cursusUsers is List && cursusUsers.length > 1) {
                              final skills = cursusUsers[1]['skills'];
                              if (skills is List) {
                                try {
                                  final ticks = skills
                                      .map<int>((skill) =>
                                          (skill['level'] as num).toInt())
                                      .toList();
                                  final features = skills
                                      .map<String>((skill) =>
                                          (skill['name'] ?? '').toString())
                                      .toList();
                                  final data = skills
                                      .map<num>((skill) =>
                                          (((skill['level'] as num?) ?? 0) /
                                              10))
                                      .toList();
                                  return RadarChart(
                                    ticks: ticks,
                                    features: features,
                                    data: [data],
                                    featuresTextStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint('Error processing skills: $e');
                                  return const Center(
                                    child: Text(
                                      'Invalid data format',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                              }
                            }
                            return const Center(
                              child: Text(
                                'Data not found',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    )));
  }
}
