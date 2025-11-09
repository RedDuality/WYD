import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/util/uri_service.dart';
import 'package:wyd_front/view/authentication/login.dart';
import 'package:wyd_front/view/home_page.dart';
import 'package:wyd_front/view/widget/loading.dart';

// consumer of AuthenticationProvider
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

        String originalUri = state.uri.toString();
        UriService.saveUri(originalUri);

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
        path: '/share',
        builder: (BuildContext context, GoRouterState state) {
          String? uri = state.uri.toString();
          UriService.saveUri(uri);
          return authProvider.isLoading
              ? const LoadingPage()
              : const HomePage();
        },
      ),
    ],
  );
}
