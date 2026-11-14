import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Informed consent for the personal data (Ley N.° 29733, RNF7).
///
/// [version] must match CONSENT_VERSION of the backend, which stores it with
/// the date the farmer accepted it.
class ConsentText {
  ConsentText._();

  static const version = '2026.1';
  static const title = 'Consentimiento de tratamiento de datos';
  static const contactEmail = 'XXXX@XXXX';

  static const sections = <(String, String)>[
    (
      'Quién trata sus datos',
      'El equipo del proyecto Bovi (XXXX), un prototipo académico de '
          'detección preliminar de enfermedades de la piel del ganado.',
    ),
    (
      'Qué datos',
      'Su nombre, su correo y su contraseña (guardada cifrada, nadie puede '
          'leerla). También las evaluaciones que sincronice: fotos de la piel '
          'de sus animales, el resultado preliminar, la fecha y los datos del '
          'animal (arete, raza, sexo y zona de la lesión).',
    ),
    (
      'Para qué',
      'Para respaldar sus evaluaciones en la nube y recuperarlas si cambia de '
          'celular. No se venden ni se comparten con terceros, y no se usan '
          'para publicidad.',
    ),
    (
      'Dónde se guardan',
      'En servidores de Amazon Web Services en Ohio, Estados Unidos. Al '
          'aceptar, autoriza esta transferencia fuera del Perú. Toda la '
          'comunicación viaja cifrada.',
    ),
    (
      'Por cuánto tiempo',
      'Mientras su cuenta exista o hasta el final del proyecto.',
    ),
    (
      'Sus derechos',
      'Puede pedir el acceso, la corrección o la eliminación de sus datos, u '
          'oponerse a su tratamiento, escribiendo a los responsables del '
          'proyecto Bovi: ${ConsentText.contactEmail}',
    ),
    (
      'Importante',
      'El resultado de la app es preliminar y no reemplaza el diagnóstico de '
          'un médico veterinario.',
    ),
  ];
}

/// Shows the consent. Returns true when the farmer accepts it.
Future<bool> showConsentSheet(BuildContext context) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    builder: (context) {
      final textTheme = TextTheme.of(context);
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  Text(ConsentText.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Ley N.° 29733 · versión ${ConsentText.version}',
                    style: textTheme.bodySmall,
                  ),
                  for (final (heading, body) in ConsentText.sections) ...[
                    const SizedBox(height: 16),
                    Text(heading, style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Acepto'),
              ),
            ),
          ],
        ),
      );
    },
  );
  return accepted ?? false;
}
