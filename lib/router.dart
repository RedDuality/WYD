import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/view/authentication/login.dart';
import 'package:wyd_front/view/home_page.dart';
import 'package:wyd_front/view/widget/loading.dart';

GoRouter createRouter(AuthenticationProvider authProvider) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    redirect: (context, state) {
      if (authProvider.isLoading) return null;

      final isAuthenticated = authProvider.isBackendVerified;
      final isLoggingIn = state.matchedLocation == '/login';

      if (isAuthenticated) {
        return isLoggingIn ? '/' : null;
      } else {
        final uriProvider = context.read<UriProvider>();
        String originalUri = state.uri.toString();
        uriProvider.setUri(originalUri);

        return isLoggingIn ? null : '/login';
      }
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return authProvider.isLoading
              ? const LoadingPage()
              : const HomePage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return authProvider.isLoading
              ? const LoadingPage()
              : const LoginPage();
        },
      ),
      GoRoute(
        path: '/shared',
        builder: (BuildContext context, GoRouterState state) {
          String? uri = state.uri.toString();
          final uriProvider = context.watch<UriProvider>();
          uriProvider.setUri(uri);
          return authProvider.isLoading
              ? const LoadingPage()
              : const HomePage();
        },
      ),
    ],
  );
}
