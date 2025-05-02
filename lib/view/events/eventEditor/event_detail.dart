import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/eventEditor/blob_provider.dart';
import 'package:wyd_front/state/eventEditor/detail_provider.dart';
import 'package:wyd_front/view/events/eventEditor/event_detail_editor.dart';
import 'package:wyd_front/view/events/eventEditor/gallery_editor.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  DetailProvider().close();
                  BlobProvider().close();
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
              titlePadding: EdgeInsets.zero,
              title: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(
                    left: 16.0, bottom: 8.0),
                child: Consumer<DetailProvider>(
                    builder: (context, provider, child) {
                  if (_titleController.text != provider.title) {
                    _titleController.text = provider.title;
                    _titleController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _titleController.text.length),
                    );
                  }
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
                    onChanged: (value) {
                      provider.updateTitle(_titleController.text);
                    },
                    onEditingComplete: () {
                      provider.updateTitle(_titleController.text,
                          finished: true);
                    },
                    onFieldSubmitted: (value) {
                      provider.updateTitle(_titleController.text,
                          finished: true);
                    },
                    onTapOutside: (event) {
                      provider.updateTitle(_titleController.text,
                          finished: true);
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
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: EventDetailEditor(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: GalleryEditor(),
            ),
          ),
        ],
      ),
    );
  }
}
