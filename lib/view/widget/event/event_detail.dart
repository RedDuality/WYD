import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/detail_provider.dart';
import 'package:wyd_front/view/widget/event/event_detail_editor.dart';
import 'package:wyd_front/view/widget/event/image_detail.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({super.key});

  @override
  EventDetailState createState() => EventDetailState();
}

class EventDetailState extends State<EventDetail> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _updateTitle(DetailProvider provider) {
    provider.updateTitle(_titleController.text);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          leading: Container(
            padding: EdgeInsets.zero,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Icon(
                Icons.close,
                size: 36,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero, // Remove default padding
            title: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(
                  left: 16.0, bottom: 8.0), // Adjust left and bottom padding
              child:
                  Consumer<DetailProvider>(builder: (context, provider, child) {
                _titleController.text = provider.title;
                return TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '',
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                  onEditingComplete: () {
                    _updateTitle(provider);
                  },
                  onFieldSubmitted: (value) {
                    _updateTitle(provider);
                  },
                  onTapOutside: (event) {
                    _updateTitle(provider);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                );
              }),
            ),
            background: Image.asset(
              'assets/images/logoimage.png',
              fit: BoxFit.cover,
            ),
          ),
          backgroundColor: Colors.blue,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: EventDetailEditor(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ImageDetail(),
          ),
        ),
      ],
    );
  }
}
