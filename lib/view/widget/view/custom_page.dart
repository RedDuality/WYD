import 'package:flutter/material.dart';

void showCustomPage(BuildContext context, Widget child, {String? title}) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => CustomPage(title: title, child: child)),
  );
}

class CustomPage extends StatelessWidget {
  final Widget child;
  final bool appBar;
  final String? title;
  const CustomPage(
      {super.key, this.appBar = true, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar
          ? AppBar(
              title: Text(title ?? ''),
            )
          : null,
      body: Center(child: child),
    );
  }
}
