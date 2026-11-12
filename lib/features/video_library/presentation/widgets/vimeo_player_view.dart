import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';

/// Plays a Vimeo player URL inline (no external browser).
final class VimeoPlayerView extends StatefulWidget {
  const VimeoPlayerView({super.key, required this.playerUrl});

  /// Embeddable URL, e.g. `https://player.vimeo.com/video/123456789`.
  final String playerUrl;

  @override
  State<VimeoPlayerView> createState() => _VimeoPlayerViewState();
}

final class _VimeoPlayerViewState extends State<VimeoPlayerView> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController.fromPlatformCreationParams(_creationParams())
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.neutral1000)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              if (mounted) setState(() => _failed = true);
            }
          },
          // Keep the user inside the player — no navigating off to vimeo.com.
          onNavigationRequest: (request) =>
              request.url.startsWith('https://player.vimeo.com')
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
        ),
      );
    _load();
  }

  PlatformWebViewControllerCreationParams _creationParams() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    }
    return const PlatformWebViewControllerCreationParams();
  }

  void _load() {
    final uri = Uri.tryParse(widget.playerUrl);
    if (uri == null) {
      setState(() => _failed = true);
      return;
    }
    // Keep any existing params (private videos carry an `h` hash).
    final playerUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'autoplay': '1',
        'playsinline': '1',
        'title': '0',
        'byline': '0',
        'portrait': '0',
      },
    );
    _controller.loadRequest(playerUri);
  }

  void _retry() {
    setState(() {
      _failed = false;
      _loading = true;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.neutral1000,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_failed) WebViewWidget(controller: _controller),
          if (_loading && !_failed)
            const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          if (_failed)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.video_slash,
                    color: AppColors.neutral500,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.videoOpenFailed,
                    style: context.captionRegular.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _retry,
                    child: Text(
                      context.l10n.retry,
                      style: context.captionBold.copyWith(
                        color: AppColors.primary,
                      ),
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
