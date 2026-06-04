import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final codeError = FormValidators.otpCode(_code);
    if (codeError != null) {
      setState(() => _error = codeError);
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
      await repo.verifyEmailOtp(email: widget.email, token: _code);
      if (mounted) context.go('/subscription');
    } on AuthException catch (e) {
      setState(() => _error = mapAuthError(e));
    } catch (e) {
      setState(() => _error = mapAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.resendEmailOtp(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ArKwStrings.codeResent)),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = mapAuthError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      header: Text(
        ArKwStrings.otpTitle,
        style: AppTypography.h4Bold.copyWith(fontSize: 22),
      ),
      topSubtitle: Text(
        ArKwStrings.otpSubtitle(widget.email),
        style: AppTypography.body16.copyWith(color: AppColors.muted),
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
        child: AuthPrimaryButton(
          label: ArKwStrings.verify,
          loading: _loading,
          onPressed: _verify,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => _error = null);
                    if (v.isNotEmpty && i < 5) {
                      _focusNodes[i + 1].requestFocus();
                    }
                    if (v.isEmpty && i > 0) {
                      _focusNodes[i - 1].requestFocus();
                    }
                    if (_code.length == 6) {
                      _verify();
                    }
                  },
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: _resend,
            child: Text(
              ArKwStrings.resendCode,
              style: TextStyle(color: AppColors.link),
            ),
          ),
        ],
      ),
    );
  }
}
