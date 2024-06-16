import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/controller/auth_controller.dart';
import 'package:wyd_front/state/my_app_state.dart';
import 'package:wyd_front/view/home_page.dart';
import 'package:wyd_front/view/login.dart';
import 'package:url_strategy/url_strategy.dart';

Future main() async {
  setPathUrlStrategy();
  await dotenv.load(fileName: ".env");

  SharedPreferences prefs = await SharedPreferences.getInstance();

  var data = prefs.getString('token') ?? ''; //null check
  runApp(MyApp(token: data));
}

class MyApp extends StatelessWidget {
  String token = '';

  MyApp({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MyAppState(),
        ),
      ],
      child: MaterialApp.router(
        title: 'WYD',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        locale: const Locale('it', 'IT'),
        routerConfig: _router,
        /*
        initialRoute: '/',
        routes: {
          '/shared': (context) => _getPage(pageIndex: 1),
          '/login': (context) => const LoginPage(),
          '/home': (context) => _getPage(pageIndex: 3),
        },
        onGenerateRoute:(settings) {
          debugPrint(settings.toString());
        
        },
        onUnknownRoute: (settings) {
          debugPrint("name ${settings.name}");

          return MaterialPageRoute(builder: (context) => _getPage());
        },*/

      ),
    );
  }




  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
             _getPage(pageIndex: 0),
      ),
      GoRoute(
        path: '/login',
        
        builder: (BuildContext context, GoRouterState state) =>
           const LoginPage(),
      ),
      GoRoute(
        path: '/shared',
        builder: (BuildContext context, GoRouterState state) =>
           _getPage(pageIndex: 1),
      ),
    ],

  );


  Widget _getPage({int pageIndex = 0}) {
    debugPrint("getpage $pageIndex");
    return token.isEmpty
        ? LoginPage(desiredPage: pageIndex)
        : FutureBuilder(
            future: AuthController().testToken(),
            builder: (ctx, snapshot) =>
                snapshot.connectionState == ConnectionState.done &&
                        snapshot.data == true
                    ? HomePage(initialIndex: pageIndex)
                    : LoginPage(desiredPage: pageIndex));
  }
}
