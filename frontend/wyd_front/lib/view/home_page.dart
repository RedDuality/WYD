import 'package:flutter/material.dart';
import 'package:wyd_front/controller/user_controller.dart';
import 'package:wyd_front/view/agenda_page.dart';
import 'package:wyd_front/widget/add_event_button.dart';

import 'events_page.dart';
import 'favorites_page.dart';
import 'generator_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    UserController().initUser(context);
  }


  @override
  Widget build(BuildContext context) {
    debugPrint(widget.initialIndex.toString());
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
        page = const EventsPage();
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
