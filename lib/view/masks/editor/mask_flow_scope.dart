import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/view/masks/controllers/mask_range_controller.dart';
import 'package:wyd_front/view/masks/controllers/mask_view_orchestrator.dart';

// this class handles the orchestrator for masks views, that spaces across profile page(maskPreview) and masks page
class MaskFlowScope extends StatelessWidget {
  final Widget child;
  const MaskFlowScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Watch UserCache: if currentProfileId changes, this triggers
    final userCache = context.watch<UserCache>();
    final maskCache = context.read<MaskCache>();

    return ChangeNotifierProvider(
      // The key forces a total reset of the orchestrator if the profile changes
      key: ValueKey(userCache.getCurrentProfileId()),
      create: (context) {
        // initialize the mask orchestrator
        final orchestrator = MaskViewOrchestrator(
          maskCache: maskCache,
          maskController: MaskController(maskCache),
          rangeController: MaskRangeController(
            initialDate: DateTime.now(),
            numberOfDays: 7,
          ),
        );
        orchestrator.initialize();
        return orchestrator;
      },
      child: child,
    );
  }
}
