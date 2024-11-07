import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swifty/auth/auth.dart';
import 'package:swifty/router/app_router.dart';
import 'package:swifty/store/store.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => StoreProvider(), child: const MyApp()),
  );
}

late final GoRouter _router = GoRouter(
  debugLogDiagnostics: true,
  routes: $appRoutes,
  redirect: (context, state) async {
    print("i ma here in first redirect");
    //// check token in store
    if (StoreProvider.token == null) {
      return const LoginRoute().location;
    }
    final AuthService _authService = AuthService();
    final bool isTokenValid =
        await _authService.checktoken(StoreProvider.token!);
    print('isTokenValid: $isTokenValid');
    if (!isTokenValid) {
      print("test test")
      return const LoginRoute().location;
    } else {
        print("test test")
      return const DetailsRoute().location;
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
