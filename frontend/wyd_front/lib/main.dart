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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
        ChangeNotifierProvider(create: (_) => PrivateProvider()),
        ChangeNotifierProvider(create: (_) => SharedProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UriProvider()),
        ChangeNotifierProvider(
            create: (context) => AuthenticationProvider(context: context)),
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
        // Wait until loading and backend verification complete
        if (authProvider.isLoading) return null;

        final isAuthenticated = authProvider.isBackendVerified;
        final isLoggingIn = state.matchedLocation == '/login';

        // Step 1: Determine desiredUri
        String originalUri = state.uri.toString();
        debugPrint("Original URI: $originalUri");
        String desiredUri = Uri.encodeComponent(originalUri);

        if (!isAuthenticated) {
          // Log desiredUri before redirect
          debugPrint("Unauthenticated. Desired URI (encoded): $desiredUri");

          // Redirect unauthenticated users to login
          return isLoggingIn
              ? null
              : (originalUri == '/' ? '/login' : '/login?redirect=$desiredUri');
        }

        // Step 2: Handle redirection after login
        if (isAuthenticated && isLoggingIn) {
          // Retrieve and decode the redirect query parameter
          String? redirectQuery = state.uri.queryParameters['redirect'];
          debugPrint("Redirect query parameter (raw): $redirectQuery");

          if (redirectQuery != null) {
            redirectQuery = Uri.decodeComponent(redirectQuery);
            debugPrint("Redirect query parameter (decoded): $redirectQuery");
          }

          return redirectQuery ?? '/';
        }

        return null; // No redirect needed
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
          path: '/register',
          builder: (BuildContext context, GoRouterState state) =>
              const RegisterPage(),
        ),
        GoRoute(
          path: '/shared',
          builder: (BuildContext context, GoRouterState state) {
            debugPrint("ciao");
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
