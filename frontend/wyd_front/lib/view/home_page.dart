import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/controller/user_controller.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/view/agenda_page.dart';
import 'package:wyd_front/view/test_private_page.dart';
import 'package:wyd_front/view/test_shared_page.dart';
import 'package:wyd_front/widget/add_event_button.dart';

import 'events_page.dart';
import 'favorites_page.dart';
import 'generator_page.dart';

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
    UserController().initUser(context);
  }


  @override
  Widget build(BuildContext context) {

    final uriProvider = Provider.of<UriProvider>(context);
    String uri = uriProvider.uri;
    uriProvider.setUri('');

   

    if (uri.isNotEmpty) {
      selectedIndex = 1;  // Handle the shared link scenario
    }

    Widget page;  

    switch (selectedIndex + 2) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
        break;
      case 2:
        page = const AgendaPage();
        break;
      case 3:
        page = EventsPage(uri: uri);
        break;
      case 4:
        page = const TestPrivatePage();
        break;
      case 5:
        page = const TestSharedPage();
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
                  /*
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Generator'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),*/
                  NavigationRailDestination(
                    icon: Icon(Icons.event_available),
                    label: Text('My Agenda'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event),
                    label: Text('Shared Events'),
                  ),
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
