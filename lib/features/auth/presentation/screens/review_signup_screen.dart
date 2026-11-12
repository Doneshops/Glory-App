import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/onboarding_navigation.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/review_signup_result.dart';
import '../cubits/review_signup/review_signup_cubit.dart';
import '../cubits/user_profile/user_profile_cubit.dart';
import 'package:glory_gym/core/l10n/l10n.dart';

/// Self-service sign-up (`POST /mobile/auth/review-signup`).
/// Only reachable while `/mobile/app-config` reports `signupEnabled: true`.
final class ReviewSignupScreen extends StatefulWidget {
  const ReviewSignupScreen({super.key});

  @override
  State<ReviewSignupScreen> createState() => _ReviewSignupScreenState();
}

final class _ReviewSignupScreenState extends State<ReviewSignupScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneFieldKey = GlobalKey<AppPhoneFieldState>();

  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  bool get _canSubmit =>
      _fullNameCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty;

  void _onSubmit(BuildContext context) {
    final l10n = context.l10n;
    final phone = _phoneCtrl.text.trim();

    setState(() {
      _fullNameError = AppValidators.required(l10n, _fullNameCtrl.text.trim());
      _emailError = AppValidators.email(l10n, _emailCtrl.text.trim());
      _phoneError = phone.isEmpty ? null : AppValidators.phone(l10n, phone);
      _passwordError = AppValidators.newPassword(l10n, _passwordCtrl.text);
      _confirmError = AppValidators.confirmPassword(
        l10n,
        _passwordCtrl.text,
      )(_confirmCtrl.text);
    });

    if (_fullNameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    context.read<ReviewSignupCubit>().signup(
          fullName: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirm: _confirmCtrl.text,
          phone: phone.isEmpty ? null : phone,
          phoneCountryCode: phone.isEmpty
              ? null
              : _phoneFieldKey.currentState?.countryCode.dialCode,
        );
  }

  void _onStateChanged(BuildContext context, ReviewSignupState state) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    if (state.status == ReviewSignupStatus.success) {
      final session = state.session;
      if (session != null) {
        context.read<UserProfileCubit>().setMember(session.member);
        unawaited(LocaleService.syncFromMember(session.member));
      }
      unawaited(context.read<UserProfileCubit>().fetchProfile());
      unawaited(
        navigateAfterAuthentication(
          context,
          onboardingCompleted: session?.member.onboardingCompleted,
        ),
      );
      return;
    }

    if (state.status != ReviewSignupStatus.failure) return;

    switch (state.errorKind) {
      case ReviewSignupErrorKind.alreadyExists:
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.signupAccountExists),
            action: SnackBarAction(
              label: l10n.signIn,
              onPressed: () => context.pop(),
            ),
          ),
        );
      case ReviewSignupErrorKind.disabled:
        // The switch is off — leave; the login screen re-reads the config.
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.signupUnavailable)),
        );
        context.pop();
      case ReviewSignupErrorKind.rateLimited:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.signupTryLater)),
        );
      case ReviewSignupErrorKind.invalid ||
            ReviewSignupErrorKind.other ||
            null:
        messenger.showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? l10n.errorTryAgain)),
        );
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => sl<ReviewSignupCubit>(),
      child: BlocListener<ReviewSignupCubit, ReviewSignupState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onStateChanged,
        child: AppScaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        32.vertical,
                        Text(
                          l10n.createAccount,
                          style: context.heading1,
                          textAlign: TextAlign.center,
                        ),
                        8.vertical,
                        Text(
                          l10n.signupSubtitle,
                          style: context.captionRegular.copyWith(
                            color: AppColors.neutral500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        24.vertical,
                        AppTextField(
                          label: l10n.fullName,
                          controller: _fullNameCtrl,
                          hint: l10n.enterFullName,
                          textInputAction: TextInputAction.next,
                          errorMessage: _fullNameError,
                          onChanged: (_) =>
                              setState(() => _fullNameError = null),
                        ),
                        16.vertical,
                        AppTextField(
                          label: l10n.email,
                          controller: _emailCtrl,
                          hint: l10n.enterYourEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          errorMessage: _emailError,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                        16.vertical,
                        AppPhoneField(
                          key: _phoneFieldKey,
                          label: l10n.phoneOptional,
                          controller: _phoneCtrl,
                          hint: l10n.enterYourPhone,
                          textInputAction: TextInputAction.next,
                          errorMessage: _phoneError,
                          onChanged: (_) => setState(() => _phoneError = null),
                        ),
                        16.vertical,
                        AppPasswordField(
                          label: l10n.password,
                          controller: _passwordCtrl,
                          hint: l10n.enterYourPassword,
                          textInputAction: TextInputAction.next,
                          errorMessage: _passwordError,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                        ),
                        16.vertical,
                        AppPasswordField(
                          label: l10n.confirmPassword,
                          controller: _confirmCtrl,
                          hint: l10n.reenterPassword,
                          textInputAction: TextInputAction.done,
                          errorMessage: _confirmError,
                          onChanged: (_) =>
                              setState(() => _confirmError = null),
                        ),
                        24.vertical,
                      ],
                    ),
                  ),
                ),
                BlocBuilder<ReviewSignupCubit, ReviewSignupState>(
                  builder: (context, state) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AlreadyHaveAccountRow(onLogin: () => context.pop()),
                        16.vertical,
                        AppButton(
                          label: l10n.createAccount,
                          isLoading: state.isLoading,
                          onPressed: _canSubmit && !state.isLoading
                              ? () => _onSubmit(context)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _AlreadyHaveAccountRow extends StatefulWidget {
  const _AlreadyHaveAccountRow({required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<_AlreadyHaveAccountRow> createState() => _AlreadyHaveAccountRowState();
}

final class _AlreadyHaveAccountRowState extends State<_AlreadyHaveAccountRow> {
  late final TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    _loginRecognizer = TapGestureRecognizer()..onTap = widget.onLogin;
  }

  @override
  void didUpdateWidget(_AlreadyHaveAccountRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loginRecognizer.onTap = widget.onLogin;
  }

  @override
  void dispose() {
    _loginRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: context.captionRegular.copyWith(color: AppColors.neutral400),
        children: [
          TextSpan(text: context.l10n.alreadyHaveAccountPrefix),
          TextSpan(
            text: context.l10n.signIn,
            recognizer: _loginRecognizer,
            style: context.subtitleMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
