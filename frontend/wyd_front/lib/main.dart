
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/login_state.dart';
import 'package:wyd_front/state/my_app_state.dart';
import 'package:wyd_front/state/private_events.dart';
import 'package:wyd_front/state/shared_events.dart';
import 'package:wyd_front/view/home_page.dart';


Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        Provider(create: (context) => PrivateEvents(),),
        Provider(create: (context) => SharedEvents(),),
        ChangeNotifierProvider(create: (context) => MyAppState(),),
        Provider(create: (context) => LoginState(),),
      ],
      child: MaterialApp(
        title: 'WYD',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        locale: const Locale('it','IT'),
        home: const HomePage(),
      ),
    );
  }
}


