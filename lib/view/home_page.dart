import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/service/model/community_service.dart';
import 'package:wyd_front/service/util/notification_service.dart';
import 'package:wyd_front/service/util/permission_service.dart';
import 'package:wyd_front/service/media/media_auto_select_service.dart';
import 'package:wyd_front/service/util/real_time_updates_service.dart';
import 'package:wyd_front/state/util/uri_service.dart';
import 'package:wyd_front/view/events/events_page.dart';
import 'package:wyd_front/view/groups/group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late int selectedIndex;
  bool private = true;
  String uri = "/";
  bool isUriLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedIndex = 0;

    _loadUri();
    _initializeServices();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSecondaryServices();
    });
  }

  Future<void> _loadUri() async {
    uri = await UriService.getUri();
    if (uri.isNotEmpty) {
      final destination = uri.split('?').first.replaceAll('/', '');
      if (destination == 'shared') {
        private = false;
      }
      await UriService.saveUri("");
    }
    
    if (!mounted) return;
    setState(() {
      isUriLoaded = true;
    });
  }

  Future<void> _initializeServices() async {
    CommunityService().retrieveCommunities();
  }

  Future<void> _initializeSecondaryServices() async {
    RealTimeUpdateService().initialize();

    if (!kIsWeb) {
      PermissionService.requestPermissions().then((value) {
        NotificationService().initialize();
        MediaAutoSelectService.checkEventsForPhotos();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MediaAutoSelectService.checkEventsForPhotos();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isUriLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = EventsPage(private: private, uri: uri);
        break;
      case 1:
        page = const GroupPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ),
        bottomNavigationBar: NavigationBar(
          height: 50,
          elevation: 0,
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_today, size: 30),
              label: 'My Agenda',
            ),
            NavigationDestination(
              icon: Icon(Icons.group, size: 30),
              label: 'Groups',
            ),
          ],
        ),
      );
    });
  }
}
