import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../domain/entities/library_video_entity.dart';

final class LibraryVideoCard extends StatelessWidget {
  const LibraryVideoCard({super.key, required this.video, required this.onTap});

  final LibraryVideoEntity video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final category = video.category;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: _Thumbnail(video: video),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category != null) ...[
                      _CategoryPill(label: category),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      video.title(languageCode),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.captionBold.copyWith(
                        color: AppColors.neutral1000,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video});

  final LibraryVideoEntity video;

  @override
  Widget build(BuildContext context) {
    final thumbnail = video.thumbnailUrl;
    final duration = video.duration;
    final audienceLabel = switch (video.audience) {
      VideoAudience.male => context.l10n.videoAudienceMale,
      VideoAudience.female => context.l10n.videoAudienceFemale,
      VideoAudience.unknown => null,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnail != null)
          CachedNetworkImage(
            imageUrl: thumbnail,
            fit: BoxFit.cover,
            placeholder: (_, _) => const _ThumbnailPlaceholder(),
            errorWidget: (_, _, _) => const _ThumbnailPlaceholder(),
          )
        else
          const _ThumbnailPlaceholder(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0x8C000000)],
              stops: [0.45, 1],
            ),
          ),
        ),
        const Center(child: _PlayButton()),
        if (audienceLabel != null)
          PositionedDirectional(
            top: 8,
            start: 8,
            child: _OverlayChip(
              label: audienceLabel,
              background: AppColors.white.withValues(alpha: 0.92),
              foreground: AppColors.neutral1000,
            ),
          ),
        if (duration != null)
          PositionedDirectional(
            bottom: 8,
            end: 8,
            child: _OverlayChip(
              label: duration,
              background: AppColors.neutral1000.withValues(alpha: 0.65),
              foreground: AppColors.white,
            ),
          ),
      ],
    );
  }
}

final class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neutral800, AppColors.neutral1000],
        ),
      ),
      child: Center(
        child: Icon(Iconsax.video, color: AppColors.neutral600, size: 30),
      ),
    );
  }
}

final class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral1000.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: AppColors.neutral1000,
        size: 26,
      ),
    );
  }
}

final class _OverlayChip extends StatelessWidget {
  const _OverlayChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.footnoteSemiboldBold.copyWith(color: foreground),
      ),
    );
  }
}

final class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.footnoteSemiboldBold.copyWith(
          color: AppColors.primary900,
        ),
      ),
    );
  }
}
