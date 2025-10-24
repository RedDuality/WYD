import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/state/event/current_events_provider.dart';
import 'package:wyd_front/view/events/eventEditor/event_view_editor.dart';
import 'package:wyd_front/view/events/eventEditor/gallery_editor.dart';

class EventView extends StatefulWidget {
  final String? eventHash;
  final bool confirmed;
  final DateTime? date;

  const EventView({
    super.key,
    this.eventHash,
    required this.confirmed,
    this.date,
  });

  @override
  EventViewState createState() => EventViewState();
}

class EventViewState extends State<EventView> {
  final _titleController = TextEditingController();
  String? eventHash;

  @override
  void initState() {
    super.initState();
    eventHash = widget.eventHash;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void onEventCreated(String eventHash) {
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
                child: Selector<CurrentEventsProvider, Event?>(
                  selector: (_, provider) => eventHash != null ? provider.get(eventHash!) : null,
                  builder: (context, event, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _titleController.text = event?.title ?? "Evento senza nome";
                      _titleController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _titleController.text.length),
                      );
                    });

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
                    );
                  },
                ),
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
              child: Selector<CurrentEventsProvider, Event?>(
                selector: (_, provider) => eventHash != null ? provider.get(eventHash!) : null,
                builder: (context, event, child) {
                  return EventViewEditor(
                    event: event,
                    confirmed: widget.confirmed,
                    date: widget.date,
                    titleController: _titleController,
                    onEventCreated: onEventCreated,
                  );
                },
              ),
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
