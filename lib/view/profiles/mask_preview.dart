import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/view/masks/mask_page.dart';
import 'package:wyd_front/view/masks/mask_range_controller.dart';
import 'package:wyd_front/view/masks/mask_tile.dart';
import 'package:wyd_front/view/masks/mask_view_orchestrator.dart';

class MaskPreview extends StatefulWidget {
  const MaskPreview({super.key});

  @override
  State<MaskPreview> createState() => _MaskPreviewState();
}

class _MaskPreviewState extends State<MaskPreview> {
  late final MaskViewOrchestrator _viewOrchestrator;
  final CalendarController<String> _calendarController = CalendarController<String>();
  late final ViewConfiguration _viewConfiguration;

  bool _isOrchestratorInitialized = false;

  @override
  void initState() {
    super.initState();

    _viewConfiguration = MultiDayViewConfiguration.week(
      initialHeightPerMinute: 0.34,
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 30),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isOrchestratorInitialized) {
      _initializeOrchestrator();
    }
  }

  void _initializeOrchestrator() {

    final maskCache = context.read<MaskCache>();

    final rangeController = MaskRangeController(
      _calendarController,
      initialDate: DateTime.now(),
      numberOfDays: 7,
    );

    _viewOrchestrator = MaskViewOrchestrator(
      maskCache: maskCache,
      maskController: MaskController(maskCache),
      rangeController: rangeController,
    );

    _viewOrchestrator.initialize();
    _isOrchestratorInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    const double buttonSpace = 160;
    const double maxCardWidth = 800;

    return ChangeNotifierProvider.value(
      value: _viewOrchestrator,
      child: LayoutBuilder(
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
                                eventsController: _viewOrchestrator.maskCntrl,
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
      ),
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
    final currentDate = _calendarController.visibleDateTimeRange.value;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaskPage(initialDate: currentDate?.start),
        ));
  }

  CalendarCallbacks<String> _getClickableCallbacks(BuildContext context) {
    void handleTap(dynamic _) => _goToEditor(context);
    return CalendarCallbacks(
      onTapped: handleTap,
      onEventTapped: (e, r) => handleTap(e),
      onLongPressed: handleTap,
    );
  }

  @override
  void dispose() {
    if (_isOrchestratorInitialized) {
      _viewOrchestrator.dispose();
    }
    _calendarController.dispose();
    super.dispose();
  }
}
