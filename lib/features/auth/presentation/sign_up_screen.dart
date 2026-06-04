import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/validation/auth_error_mapper.dart';
import '../../../core/validation/form_validators.dart';
import 'auth_providers.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_scaffold.dart';
import '../../../shared/widgets/legal_links.dart';
import 'widgets/auth_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;
  bool _loading = false;
  String? _error;
  String? _termsError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final termsErr = FormValidators.termsAccepted(_agreed);
    setState(() => _termsError = termsErr);
    if (!(_formKey.currentState?.validate() ?? false) || termsErr != null) {
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      setState(() => _error = ArKwStrings.supabaseNotConfigured);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _email.text.trim();
      await repo.signUpWithEmail(
        email: email,
        password: _password.text,
        displayName: _name.text.trim(),
      );
      final session = repo.currentSession;
      if (!mounted) return;
      if (session != null) {
        context.go('/subscription');
      } else {
        context.push('/auth/otp', extra: email);
      }
    } on AuthException catch (e) {
      setState(() => _error = mapAuthError(e));
    } catch (e) {
      setState(() => _error = mapAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      header: Text(
        ArKwStrings.createAccount,
        style: AppTypography.h4Bold.copyWith(color: AppColors.onPrimary),
        textAlign: TextAlign.start,
      ),
      topSubtitle: Text(
        ArKwStrings.signUpSubtitle,
        style: AppTypography.body16.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.8)),
      ),
      footer: Container(
        color: AppColors.sheet,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: AuthPrimaryButton(
          label: ArKwStrings.continueBtn,
          loading: _loading,
          onPressed: _submit,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              label: ArKwStrings.fullName,
              controller: _name,
              hint: ArKwStrings.fullNameHint,
              autofillHints: const [AutofillHints.name],
              validator: (v) => FormValidators.required(v, fieldLabel: ArKwStrings.fullName),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              label: ArKwStrings.email,
              controller: _email,
              hint: ArKwStrings.emailHint,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: FormValidators.email,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              label: ArKwStrings.password,
              controller: _password,
              hint: ArKwStrings.passwordHint,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              validator: FormValidators.passwordSignUp,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() {
                      _agreed = v ?? false;
                      _termsError = null;
                    }),
                    activeColor: AppColors.link,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: SignUpLegalText()),
              ],
            ),
            if (_termsError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(_termsError!, style: const TextStyle(color: AppColors.error)),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
          ],
        ),
      ),
    );
  }
}
