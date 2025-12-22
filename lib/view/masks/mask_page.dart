import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/view/masks/editor/mask_editor.dart';
import 'package:wyd_front/view/masks/mask_range_controller.dart';
import 'package:wyd_front/view/masks/mask_tile.dart';
import 'package:wyd_front/view/masks/mask_view_orchestrator.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/util/add_button.dart';
import '../../model/util/iterable_extension.dart';

class MaskPage extends StatefulWidget {
  final DateTime? initialDate;

  const MaskPage({super.key, this.initialDate});

  @override
  State<MaskPage> createState() => _MaskPageState();
}

class _MaskPageState extends State<MaskPage> {
  late final MaskViewOrchestrator _viewOrchestrator;

  late final CalendarController<String> _calendarController;
  late final ViewConfiguration _viewConfiguration;

  bool _isOrchestratorInitialized = false;

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController<String>();

    _viewConfiguration = MultiDayViewConfiguration.week(
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 0),
      displayRange: DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime.now().add(Duration(days: 30 * 365)),
      ),
    );

    final rangeController = MaskRangeController(
      _calendarController,
      initialDate: widget.initialDate ?? DateTime.now(),
      numberOfDays: 7,
    );

    _viewOrchestrator = MaskViewOrchestrator(
      maskCache: context.read<MaskCache>(),
      maskController: MaskController(),
      rangeController: rangeController,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isOrchestratorInitialized) {
      // This runs after initState but BEFORE the first build
      _viewOrchestrator.initialize();
      _isOrchestratorInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewOrchestrator,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mask Editor'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _calendarController.animateToPreviousPage(),
              tooltip: 'Previous Week',
            ),
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () => _calendarController.jumpToDate(DateTime.now().add(Duration(days: 20))),
              tooltip: 'Today',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _calendarController.animateToNextPage(),
              tooltip: 'Next Week',
            ),
            const SizedBox(width: 8), // Padding
          ],
        ),
        body: Consumer<MaskViewOrchestrator>(
          builder: (context, orchestrator, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CalendarView<String>(
                calendarController: _calendarController,
                eventsController: orchestrator.maskCntrl,
                viewConfiguration: _viewConfiguration,
                components: _getCustomComponents(),
                callbacks: CalendarCallbacks<String>(
                  onEventTapped: _handleEventTapped,
                ),
                header: CalendarHeader<String>(),
                body: CalendarBody<String>(
                  multiDayTileComponents: TileComponents<String>(
                    tileBuilder: (event, tileRange) {
                      return MaskTile(event: event);
                    },
                    tileWhenDraggingBuilder: (event) {
                      return MaskTile(
                        event: event,
                        opacity: 0.5,
                      );
                    },
                    feedbackTileBuilder: (event, size) {
                      return MaskTile(event: event);
                    },
                    dropTargetTile: (event) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: AddButton(text: 'Add Mask', child: MaskEditor()),
      ),
    );
  } // build

  // --- Helper Methods ---

  CalendarComponents<String> _getCustomComponents() {
    return CalendarComponents(
      multiDayComponentStyles: MultiDayComponentStyles(
        bodyStyles: MultiDayBodyComponentStyles(
          timelineStyle: TimelineStyle(
            textPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 70), // hide the half and quarter hours
          ),
        ),
      ),
    );
  }

  void _handleEventTapped(CalendarEvent<String> event, RenderBox renderBox) {
    final maskCache = Provider.of<MaskCache>(context, listen: false);
    final maskId = event.data;
    final mask = maskCache.allMasks.firstWhereOrNull((m) => m.id == maskId);

    if (mask != null) {
      showCustomDialog(context, MaskEditor(originalMask: mask));
    }
  }

  @override
  void dispose() {
    _viewOrchestrator.dispose();
    _calendarController.dispose();
    super.dispose();
  }
}
