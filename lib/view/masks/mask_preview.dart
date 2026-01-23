import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/view/masks/mask_page.dart';
import 'package:wyd_front/view/masks/tiles/mask_tile.dart';
import 'package:wyd_front/view/masks/controllers/mask_view_orchestrator.dart';

class MaskPreview extends StatefulWidget {
  const MaskPreview({super.key});

  @override
  State<MaskPreview> createState() => _MaskPreviewState();
}

class _MaskPreviewState extends State<MaskPreview> {
  late final ViewConfiguration _viewConfiguration;

  late final CalendarController<String> _calendarController;
  late MaskViewOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();
    _orchestrator = context.read<MaskViewOrchestrator>();

    _calendarController = CalendarController<String>();

    _viewConfiguration = MultiDayViewConfiguration.week(
      initialHeightPerMinute: 0.34,
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 30),
    );

    // library-called date change(e.g. swipe)
    _calendarController.visibleDateTimeRange.addListener(_handleUiRangeChange);
  }

  void _handleUiRangeChange() {
    final range = _calendarController.visibleDateTimeRange.value;
    if (range != null) {
      _orchestrator.rangeCntrl.setRange(range);
    }
  }

  @override
  void dispose() {
    _calendarController.visibleDateTimeRange.removeListener(_handleUiRangeChange);
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orchestrator = context.watch<MaskViewOrchestrator>();

    const double buttonSpace = 160;
    const double maxCardWidth = 800;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showButtons = constraints.maxWidth >= (maxCardWidth + buttonSpace);

        return SizedBox(
          height: 400,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showButtons)
                _buildNavButton(
                  context: context,
                  icon: Icons.chevron_left,
                  onPressed: () => _calendarController.animateToPreviousPage(),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxCardWidth),
                child: Container(
                  width: showButtons ? maxCardWidth : constraints.maxWidth,
                  padding: EdgeInsets.symmetric(horizontal: showButtons ? 10 : 0),
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () => _goToEditor(context),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CalendarView<String>(
                              eventsController: orchestrator.maskCntrl,
                              calendarController: _calendarController,
                              viewConfiguration: _viewConfiguration,
                              callbacks: _getClickableCallbacks(context),
                              header: CalendarHeader<String>(),
                              body: CalendarBody<String>(
                                interaction: CalendarInteraction(
                                  allowResizing: false,
                                  allowRescheduling: false,
                                  allowEventCreation: false,
                                ),
                                multiDayTileComponents: TileComponents<String>(
                                  tileBuilder: (event, tileRange) {
                                    return MaskTile(event: event);
                                  },
                                  tileWhenDraggingBuilder: (event) => const SizedBox.shrink(),
                                  feedbackTileBuilder: (event, size) => const SizedBox.shrink(),
                                  dropTargetTile: (event) => const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                              child: const Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (showButtons)
                _buildNavButton(
                  context: context,
                  icon: Icons.chevron_right,
                  onPressed: () => _calendarController.animateToNextPage(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavButton({required BuildContext context, required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IconButton.filledTonal(
        iconSize: 38,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          hoverColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          padding: const EdgeInsets.all(12),
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  void _goToEditor(BuildContext context) {
    final orchestrator = context.read<MaskViewOrchestrator>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: orchestrator,
          child: const MaskPage(),
        ),
      ),
    );
  }

  CalendarCallbacks<String> _getClickableCallbacks(BuildContext context) {
    void handleTap(dynamic _) => _goToEditor(context);
    return CalendarCallbacks(
      onTapped: handleTap,
      onEventTapped: (e, r) => handleTap(e),
      onLongPressed: handleTap,
    );
  }
}
