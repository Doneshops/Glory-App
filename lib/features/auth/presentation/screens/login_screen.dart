import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/locale_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/onboarding_navigation.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubits/login/login_cubit.dart';
import '../cubits/user_profile/user_profile_cubit.dart';
import '../widgets/login_header.dart';
import '../widgets/login_terms_row.dart';
import 'package:glory_gym/core/l10n/l10n.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends State<LoginScreen>
    with WidgetsBindingObserver {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _termsAccepted = false;

  /// Server switch for the sign-up link — hidden until `/mobile/app-config`
  /// explicitly says `signupEnabled: true`.
  bool _signupEnabled = false;
  String? _identifierError;
  String? _passwordError;

  bool get _canLogin =>
      _identifierCtrl.text.isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _termsAccepted;

  void _onLoginPressed(BuildContext context) {
    setState(() {
      _identifierError =
          AppValidators.loginIdentifier(context.l10n, _identifierCtrl.text);
      _passwordError = AppValidators.password(context.l10n, _passwordCtrl.text);
    });

    if (_identifierError != null || _passwordError != null) return;

    context.read<LoginCubit>().login(
          identifier: _identifierCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSignupConfig();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSignupConfig();
  }

  Future<void> _refreshSignupConfig() async {
    final enabled = await sl<AuthRepository>().isSignupEnabled();
    if (mounted && enabled != _signupEnabled) {
      setState(() => _signupEnabled = enabled);
    }
  }

  Future<void> _openSignup(BuildContext context) async {
    await context.push(AppRoutes.reviewSignup);
    _refreshSignupConfig();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }

          if (state.status == LoginStatus.success) {
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
            context.read<LoginCubit>().reset();
          }
        },
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
                        const LoginHeader(),
                        24.vertical,
                        AppTextField(
                          label: context.l10n.loginIdentifier,
                          controller: _identifierCtrl,
                          hint: context.l10n.enterLoginIdentifier,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          errorMessage: _identifierError,
                          onChanged: (_) =>
                              setState(() => _identifierError = null),
                        ),
                        16.vertical,
                        AppPasswordField(
                          label: context.l10n.password,
                          controller: _passwordCtrl,
                          hint: context.l10n.enterYourPassword,
                          textInputAction: TextInputAction.done,
                          errorMessage: _passwordError,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                        ),
                        10.vertical,
                        LoginTermsRow(
                          accepted: _termsAccepted,
                          onToggle: () =>
                              setState(() => _termsAccepted = !_termsAccepted),
                        ),
                        // 10.vertical,
                        // _ForgotPasswordLink(
                        //   onTap: () => context.push(AppRoutes.forgotPassword),
                        // ),
                        16.vertical,
                        // AppDividerLabel(label: context.l10n.quickLoginWith),
                        // 16.vertical,
                        // AppSocialLoginRow(onApple: () {}, onGoogle: () {}),
                        24.vertical,
                      ],
                    ),
                  ),
                ),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => _BottomSection(
                    canLogin: _canLogin,
                    isLoading: state.isLoading,
                    onLogin: () => _onLoginPressed(context),
                    // The library is the guest home: return to it when it opened
                    // this screen, otherwise make it the new root.
                    onBrowseVideos: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.videoLibrary),
                    onCreateAccount:
                        _signupEnabled ? () => _openSignup(context) : null,
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

// ─── Private widgets ─────────────────────────────────────────────────────────

final class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          context.l10n.forgotPassword,
          style: context.captionRegular.copyWith(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

final class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.canLogin,
    required this.isLoading,
    required this.onLogin,
    required this.onBrowseVideos,
    this.onCreateAccount,
  });

  final bool canLogin;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onBrowseVideos;

  /// `null` hides the "Create account" link (sign-up switched off).
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final onCreateAccount = this.onCreateAccount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCreateAccount != null) ...[
            _CreateAccountRow(onTap: onCreateAccount),
            16.vertical,
          ],
          AppButton(
            label: context.l10n.login,
            isLoading: isLoading,
            onPressed: canLogin && !isLoading ? onLogin : null,
          ),
          16.vertical,
          AppDividerLabel(label: context.l10n.orLabel),
          16.vertical,
          _BrowseVideosTile(onTap: onBrowseVideos),
        ],
      ),
    );
  }
}

/// Guest entry point: lets visitors browse the public video library without
/// signing in.
final class _BrowseVideosTile extends StatelessWidget {
  const _BrowseVideosTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.video_play,
                  color: AppColors.primary800,
                  size: 22,
                ),
              ),
              12.horizontal,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.guestBrowseVideosTitle,
                      style: context.contentBold,
                    ),
                    2.vertical,
                    Text(
                      context.l10n.guestBrowseVideosSubtitle,
                      style: context.captionRegular.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isRtl ? Iconsax.arrow_left_2 : Iconsax.arrow_right_3,
                size: 18,
                color: AppColors.neutral500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _CreateAccountRow extends StatelessWidget {
  const _CreateAccountRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.dontHaveAccountPrefix,
          style: context.captionRegular.copyWith(color: AppColors.neutral400),
        ),
        4.horizontal,
        GestureDetector(
          onTap: onTap,
          child: Text(
            context.l10n.createAccount,
            style: context.subtitleMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
