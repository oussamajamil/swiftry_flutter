import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:swifty/pages/details_page.dart';
import 'package:swifty/pages/home_page.dart';

import '../pages/login_page.dart';

part 'app_router.g.dart';

@TypedGoRoute<LoginRoute>(
  path: '/',
)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

@TypedGoRoute<DetailsRoute>(
  path: '/details',
)
class DetailsRoute extends GoRouteData {
  const DetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MyDetailsPage();
}
