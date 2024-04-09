import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/main.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text("No favorites yet"),
      );
    }
    return Center(
        child: ListView(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have '
                '${appState.favorites.length} favorites:'),
          ),
          for (var fav in appState.favorites)
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(fav.asSnakeCase),
            )
        ]));
  }
}
