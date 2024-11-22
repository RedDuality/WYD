import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/view/agenda_page.dart';
import 'package:wyd_front/view/events_page.dart';
import 'package:wyd_front/widget/add_event_button.dart';

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

    if (uri.isNotEmpty) {
      String destination = uri.split('?').first.replaceAll('/', '');
      switch (destination) {
        case 'shared':
          selectedIndex = 1;
          break;
        default:
          selectedIndex = 0;
      }
      // Handle the shared link scenario
    }

    uriProvider.setUri("");


    Widget page;

    switch (selectedIndex) {
      case 0:
        page = const AgendaPage();
        break;
      case 1:
        page = EventsPage(uri: uri);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                selectedIndex: selectedIndex,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.event_available),
                    label: Text('My New Agenda'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event),
                    label: Text('New Shared'),
                  ),
                ],
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
        floatingActionButton: const AddEventButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }
}
