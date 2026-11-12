import 'package:flutter/material.dart';

import '../../../../iam/interfaces/acl/iam_context_facade.dart';
import '../../../../shared/infrastructure/di/service_locator.dart';
import '../../../../shared/infrastructure/persistence/preferences/preferences_app.dart';
import '../../../application/internal/commandservices/history_restore_service.dart';
import '../pages/restore_history_page.dart';

/// After signing in on a phone without the farmer's data, offers to bring
/// the history back from the cloud (HU13, scenario 1). Asked once per
/// farmer: after "Ahora no" it stays in the profile.
class RestoreOffer extends StatefulWidget {
  final Widget child;

  const RestoreOffer({super.key, required this.child});

  @override
  State<RestoreOffer> createState() => _RestoreOfferState();
}

class _RestoreOfferState extends State<RestoreOffer> {
  @override
  void initState() {
    super.initState();
    if (locator.isRegistered<HistoryRestoreService>()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _offer());
    }
  }

  Future<void> _offer() async {
    final farmerId = await locator<IamContextFacade>().currentFarmerId();
    if (farmerId == null) return;
    final preferences = ApplicationPreferences();
    if (await preferences.hasDeclinedRestore(farmerId)) return;
    final count = await locator<HistoryRestoreService>().pendingToRestore();
    if (count == 0 || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => RestoreHistoryPage(
          cloudCount: count,
          onDecline: () => preferences.declineRestore(farmerId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
