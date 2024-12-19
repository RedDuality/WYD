import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/view/events_page.dart';
import 'package:wyd_front/view/group_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final uriProvider = Provider.of<UriProvider>(context);

    String uri = uriProvider.uri;
    Widget page;
    bool private = true;
    if (uri.isNotEmpty) {
      String destination = uri.split('?').first.replaceAll('/', '');
      switch (destination) {
        case 'shared':
          private = false;
          break;
        default:
          break;
      }
      // Handle the shared link scenario
    }

    uriProvider.setUri("");

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
        body: Stack(
          children: [
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: NavigationBar(
                    height: 50,
                    elevation: 0,
                    selectedIndex: selectedIndex,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
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
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
