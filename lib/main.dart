import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wyd_front/router.dart';
import 'package:wyd_front/service/util/background_service.dart';
import 'package:wyd_front/state/event/event_details_provider.dart';
import 'package:wyd_front/state/trash/calendar_view_event_controller.dart';
import 'package:wyd_front/state/eventEditor/cached_media_provider.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/community_provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/state/util/event_intervals_cache_manager.dart';
import 'package:wyd_front/state/util/uri_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    BackgroundService.executeTask(task, inputData);
    return Future.value(true);
  });
}

Future main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProfilesProvider()),
        ChangeNotifierProvider(create: (_) => CalendarViewEventController()),
        ChangeNotifierProvider(create: (_) => EventViewProvider()),
        ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
        ChangeNotifierProvider(create: (_) => CachedMediaProvider()),
        ChangeNotifierProvider(create: (_) => UriProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        Provider(create: (_) => EventIntervalsCacheManager()),
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
            routerConfig: createRouter(authProvider),
          );
        },
      ),
    );
  }
}
