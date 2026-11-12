import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/library_video_entity.dart';
import '../cubits/video_library/video_library_cubit.dart';
import '../utils/video_category_label.dart';
import '../widgets/library_video_card.dart';
import '../widgets/video_filter_sheet.dart';

/// Public video library — the guest home, with a login action in the app bar.
final class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VideoLibraryCubit>()..init(),
      child: const _VideoLibraryView(),
    );
  }
}

final class _VideoLibraryView extends StatefulWidget {
  const _VideoLibraryView();

  @override
  State<_VideoLibraryView> createState() => _VideoLibraryViewState();
}

final class _VideoLibraryViewState extends State<_VideoLibraryView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<VideoLibraryCubit>().loadMore();
    }
  }

  void _openVideo(LibraryVideoEntity video) {
    context.push(AppRoutes.videoPlayer, extra: video);
  }

  Future<void> _openFilters() async {
    final cubit = context.read<VideoLibraryCubit>();
    final filters = await VideoFilterSheet.show(
      context,
      categories: cubit.state.categories,
      initial: (
        audience: cubit.state.audience,
        category: cubit.state.selectedCategory,
      ),
    );
    if (filters == null) return;
    cubit.applyFilters(audience: filters.audience, category: filters.category);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: _LibraryAppBar(onLogin: () => context.push(AppRoutes.login)),
      body: BlocConsumer<VideoLibraryCubit, VideoLibraryState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null &&
            current.videos.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) {
          final cubit = context.read<VideoLibraryCubit>();

          final scrollView = CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (defaultTargetPlatform == TargetPlatform.iOS)
                CupertinoSliverRefreshControl(
                  onRefresh: () => cubit.load(refresh: true),
                ),
              SliverToBoxAdapter(
                child: _Hero(
                  onSearch: cubit.search,
                  onFilter: _openFilters,
                  activeFilterCount: state.activeFilterCount,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _FiltersHeaderDelegate(
                  state: state,
                  onAudienceSelected: cubit.selectAudience,
                  onCategorySelected: cubit.selectCategory,
                ),
              ),
              ..._buildContent(context, state),
            ],
          );

          if (defaultTargetPlatform == TargetPlatform.iOS) return scrollView;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => cubit.load(refresh: true),
            child: scrollView,
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, VideoLibraryState state) {
    final l10n = context.l10n;
    final cubit = context.read<VideoLibraryCubit>();

    if (state.videos.isEmpty &&
        (state.isLoading || state.status == VideoLibraryStatus.initial)) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    if (state.videos.isEmpty && state.status == VideoLibraryStatus.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: Iconsax.video_slash,
            title: l10n.videoLibraryLoadFailedTitle,
            description: l10n.videoLibraryLoadFailedDescription,
            action: AppButton(
              label: l10n.retry,
              width: 180,
              height: 48,
              onPressed: () => cubit.load(refresh: true),
            ),
          ),
        ),
      ];
    }

    if (state.videos.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyState(
            icon: state.hasFilters
                ? Iconsax.search_normal_1
                : Iconsax.video_play,
            title: state.hasFilters
                ? l10n.videoLibraryNoResultsTitle
                : l10n.videoLibraryEmptyTitle,
            description: state.hasFilters
                ? l10n.videoLibraryNoResultsDescription
                : l10n.videoLibraryEmptyDescription,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        sliver: SliverGrid.builder(
          itemCount: state.videos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 214,
          ),
          itemBuilder: (_, index) {
            final video = state.videos[index];
            return LibraryVideoCard(
              video: video,
              onTap: () => _openVideo(video),
            );
          },
        ),
      ),
      if (state.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }
}

/// Dark brand bar of the guest home: wordmark plus a login action.
final class _LibraryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _LibraryAppBar({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return AppBar(
      backgroundColor: AppColors.neutral1000,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: canPop ? 0 : 18,
      leading: canPop
          ? IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: AppColors.white,
            )
          : null,
      title: const _BrandMark(),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 18),
          child: _LoginButton(onTap: onLogin),
        ),
      ],
    );
  }
}

final class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary300, AppColors.primary700],
            ),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            size: 18,
            color: AppColors.neutral1000,
          ),
        ),
        10.horizontal,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'GLORY ',
                style: style.copyWith(color: AppColors.white),
              ),
              TextSpan(
                text: 'GYM',
                style: style.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

final class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.login, size: 16, color: AppColors.neutral1000),
              6.horizontal,
              Text(
                context.l10n.login,
                style: context.footnoteBold.copyWith(
                  color: AppColors.neutral1000,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark welcome block that continues the app bar, with the search field.
final class _Hero extends StatelessWidget {
  const _Hero({
    required this.onSearch,
    required this.onFilter,
    required this.activeFilterCount,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onFilter;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        gradient: RadialGradient(
          // Opaque stops: the page behind the rounded corners is light.
          center: AlignmentDirectional(0.9, -0.8),
          radius: 1.4,
          colors: [Color(0xFF33260A), AppColors.neutral1000],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.videoLibraryWelcome,
            style: context.captionRegular.copyWith(color: AppColors.primary),
          ),
          4.vertical,
          Text(
            l10n.videoLibraryHeroTitle,
            style: context.heading3.copyWith(color: AppColors.white),
          ),
          6.vertical,
          Text(
            l10n.videoLibraryHeroSubtitle,
            style: context.captionRegular.copyWith(color: AppColors.neutral400),
          ),
          18.vertical,
          Row(
            children: [
              Expanded(child: _SearchField(onChanged: onSearch)),
              10.horizontal,
              _FilterButton(onTap: onFilter, activeCount: activeFilterCount),
            ],
          ),
        ],
      ),
    );
  }
}

final class _FiltersHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FiltersHeaderDelegate({
    required this.state,
    required this.onAudienceSelected,
    required this.onCategorySelected,
  });

  final VideoLibraryState state;
  final ValueChanged<VideoAudience?> onAudienceSelected;
  final ValueChanged<String?> onCategorySelected;

  static const _audienceHeight = 42.0;
  static const _chipsHeight = 36.0;
  static const _gap = 12.0;

  bool get _hasCategories => state.categories.isNotEmpty;

  @override
  double get maxExtent =>
      _gap +
      _audienceHeight +
      _gap +
      (_hasCategories ? _chipsHeight + _gap : 0);

  @override
  double get minExtent => maxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.neutral100,
      padding: const EdgeInsets.only(top: _gap),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _AudienceSwitch(
              selected: state.audience,
              onSelected: onAudienceSelected,
            ),
          ),
          if (_hasCategories) ...[
            const SizedBox(height: _gap),
            _CategoryChips(
              categories: state.categories,
              selected: state.selectedCategory,
              onSelected: onCategorySelected,
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FiltersHeaderDelegate oldDelegate) =>
      oldDelegate.state.audience != state.audience ||
      oldDelegate.state.selectedCategory != state.selectedCategory ||
      oldDelegate.state.categories != state.categories;
}

final class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap, required this.activeCount});

  final VoidCallback onTap;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: active ? AppColors.primary : AppColors.neutral900,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.neutral800,
                ),
              ),
              child: Icon(
                Iconsax.setting_4,
                size: 22,
                color: active ? AppColors.neutral1000 : AppColors.primary,
              ),
            ),
          ),
        ),
        if (active)
          PositionedDirectional(
            top: -6,
            end: -6,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral1000, width: 2),
              ),
              child: Text(
                '$activeCount',
                style: context.footnoteBold.copyWith(
                  color: AppColors.neutral1000,
                  fontSize: 10,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: context.contentRegular.copyWith(color: AppColors.neutral1000),
      decoration: InputDecoration(
        hintText: context.l10n.videoLibrarySearchHint,
        hintStyle: context.captionRegular.copyWith(color: AppColors.neutral400),
        prefixIcon: const Icon(
          Iconsax.search_normal_1,
          size: 20,
          color: AppColors.neutral500,
        ),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

final class _AudienceSwitch extends StatelessWidget {
  const _AudienceSwitch({required this.selected, required this.onSelected});

  final VideoAudience? selected;
  final ValueChanged<VideoAudience?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <(VideoAudience?, String)>[
      (null, l10n.videoLibraryAllCategories),
      (VideoAudience.male, l10n.videoAudienceMale),
      (VideoAudience.female, l10n.videoAudienceFemale),
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          for (final (audience, label) in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(audience),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: audience == selected
                        ? AppColors.primary
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    label,
                    style: context.captionBold.copyWith(
                      color: audience == selected
                          ? AppColors.neutral1000
                          : AppColors.neutral600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _CategoryChips extends StatefulWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

final class _CategoryChipsState extends State<_CategoryChips> {
  final _selectedKey = GlobalKey();

  @override
  void didUpdateWidget(_CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A muscle picked in the filter sheet may sit off-screen in this row.
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final chipContext = _selectedKey.currentContext;
        if (chipContext == null || !chipContext.mounted) return;
        Scrollable.ensureVisible(
          chipContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <String?>[null, ...widget.categories];

    // A Row (not a lazy ListView) so the selected chip always has a context
    // to scroll to.
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            for (final (index, category) in items.indexed) ...[
              if (index > 0) const SizedBox(width: 8),
              _Chip(
                key: category == widget.selected ? _selectedKey : null,
                label: category == null
                    ? context.l10n.videoLibraryAllCategories
                    : VideoCategoryLabel.parse(category).muscle,
                selected: category == widget.selected,
                onTap: () => widget.onSelected(category),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.neutral200,
          ),
        ),
        child: Text(
          label,
          style: context.captionBold.copyWith(
            color: selected ? AppColors.neutral1000 : AppColors.neutral700,
          ),
        ),
      ),
    );
  }
}
