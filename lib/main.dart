import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swifty/pages/details_page.dart';
import 'package:swifty/pages/login_page.dart';
import 'package:swifty/pages/profile_page.dart';
import 'package:swifty/pages/search_page.dart';
import 'package:swifty/store/store.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => StoreProvider(), child: const MyApp()),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: "/login",
      pageBuilder: (context, state) => MaterialPage(child: const LoginPage()),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => const MyDetailsPage(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => MyProfilePage(),
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) => MySearchProfile(),
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final token = storeProvider.token;
    if (token == null) {
      return "/login";
    } else {
      return "/details";
    }
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false, routerConfig: _router);
  }
}
