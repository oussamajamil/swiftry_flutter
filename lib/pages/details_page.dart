import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:swifty/store/store.dart';

class MyDetailsPage extends StatelessWidget {
  const MyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = StoreProvider.user ?? {};
    return Scaffold(
        body: SafeArea(
      child: Text("hello world"),
    )
        // body: SafeArea(
        //   child: Scrollbar(
        //     child: Stack(
        //       children: [
        //         Column(
        //           children: [
        //             Container(
        //               width: double.infinity,
        //               padding: const EdgeInsets.all(20),
        //               color: Colors.blue,
        //               child: Column(
        //                 children: [
        //                   CircleAvatar(
        //                     radius: 50,
        //                     backgroundImage:
        //                         NetworkImage(user['image']['link'] ?? ''),
        //                   ),
        //                   const SizedBox(height: 5),
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Text(
        //                         user['login'] ?? '',
        //                         style: const TextStyle(
        //                           fontSize: 20,
        //                           fontWeight: FontWeight.bold,
        //                           color: Colors.white,
        //                         ),
        //                       ),
        //                       const SizedBox(width: 5),
        //                       Icon(
        //                         Icons.verified,
        //                         color: Colors.white,
        //                         size: 20,
        //                       ),
        //                     ],
        //                   ),
        //                   const SizedBox(height: 5),
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Text(
        //                         'points: ${user['correction_point'] ?? 0}',
        //                         style: const TextStyle(
        //                           fontSize: 16,
        //                           color: Colors.white,
        //                         ),
        //                       ),
        //                       const SizedBox(width: 100),
        //                       Text(
        //                         'wallet: ${user['wallet'] ?? 0}',
        //                         style: const TextStyle(
        //                           fontSize: 16,
        //                           color: Colors.white,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                   const SizedBox(height: 5),
        //                   Center(
        //                     child: LinearPercentIndicator(
        //                       width: double.infinity - 40,
        //                       lineHeight: 8.0,
        //                       percent: 0.9,
        //                       progressColor: Colors.orange,
        //                     ),
        //                   )
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //         Positioned(
        //           top: 10,
        //           left: 10,
        //           child: IconButton(
        //             icon: const Icon(Icons.logout),
        //             onPressed: () {
        //               Provider.of<StoreProvider>(context, listen: false).logout();
        //               Navigator.of(context).pop();
        //             },
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        );
  }
}
