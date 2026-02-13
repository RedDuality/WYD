import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_cache.dart';
import 'package:wyd_front/view/events/eventEditor/event_view_editor.dart';
import 'package:wyd_front/view/events/eventEditor/gallery_editor.dart';
import 'package:wyd_front/view/events/eventEditor/title_editor.dart';
import 'package:wyd_front/view/widget/button/exit_button.dart';

class EventView extends StatefulWidget {
  final String? eventId;
  final DateTime? date;

  const EventView({
    super.key,
    this.eventId,
    this.date,
  });

  @override
  EventViewState createState() => EventViewState();
}

class EventViewState extends State<EventView> {
  final _titleController = TextEditingController();
  String? eventId;

  @override
  void initState() {
    super.initState();

    eventId = widget.eventId;

    final event = eventId != null ? context.read<EventsCache>().get(eventId!) : null;

    final newTitle = event?.title ?? "Evento senza nome";
    _titleController.text = newTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void onEventCreated(String eventId) {
    setState(() {
      this.eventId = eventId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileEventCache = Provider.of<DetailedProfileEventsCache>(context, listen: false);
    final showImages = eventId != null && profileEventCache.atLeastOneConfirmed(eventId!);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: Container(padding: EdgeInsets.zero),
            actions: [ExitButton()],
            flexibleSpace: _titleManager(),
            backgroundColor: Colors.blue,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: EventViewEditor(
                eventId: eventId,
                date: widget.date,
                titleController: _titleController,
                onEventCreated: onEventCreated,
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: showImages
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                      child: GalleryEditor(eventId: eventId!),
                    )
                  : Container()),
        ],
      ),
    );
  }

  Widget _titleManager() {
    return FlexibleSpaceBar(
      titlePadding: EdgeInsets.zero,
      title: Builder(builder: (context) {
        final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        final isCollapsed = (settings?.minExtent == settings?.currentExtent);

        return TitleEditor(
          controller: _titleController,
          isCollapsed: isCollapsed,
        );
      }),
      background: Image.asset(
        'assets/images/logoimage.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
