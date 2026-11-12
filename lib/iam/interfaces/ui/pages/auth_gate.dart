import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/bovi_logo.dart';
import '../viewmodels/session_view_model.dart';
import 'sign_in_page.dart';

/// Shows the app to a farmer with a session and the sign in otherwise.
///
/// The sign in and sign up screens live in their own navigator, so when the
/// session starts they all disappear at once and [child] takes their place.
class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final status = context.select<SessionViewModel, SessionStatus>(
      (session) => session.status,
    );
    return switch (status) {
      SessionStatus.loading => const _Splash(),
      SessionStatus.signedIn => child,
      SessionStatus.signedOut => Navigator(
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      ),
    };
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    // scaleDown: the logo never overflows a narrow screen.
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: FittedBox(fit: BoxFit.scaleDown, child: BoviLogo(size: 64)),
        ),
      ),
    );
  }
}
