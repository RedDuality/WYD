import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/eventEditor/event_view_provider.dart';
import 'package:wyd_front/view/events/eventEditor/event_view_editor.dart';
import 'package:wyd_front/view/events/eventEditor/gallery_editor.dart';

class EventView extends StatefulWidget {
  final String? eventHash;
  const EventView({super.key, this.eventHash});

  @override
  EventViewState createState() => EventViewState();
}

class EventViewState extends State<EventView> {
  final _titleController = TextEditingController();
  String? eventHash;

  @override
  void initState(){
    super.initState();
    eventHash = widget.eventHash;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  void onEventCreated(String eventHash){
    setState(() {
      this.eventHash = eventHash;
    });
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
                  EventViewProvider().close();
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
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Consumer<EventViewProvider>(builder: (context, provider, child) {
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
                      provider.updateTitle(_titleController.text, finished: true);
                    },
                    onFieldSubmitted: (value) {
                      provider.updateTitle(_titleController.text, finished: true);
                    },
                    onTapOutside: (event) {
                      provider.updateTitle(_titleController.text, finished: true);
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
              child: EventViewEditor(onEventCreated: onEventCreated,),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: eventHash != null ? GalleryEditor(eventHash: eventHash!) : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
