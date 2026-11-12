import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/model/valueobjects/account_rules.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/auth_form_widgets.dart';
import 'sign_up_page.dart';

/// Sign in (HU14, scenarios 2 and 3).
class SignInPage extends StatefulWidget {
  static const title = 'Iniciar sesión';
  static const submitLabel = 'Ingresar';
  static const signUpLabel = 'Crear una cuenta';

  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<SessionViewModel>().signIn(
      _email.text,
      _password.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notice = context.select<SessionViewModel, String?>((s) => s.notice);
    return AuthFormScaffold(
      title: SignInPage.title,
      subtitle:
          'Ingrese una sola vez: después podrá usar Bovi sin internet hasta '
          '30 días.',
      children: [
        if (_error != null) ...[
          FormMessage(_error!),
          const SizedBox(height: 16),
        ] else if (notice != null) ...[
          FormMessage(notice, isError: false),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (text) => AccountRules.validateEmail(text ?? ''),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  onSubmitted: _submit,
                  validator: (text) =>
                      (text ?? '').isEmpty ? 'Ingrese su contraseña.' : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        BusyButton(
          label: SignInPage.submitLabel,
          icon: Icons.login_rounded,
          busy: _busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SignUpPage()),
                ),
          child: const Text(SignInPage.signUpLabel),
        ),
      ],
    );
  }
}
