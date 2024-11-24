import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/authentication_provider.dart';
import 'package:wyd_front/state/my_app_state.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/state/user_provider.dart';
import 'package:wyd_front/view/home_page.dart';
import 'package:wyd_front/view/login.dart';
import 'package:wyd_front/widget/loading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
        ChangeNotifierProvider(create: (_) => PrivateProvider()),
        ChangeNotifierProvider(create: (_) => SharedProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UriProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'WYD?',
            theme: ThemeData(
              useMaterial3: true,
              //
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
              ),
            ),
            locale: const Locale('it', 'IT'),
            routerConfig: _router(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _router(AuthenticationProvider authProvider) {
    return GoRouter(
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
    // localhost:9019/#/shared?event=r2Yb5_2uMFLScnuJq0mb3w
  }
}
