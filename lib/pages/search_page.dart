import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:swifty/auth/auth.dart';
import 'package:swifty/store/store.dart';

class MySearchProfile extends StatefulWidget {
  const MySearchProfile({super.key});

  @override
  State<MySearchProfile> createState() => _MySearchProfileState();
}

class _MySearchProfileState extends State<MySearchProfile> {
  late Future<List<dynamic>> _SearchDetails; // Change to List<dynamic>
  late TextEditingController searchController;
  late String searchTerm;
  late Timer _debounce;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    final store = Provider.of<StoreProvider>(context, listen: false);
    super.initState();
    searchController = TextEditingController();
    _SearchDetails = Future.value([]); // Initially an empty list
    searchTerm = '';
    if (store.user == null) {
      Navigator.of(context).pop();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {});
    _SearchDetails = getUsers(searchTerm, store.token ?? '');
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce.cancel();
    super.dispose();
  }

  Future<List<dynamic>> getUsers(String login, String token) async {
    final store = Provider.of<StoreProvider>(context, listen: false);

    final response = await http.get(
      Uri.parse(
        'https://api.intra.42.fr/v2/users?filter[login]=$login',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else if (response.statusCode == 401 && store.getRetry < 3) {
      final String token = await _authService.login();
      final Map<String, dynamic> user = await _authService.getUserInfo(token);

      store.setUser(user);
      store.setToken(token);
      store.setRetry(store.getRetry + 1);
      return getUsers(login, token);
    } else if (response.statusCode == 401) {
      /// redirect to login page
      Navigator.of(context).pop();
      store.clearUser();
      return Future.value([]);
    } else {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On Snap!',
          message: 'Failed to load users',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      final store = Provider.of<StoreProvider>(context, listen: false);
      store.clearUser();
      store.setSearchName(null);
      GoRouter.of(context).go("/login");
      throw Exception('Failed to load users');
    }
  }

  void onSearchChanged(String query) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchTerm = query;
        // Trigger search again based on the new query
        final store = Provider.of<StoreProvider>(context, listen: false);
        _SearchDetails = getUsers(searchTerm, store.token ?? '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search 42 Users',
                  hintText: 'Enter a login or display name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: onSearchChanged, // Handle search term change
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _SearchDetails, // Use the list type here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.twistingDots(
                        leftDotColor: const Color.fromARGB(255, 196, 196, 203),
                        rightDotColor: const Color.fromARGB(255, 7, 182, 191),
                        size: 100,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}', // Display error message here
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    // Assuming the API returns a list of users
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['image']['link'] != null
                                ? NetworkImage(user['image']['link'])
                                : null,
                            child: user['image']['link'] == null
                                ? Text(user['login'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(user['login']),
                          subtitle: Text(user['displayname'] ?? ''),
                          onTap: () {
                            final store = Provider.of<StoreProvider>(context,
                                listen: false);
                            store.setSearchName(user['login']);
                            store.setPageNumber(0);
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
