import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/controller/user_controller.dart';
import 'package:wyd_front/state/uri_provider.dart';
import 'package:wyd_front/view/agenda_page.dart';
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

  @override
  void initState() {
    super.initState();

    UserController().initUser(context);
  }


  @override
  Widget build(BuildContext context) {

    final uriProvider = Provider.of<UriProvider>(context);
    String uri = uriProvider.uri;
    //debugPrint("home $uri");

    int selectedIndex = 0;
    if (uri.isNotEmpty) {
      selectedIndex = 0;  // Handle the shared link scenario
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
        uri = "";
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
