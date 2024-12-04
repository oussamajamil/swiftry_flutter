import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swifty/pages/profile_page.dart';
import 'package:swifty/pages/search_page.dart';
import 'package:swifty/store/store.dart';

class MyDetailsPage extends StatelessWidget {
  const MyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      drawer: const NavigationDrawer(),
      body: Consumer<StoreProvider>(
        builder: (context, store, child) {
          final pageNumber = store.pageNumber;
          if (pageNumber == 0) {
            return MyProfilePage();
          } else if (pageNumber == 1) {
            return const MySearchProfile();
          } else {
            return const Center(child: Text("Page not found"));
          }
        },
      ),
    );
  }
}




class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context, listen: false);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      store.user?['image']["link"] ??
                          'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<StoreProvider>(
                    builder: (context, store, child) {
                      return Text(
                        store.user?['login'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      );
                    },
                  ),
                ],
              )),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            onTap: () {
              final store = Provider.of<StoreProvider>(context, listen: false);
              store.setSearchName(store.user?['login']);
              _navigateToPage(context, 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.green),
            title: const Text(
              "Search",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            onTap: () {
              _navigateToPage(context, 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            onTap: () {
              final store = Provider.of<StoreProvider>(context, listen: false);
              store.clearUser();
              store.setSearchName(null);
              GoRouter.of(context).go("/login");
            },
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    final store = Provider.of<StoreProvider>(context, listen: false);
    store.setPageNumber(index);

    switch (index) {
      case 0:
        store.setSearchName(store.user?['login']);
        GoRouter.of(context).go('/details/profile');
        break;
      case 1:
        GoRouter.of(context).go('/details/search');
        break;
    }

    // Safely close the drawer
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
