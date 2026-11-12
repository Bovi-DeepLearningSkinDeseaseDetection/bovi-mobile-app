import 'package:flutter/material.dart';

import '../../../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../../../../../livestock/interfaces/ui/widgets/animal_picker_sheet.dart';
import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../../shared/infrastructure/di/service_locator.dart';
import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/icon_bubble.dart';
import '../../../../application/internal/commandservices/evaluation_command_service.dart';
import '../../../../domain/exceptions/evaluation_already_synced_exception.dart';
import '../../../../domain/model/aggregates/evaluation.dart';
import 'body_zone_picker.dart';

/// Animal and body zone of a saved evaluation (HU15). Choosing them is
/// optional, so it never adds taps before the result (RNF3).
class EvaluationAnimalSection extends StatefulWidget {
  static const title = 'Animal evaluado';
  static const assignLabel = 'Asignar animal';
  static const lockedText =
      'Respaldada en la nube: el animal y la zona ya no se pueden cambiar.';

  /// The saved evaluation; null while it is still being saved.
  final Evaluation? evaluation;

  const EvaluationAnimalSection({super.key, required this.evaluation});

  /// Whether the services to assign an animal are available.
  static bool get isAvailable =>
      locator.isRegistered<LivestockContextFacade>() &&
      locator.isRegistered<EvaluationCommandService>();

  @override
  State<EvaluationAnimalSection> createState() =>
      _EvaluationAnimalSectionState();
}

class _EvaluationAnimalSectionState extends State<EvaluationAnimalSection> {
  late Evaluation? _evaluation = widget.evaluation;
  Future<AnimalSummary?>? _animal;
  bool _isSaving = false;

  LivestockContextFacade get _livestock => locator<LivestockContextFacade>();

  @override
  void initState() {
    super.initState();
    _loadAnimal();
  }

  @override
  void didUpdateWidget(EvaluationAnimalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.evaluation != oldWidget.evaluation) {
      _evaluation = widget.evaluation;
      _loadAnimal();
    }
  }

  void _loadAnimal() {
    final animalId = _evaluation?.animalId;
    _animal = animalId == null ? null : _livestock.animalById(animalId);
  }

  // Animal first (scenarios 1 and 2), then the body zone (scenario 3).
  Future<void> _assign() async {
    final evaluation = _evaluation;
    if (evaluation == null) return;
    final animal = await showAnimalPicker(context, _livestock);
    if (animal == null || !mounted) return;
    final zone = await showBodyZonePicker(
      context,
      selected: evaluation.bodyZone,
    );
    if (zone == null || !mounted) return;
    setState(() => _isSaving = true);
    try {
      final updated = await locator<EvaluationCommandService>().assignAnimal(
        evaluation,
        animalId: animal.id,
        animalEarTag: animal.earTag,
        bodyZone: zone,
      );
      if (!mounted) return;
      setState(() {
        _evaluation = updated;
        _animal = Future.value(animal);
      });
    } on EvaluationAlreadySyncedException {
      // It was synced in the background while this screen was open.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(EvaluationAlreadySyncedException.message),
          ),
        );
      }
    } catch (error) {
      debugPrint('Assigning the animal failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo asignar el animal.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final evaluation = _evaluation;
    final textTheme = TextTheme.of(context);
    final assigned = evaluation?.animalId != null;
    final locked = evaluation?.syncStatus == SyncStatus.synced;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IconBubble(icon: Icon(Icons.sell_outlined), size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EvaluationAnimalSection.title,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      if (assigned)
                        _AssignedAnimal(
                          earTag: evaluation!.animalEarTag ?? '',
                          zone: evaluation.bodyZone?.label,
                          animal: _animal,
                        )
                      else
                        Text(
                          locked
                              ? 'Sin animal asignado.'
                              : 'Opcional: indique a qué animal pertenece '
                                    'la foto.',
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (locked)
              Text(
                EvaluationAnimalSection.lockedText,
                style: textTheme.bodySmall,
              )
            else
              OutlinedButton.icon(
                onPressed: evaluation == null || _isSaving ? null : _assign,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(assigned ? Icons.edit_outlined : Icons.add_rounded),
                label: Text(
                  assigned
                      ? 'Cambiar animal'
                      : EvaluationAnimalSection.assignLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssignedAnimal extends StatelessWidget {
  final String earTag;
  final String? zone;
  final Future<AnimalSummary?>? animal;

  const _AssignedAnimal({
    required this.earTag,
    required this.zone,
    required this.animal,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AnimalSummary?>(
      future: animal,
      builder: (context, snapshot) {
        final details = snapshot.data?.details;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arete $earTag${details == null ? '' : ' · $details'}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            if (zone != null)
              Text(
                'Zona: $zone',
                style: const TextStyle(fontSize: 13, color: AppColors.bodyText),
              ),
          ],
        );
      },
    );
  }
}
