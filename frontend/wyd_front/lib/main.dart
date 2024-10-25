import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/controller/auth_controller.dart';
import 'package:wyd_front/state/events_provider.dart';
import 'package:wyd_front/state/my_app_state.dart';
import 'package:wyd_front/state/uri_provider.dart';
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

  SharedPreferences prefs = await SharedPreferences.getInstance();

  var data = prefs.getString('token') ?? ''; //null check
  runApp(MyApp(token: data));
}

class MyApp extends StatelessWidget {
  final String token;

  MyApp({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => UriProvider()),
        ChangeNotifierProvider(create: (context) => EventsProvider())
      ],
      child: MaterialApp.router(
        title: 'WYD?',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        locale: const Locale('it', 'IT'),
        routerConfig: _router,
      ),
    );
  }

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => _getPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: '/shared',
        builder: (BuildContext context, GoRouterState state) {
          String? uri = state.uri.toString();
          final uriProvider = Provider.of<UriProvider>(context);
          uriProvider.setUri(uri);
          return _getPage();
        },
      ),
    ],
  );

  Widget _getPage() {
    return token.isEmpty
        ? const LoginPage()
        : FutureBuilder(
            future: AuthController().testToken(),
            builder: (ctx, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return snapshot.data == true
                      ? const HomePage()
                      : const LoginPage();
                default:
                  return const LoadingPage(); //Loading
              }
            },
          );
  }
}
