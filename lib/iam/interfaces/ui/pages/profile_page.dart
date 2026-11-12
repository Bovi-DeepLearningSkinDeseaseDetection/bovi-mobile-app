import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../clinical/interfaces/ui/pages/restore_history_page.dart';
import '../../../../clinical/interfaces/ui/widgets/help_frame.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/bovi_logo.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';
import '../../../domain/model/aggregates/auth_session.dart';
import '../viewmodels/session_view_model.dart';

/// Profile section: the farmer's account, help, settings and sign out.
class ProfilePage extends StatelessWidget {
  static const slogan = 'Tecnología para un ganado más saludable';

  const ProfilePage({super.key});

  static const signOutLabel = 'Cerrar sesión';

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Sus evaluaciones se quedan en este celular. Para volver a usar Bovi '
          'necesitará internet para iniciar sesión.',
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
            child: const Text(signOutLabel),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await context.read<SessionViewModel>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final farmer = context.select<SessionViewModel, Farmer?>((s) => s.farmer);
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
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: BoviLogo(size: 52),
                  ),
                  const SizedBox(height: 16),
                  if (farmer != null) ...[
                    Text(farmer.name, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      farmer.email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.bodyText,
                      ),
                    ),
                  ] else
                    Text(
                      slogan,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.bodyText,
                      ),
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
          if (farmer != null) ...[
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: _ProfileTile(
                icon: Icons.cloud_download_outlined,
                title: RestoreHistoryPage.title,
                subtitle: 'Recuperar sus evaluaciones de la nube',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => const RestoreHistoryPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const IconBubble(
                  icon: Icon(Icons.logout_rounded),
                  size: 44,
                ),
                title: const Text(signOutLabel),
                subtitle: const Text(
                  'Sus evaluaciones se quedan en el celular',
                ),
                onTap: () => _confirmSignOut(context),
              ),
            ),
          ],
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
