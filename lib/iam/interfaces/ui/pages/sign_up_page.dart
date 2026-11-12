import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/commands/sign_up_command.dart';
import '../../../domain/model/valueobjects/account_rules.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/auth_form_widgets.dart';
import '../widgets/consent_sheet.dart';

/// Account of the farmer, with the data consent (HU14 scenario 1, RNF7).
class SignUpPage extends StatefulWidget {
  static const title = 'Crear cuenta';
  static const submitLabel = 'Crear cuenta';
  static const consentMissing =
      'Para crear su cuenta debe aceptar el consentimiento de datos.';

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _consent = false;
  bool _consentError = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _readConsent() async {
    final accepted = await showConsentSheet(context);
    if (accepted && mounted) {
      setState(() {
        _consent = true;
        _consentError = false;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState!.validate();
    setState(() => _consentError = !_consent);
    if (!formValid || !_consent) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<SessionViewModel>().signUp(
      SignUpCommand(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        consentAccepted: _consent,
      ),
    );
    // Without error the gate already replaced the sign in screens by the app.
    if (!mounted || error == null) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return AuthFormScaffold(
      showBack: true,
      title: SignUpPage.title,
      subtitle:
          'Sus evaluaciones quedarán asociadas a usted y respaldadas en '
          'la nube.',
      children: [
        if (_error != null) ...[
          FormMessage(_error!),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (text) => AccountRules.validateName(text ?? ''),
                ),
                const SizedBox(height: 16),
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
                  helperText: 'Al menos 8 caracteres, con letras y números.',
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  validator: (text) =>
                      AccountRules.validateNewPassword(text ?? ''),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirm,
                  label: 'Repita la contraseña',
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: _submit,
                  validator: (text) => text != _password.text
                      ? 'Las contraseñas no coinciden.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ConsentTile(
          accepted: _consent,
          showError: _consentError,
          onChanged: (value) => setState(() {
            _consent = value;
            if (value) _consentError = false;
          }),
          onRead: _readConsent,
          textTheme: textTheme,
        ),
        const SizedBox(height: 24),
        BusyButton(
          label: SignUpPage.submitLabel,
          icon: Icons.person_add_alt_1_rounded,
          busy: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final bool accepted;
  final bool showError;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRead;
  final TextTheme textTheme;

  const _ConsentTile({
    required this.accepted,
    required this.showError,
    required this.onChanged,
    required this.onRead,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: accepted,
              onChanged: (value) => onChanged(value ?? false),
              isError: showError,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text.rich(
                  TextSpan(
                    style: textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Acepto el '),
                      TextSpan(
                        text: 'consentimiento de tratamiento de datos',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = onRead,
                      ),
                      const TextSpan(text: ' (Ley N.° 29733).'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              SignUpPage.consentMissing,
              style: textTheme.bodySmall?.copyWith(color: AppColors.lesionText),
            ),
          ),
      ],
    );
  }
}
