import 'package:flutter/material.dart';
import 'package:wyd_front/service/util/app_lifecycle_service.dart';
import 'package:wyd_front/view/events/events_page.dart';
import 'package:wyd_front/view/groups/group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    AppLifecycleService().attach();
  }

  @override
  void dispose() {
    AppLifecycleService().detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: _selectedPage(),
        ),
        bottomNavigationBar: _navigationBar(),
      );
    });
  }

  Widget _selectedPage() {
    switch (selectedIndex) {
      case 0:
        return const EventsPage();
      case 1:
        return const GroupPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
  }

  Widget _navigationBar() {
    return NavigationBar(
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
    );
  }
}
