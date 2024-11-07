import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:swifty/auth/auth.dart';
import 'package:swifty/component/button.dart';
import 'package:swifty/router/app_router.dart';
import 'package:swifty/store/store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // final store = Provider.of<StoreProvider>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Text('||||||||||||||||||||||||||'),
        )
        //    Container(
        //     decoration: const BoxDecoration(
        //       image: DecorationImage(
        //         image: AssetImage('assets/image/intra.jpg'),
        //         fit: BoxFit.cover, // Cover the entire screen
        //       ),
        //     ),
        //     child: Center(
        //       child: Padding(
        //         padding: const EdgeInsets.all(20),
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: <Widget>[
        //             SvgPicture.asset(
        //               'assets/icons/42_logo.svg',
        //               height: 80,
        //               width: 80,
        //             ),
        //             const SizedBox(height: 10),
        //             const Text(
        //               'Welcome to Swifty',
        //               style: TextStyle(
        //                 fontSize: 30,
        //                 fontWeight: FontWeight.bold,
        //                 color: Colors.white,
        //               ),
        //             ),
        //             const SizedBox(height: 20),
        //             MyButton(
        //                 text: 'SIGN IN',
        //                 onPressed: () async {
        //                   try {
        //                     final String token = await _authService.login();
        //                     if (token.isEmpty) {
        //                       throw Exception("Failed to retrieve access token");
        //                     }
        //                     store.setToken(token);
        //                     final Map<String, dynamic> user =
        //                         await _authService.getUserInfo(token);
        //                     if (user.isEmpty) {
        //                       throw Exception("Failed to retrieve user info");
        //                     }
        //                     store.setUser(user);
        //                     DetailsRoute().push(context);
        //                   } catch (e) {
        //                     print(e);
        //                   }
        //                 }),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),

        );
  }
}
