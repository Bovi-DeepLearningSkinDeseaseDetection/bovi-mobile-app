import 'package:flutter/material.dart';

import '../../../../clinical/interfaces/ui/widgets/help_frame.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/bovi_logo.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// Profile section: app information, help and settings.
class ProfilePage extends StatelessWidget {
  static const slogan = 'Tecnología para un ganado más saludable';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BoviLogo(size: 52),
                  const SizedBox(height: 16),
                  Text(
                    slogan,
                    style: TextTheme.of(
                      context,
                    ).bodyMedium?.copyWith(color: AppColors.bodyText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _ProfileTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Cómo tomar una buena foto',
                  subtitle: 'Guía de encuadre',
                  onTap: () => showFramingHelp(context),
                ),
                const Divider(indent: 76),
                _ProfileTile(
                  icon: Icons.settings_outlined,
                  title: 'Ajustes',
                  subtitle: 'Configuración',
                  onTap: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Los ajustes estarán disponibles próximamente.',
                        ),
                      ),
                    ),
                ),
                const Divider(indent: 76),
                _ProfileTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Acerca de Bovi',
                  subtitle: 'Información y licencias',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Bovi',
                    applicationIcon: const BoviIcon(size: 48),
                    applicationLegalese:
                        'Los resultados son preliminares y no reemplazan el '
                        'diagnóstico de un médico veterinario.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconBubble(icon: Icon(icon), size: 44),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondaryText,
      ),
      onTap: onTap,
    );
  }
}
