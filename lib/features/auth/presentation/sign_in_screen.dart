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
import 'widgets/auth_text_field.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
      await repo.signInWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
      context.go(
        redirect != null && redirect.isNotEmpty ? redirect : '/',
      );
    } on AuthException catch (e) {
      setState(() => _error = mapAuthError(e));
    } catch (e) {
      setState(() => _error = mapAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!(FormValidators.email(_email.text) == null)) {
      setState(() => _error = FormValidators.email(_email.text));
      return;
    }
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.resetPassword(_email.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ArKwStrings.resetEmailSent)),
      );
    } on AuthException catch (e) {
      setState(() => _error = mapAuthError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      header: Text(
        ArKwStrings.welcomeBack,
        style: AppTypography.h4Bold.copyWith(color: AppColors.onPrimary),
        textAlign: TextAlign.center,
      ),
      topSubtitle: Text(
        ArKwStrings.signInSubtitle,
        style: AppTypography.body16.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.8)),
        textAlign: TextAlign.center,
      ),
      footer: Container(
        color: AppColors.sheet,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ArKwStrings.noAccount,
              style: AppTypography.body16.copyWith(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/auth/sign-up'),
              child: const Text(
                ArKwStrings.signUp,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.link,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ArKwStrings.welcome,
              style: AppTypography.h4Bold.copyWith(fontSize: 32),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ArKwStrings.signInSubtitle,
              style: AppTypography.body16.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthTextField(
              label: ArKwStrings.email,
              controller: _email,
              hint: ArKwStrings.emailHint,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: FormValidators.email,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              label: ArKwStrings.password,
              controller: _password,
              hint: ArKwStrings.passwordHint,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              autofillHints: const [AutofillHints.password],
              validator: FormValidators.password,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
              label: ArKwStrings.signIn,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _resetPassword,
              child: Text(
                ArKwStrings.forgotPassword,
                style: AppTypography.body16.copyWith(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _loading ? null : () => context.go('/'),
              child: Text(
                ArKwStrings.browseWithoutAccount,
                style: AppTypography.body16.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.link,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
