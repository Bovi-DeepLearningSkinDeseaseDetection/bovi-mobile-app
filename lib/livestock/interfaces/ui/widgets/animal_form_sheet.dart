import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/valueobjects/animal_sex.dart';
import '../../../domain/model/valueobjects/breed.dart';
import '../../../domain/model/valueobjects/ear_tag.dart';
import '../../acl/livestock_context_facade.dart';

/// Registers a new animal (HU15, scenario 1). Returns the registered animal,
/// or the existing one when its ear tag was taken and the user selected it
/// (scenario 4).
Future<AnimalSummary?> showAnimalForm(
  BuildContext context,
  LivestockContextFacade livestock, {
  String initialEarTag = '',
}) {
  return showModalBottomSheet<AnimalSummary>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    builder: (context) =>
        _AnimalForm(livestock: livestock, initialEarTag: initialEarTag),
  );
}

class _AnimalForm extends StatefulWidget {
  final LivestockContextFacade livestock;
  final String initialEarTag;

  const _AnimalForm({required this.livestock, required this.initialEarTag});

  @override
  State<_AnimalForm> createState() => _AnimalFormState();
}

class _AnimalFormState extends State<_AnimalForm> {
  final _formKey = GlobalKey<FormState>();
  late final _earTag = TextEditingController(text: widget.initialEarTag);
  final _otherBreed = TextEditingController();
  String _breed = Breed.common.first;
  AnimalSex _sex = AnimalSex.female;
  bool _isSaving = false;

  @override
  void dispose() {
    _earTag.dispose();
    _otherBreed.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final breed = _breed == Breed.other ? _otherBreed.text.trim() : _breed;
    try {
      final animal = await widget.livestock.registerAnimal(
        earTag: _earTag.text,
        breed: breed,
        sex: _sex,
      );
      if (mounted) Navigator.of(context).pop(animal);
    } on DuplicateAnimalException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final select = await _confirmExisting(error.existing);
      if (select && mounted) Navigator.of(context).pop(error.existing);
    }
  }

  Future<bool> _confirmExisting(AnimalSummary existing) async {
    final select = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arete ya registrado'),
        content: Text(
          'Ya existe el animal con arete ${existing.earTag} '
          '(${existing.details}). ¿Desea seleccionarlo?',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: const Text('Seleccionar'),
          ),
        ],
      ),
    );
    return select ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Padding(
      // Keeps the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Registrar animal', style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _earTag,
                autofocus: widget.initialEarTag.isEmpty,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Número de arete',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                validator: (text) =>
                    EarTag.validate(EarTag.normalize(text ?? '')),
              ),
              const SizedBox(height: 20),
              Text('Raza', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final breed in [...Breed.common, Breed.other])
                    ChoiceChip(
                      label: Text(breed),
                      selected: _breed == breed,
                      onSelected: (_) => setState(() => _breed = breed),
                    ),
                ],
              ),
              if (_breed == Breed.other) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherBreed,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Otra raza'),
                  validator: (text) =>
                      (text ?? '').trim().isEmpty ? 'Ingrese la raza.' : null,
                ),
              ],
              const SizedBox(height: 20),
              Text('Sexo', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<AnimalSex>(
                segments: [
                  for (final sex in AnimalSex.values)
                    ButtonSegment(value: sex, label: Text(sex.label)),
                ],
                selected: {_sex},
                onSelectionChanged: (selection) =>
                    setState(() => _sex = selection.first),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text('Guardar animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
