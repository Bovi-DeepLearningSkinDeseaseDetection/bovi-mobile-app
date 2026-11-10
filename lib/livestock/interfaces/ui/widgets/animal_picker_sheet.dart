import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';
import '../../acl/livestock_context_facade.dart';
import 'animal_form_sheet.dart';

/// Lets the user pick an animal: the most recent ones are listed first, so
/// one is chosen in two taps, or found by its ear tag (HU15, scenario 2).
Future<AnimalSummary?> showAnimalPicker(
  BuildContext context,
  LivestockContextFacade livestock,
) {
  return showModalBottomSheet<AnimalSummary>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    builder: (context) => _AnimalPicker(livestock: livestock),
  );
}

class _AnimalPicker extends StatefulWidget {
  final LivestockContextFacade livestock;

  const _AnimalPicker({required this.livestock});

  @override
  State<_AnimalPicker> createState() => _AnimalPickerState();
}

class _AnimalPickerState extends State<_AnimalPicker> {
  String _query = '';
  late Future<List<AnimalSummary>> _animals = widget.livestock.searchAnimals(
    '',
  );

  void _search(String query) {
    setState(() {
      _query = query;
      _animals = widget.livestock.searchAnimals(query);
    });
  }

  Future<void> _register() async {
    final animal = await showAnimalForm(
      context,
      widget.livestock,
      initialEarTag: _query.trim(),
    );
    if (animal != null && mounted) Navigator.of(context).pop(animal);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Seleccionar animal', style: textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  SearchBar(
                    hintText: 'Buscar por número de arete',
                    leading: const Icon(
                      Icons.search_rounded,
                      color: AppColors.secondaryText,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: _search,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AnimalSummary>>(
                future: _animals,
                builder: (context, snapshot) {
                  final animals = snapshot.data;
                  if (animals == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (animals.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _query.isEmpty
                            ? 'Aún no hay animales registrados.'
                            : 'Ningún animal tiene ese arete.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.bodyText,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: animals.length,
                    separatorBuilder: (_, _) => const Divider(indent: 76),
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return ListTile(
                        leading: const IconBubble(
                          icon: Icon(Icons.sell_outlined),
                          size: 44,
                        ),
                        title: Text('Arete ${animal.earTag}'),
                        subtitle: Text(animal.details),
                        onTap: () => Navigator.of(context).pop(animal),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: OutlinedButton.icon(
                  onPressed: _register,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Registrar animal nuevo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
