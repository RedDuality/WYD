import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/authentication_provider.dart';
import 'package:wyd_front/state/events_provider.dart';
import 'package:wyd_front/state/my_app_state.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/state/user_provider.dart';
import 'package:wyd_front/view/home_page.dart';
import 'package:wyd_front/view/login.dart';
import 'package:wyd_front/view/register.dart';
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
    final privateProvider = PrivateProvider();
    final sharedProvider = SharedProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
        ChangeNotifierProvider<PrivateProvider>.value(value: privateProvider),
        ChangeNotifierProvider<SharedProvider>.value(value: sharedProvider),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            privateProvider: privateProvider,
            sharedProvider: sharedProvider,
          ),
        ),
        ChangeNotifierProvider(
            create: (context) => AuthenticationProvider(context: context)),
        ChangeNotifierProvider(create: (_) => UriProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'WYD?',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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
        // Wait until the loading process completes
        if (authProvider.isLoading) return null;

        final isLoggingIn = state.matchedLocation == '/login';

        debugPrint("location${state.matchedLocation}");
        final needsAuth =
            !authProvider.isAuthenticated || !authProvider.isBackendVerified;

        // Redirect unauthenticated users to login, unless they're already on the login page
        if (needsAuth && !isLoggingIn) return '/login';

        // Redirect authenticated users away from the login page if they're already logged in
        if (!needsAuth && isLoggingIn) return '/';

        return null; // No redirection needed
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
          builder: (BuildContext context, GoRouterState state) =>
              const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) =>
              const RegisterPage(),
        ),
        GoRoute(
          path: '/shared',
          builder: (BuildContext context, GoRouterState state) {
            String? uri = state.uri.toString();
            final uriProvider = Provider.of<UriProvider>(context);
            uriProvider.setUri(uri);
            return authProvider.isLoading
                ? const LoadingPage()
                : const HomePage();
          },
        ),
      ],
    );
  }
}
