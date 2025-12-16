import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wyd_front/router.dart';
import 'package:wyd_front/service/util/background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wyd_front/state/community_storage.dart';
import 'package:wyd_front/state/event/event_intervals_cache.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/event/event_details_cache.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/media/media_flag_cache.dart';
import 'package:wyd_front/state/profile/detailed_profiles_cache.dart';
import 'package:wyd_front/state/profile/profiles_cache.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_cache.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/state/user/view_settings_cache.dart';
import 'package:wyd_front/view/widget/loading_page.dart';

import 'firebase_options_dev.dart' as dev;
import 'firebase_options_prod.dart' as prod;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    BackgroundService.executeTask(task, inputData);
    return Future.value(true);
  });
}

Future main() async {
  //await initializeDateFormatting('it', 'IT');

  WidgetsFlutterBinding.ensureInitialized();

  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  await dotenv.load(fileName: '.env.$env');

  final firebaseOptions =
      env == 'prod' ? prod.DefaultFirebaseOptions.currentPlatform : dev.DefaultFirebaseOptions.currentPlatform;

  await Firebase.initializeApp(options: firebaseOptions);

  if (!kIsWeb) {
    Workmanager().initialize(callbackDispatcher);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => UserCache()),
        ChangeNotifierProvider(create: (_) => ProfileCache()),
        ChangeNotifierProvider(create: (_) => DetailedProfileCache()),
        ChangeNotifierProvider(create: (_) => ViewSettingsCache()),
        ChangeNotifierProvider(create: (_) => DetailedProfileEventsCache()),
        ChangeNotifierProvider(create: (_) => CommunityStorage()),
        ChangeNotifierProvider(create: (_) => EventsCache()),
        ChangeNotifierProvider(create: (_) => EventDetailsCache()),
        ChangeNotifierProvider(create: (_) => MaskCache()),
        ChangeNotifierProvider(create: (_) => MediaFlagCache()),
        Provider<EventIntervalsCache>(
          create: (_) => EventIntervalsCache(),
          dispose: (_, manager) => manager.dispose(),
        ),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const MaterialApp(
              title: 'WYD?',
              home: LoadingPage(),
            );
          }
          return MaterialApp.router(
            title: 'WYD?',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
              ),
            ),
            locale: const Locale('it', 'IT'),
            routerConfig: createRouter(authProvider),
          );
        },
      ),
    );
  }
}
