import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/providers/theme_provider.dart';
import 'package:media_player/presentation/screens/audio_player_screen.dart';
import 'package:media_player/presentation/screens/faq_feedback_screen.dart';
import 'package:media_player/presentation/screens/folder_detail_screen.dart';
import 'package:media_player/presentation/screens/lockscreen_screen.dart';
import 'package:media_player/presentation/screens/permission_screen.dart';
import 'package:media_player/presentation/screens/privacy_policy_screen.dart';
import 'package:media_player/presentation/screens/settings_screen.dart';
import 'package:media_player/presentation/screens/user_agreement_screen.dart';
import 'package:media_player/presentation/screens/video_player_screen.dart';
import 'package:media_player/presentation/widgets/filter_bottom_sheet.dart';
import 'package:media_player/presentation/widgets/media_list_item.dart';
import 'package:media_player/presentation/widgets/mini_player.dart';
import 'package:media_player/presentation/widgets/player_styles_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _bottomNavIndex = 0; // 0: My music, 1: Videos, 2: Account/Settings
  final TextEditingController _searchController = TextEditingController();
  int _videoViewMode = 0; // 0: Folders, 1: All Videos
  bool _autoUpdate = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionGranted = ref.watch(permissionStateProvider);

    // If permission is denied, show the styled PermissionScreen
    if (!permissionGranted) {
      return const PermissionScreen();
    }

    final hasActiveMedia = ref.watch(currentMediaItemProvider).value != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top App Bar with Search Bar, Filter & Lockscreen launcher
                if (_bottomNavIndex != 2) _buildTopSearchBar(context, isDark),

                // Main Body based on 3-tab Bottom Nav
                Expanded(
                  child: IndexedStack(
                    index: _bottomNavIndex,
                    children: [
                      _buildMyMusicContent(context, isDark),
                      _buildVideosContent(context, isDark),
                      _buildAccountContent(context, isDark),
                    ],
                  ),
                ),
              ],
            ),

            // Floating Mini Player
            if (hasActiveMedia)
              Positioned(
                bottom: 72,
                left: 0,
                right: 0,
                child: const MiniPlayer(),
              ),

            // 3-tab Bottom Navigation Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Top Search Bar with Filter Button & Lockscreen launcher
  Widget _buildTopSearchBar(BuildContext context, bool isDark) {
    final filterState = ref.watch(mediaFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          // Search Field Pill with Mic Icon
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 15,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: _bottomNavIndex == 1
                            ? 'Search video files, folders...'
                            : 'Search songs, artists, albums...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).state = val;
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 14),
                      color: isDark ? Colors.white38 : const Color(0xFF8E8E93),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.microphone,
                      size: 15,
                      color: isDark ? AppTheme.primaryIndigo : const Color(0xFF6366F1),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voice search active...')),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Filter Button with Active Indicator Badge
          Stack(
            children: [
              IconButton(
                tooltip: 'Filter & Sort Media',
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: filterState.activeFiltersCount > 0
                        ? AppTheme.primaryIndigo.withValues(alpha: 0.2)
                        : (isDark ? AppTheme.cardDark : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: filterState.activeFiltersCount > 0
                          ? AppTheme.primaryIndigo
                          : (isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
                    ),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.sliders,
                    size: 15,
                    color: filterState.activeFiltersCount > 0
                        ? AppTheme.primaryIndigo
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ),
                onPressed: () {
                  FilterBottomSheet.show(context);
                },
              ),
              if (filterState.activeFiltersCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${filterState.activeFiltersCount}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Lock Screen Player Preview Button
          IconButton(
            tooltip: 'Lockscreen Player View',
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
                ),
              ),
              child: const FaIcon(
                FontAwesomeIcons.lock,
                size: 15,
                color: AppTheme.primaryCyan,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LockscreenScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // 1. "My music" tab content
  Widget _buildMyMusicContent(BuildContext context, bool isDark) {
    final selectedTab = ref.watch(selectedSubTabProvider);

    return CustomScrollView(
      slivers: [
        // 3 Quick Cards (Favourites, Playlists, Recent)
        SliverToBoxAdapter(
          child: _buildQuickCards(context),
        ),

        // Sub-navigation Tabs: Songs, Videos, Artists, Albums, Folders
        SliverToBoxAdapter(
          child: _buildSubTabs(context, selectedTab, isDark),
        ),

        // Action Bar: "Shuffle playback" + Filter & Sort
        if (selectedTab == SubTabOption.songs)
          SliverToBoxAdapter(
            child: _buildShuffleActionBar(context, isDark),
          ),

        // Tab Content List
        _buildTabContent(selectedTab, isDark),

        // Space for mini player and bottom nav bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 140),
        ),
      ],
    );
  }

  // 2. "Videos" Tab Content (Folder-wise organization)
  Widget _buildVideosContent(BuildContext context, bool isDark) {
    final videoFolders = ref.watch(videoFoldersProvider);
    final videoFiles = ref.watch(filteredVideoProvider);

    return CustomScrollView(
      slivers: [
        // Folder / All Videos View Mode Switch
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Text(
                  'Video Library',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppTheme.cardBorderDark : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _videoViewMode = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: _videoViewMode == 0 ? AppTheme.primaryGradient : null,
                            color: _videoViewMode == 0 ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.folderOpen,
                                size: 12,
                                color: _videoViewMode == 0 ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Folders',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _videoViewMode == 0 ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _videoViewMode = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: _videoViewMode == 1 ? AppTheme.primaryGradient : null,
                            color: _videoViewMode == 1 ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.grip,
                                size: 12,
                                color: _videoViewMode == 1 ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'All Videos',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _videoViewMode == 1 ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_videoViewMode == 0)
          // Video Folders View
          videoFolders.when(
            data: (folders) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = folders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: FaIcon(FontAwesomeIcons.film, color: Colors.white, size: 20),
                            ),
                          ),
                          title: Text(
                            folder.name,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          subtitle: Text(
                            '${folder.mediaCount} video tracks',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FolderDetailScreen(folder: folder),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: folders.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo)),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          )
        else
          // All Videos Grid View
          videoFiles.when(
            data: (videos) => _buildVideoGridList(videos),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo)),
            ),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  // 3. "Account / Settings" Tab Content with "Made by Salman" remark & Awesome Icons
  Widget _buildAccountContent(BuildContext context, bool isDark) {
    final themeMode = ref.watch(themeProvider);
    final permissionGranted = ref.watch(permissionStateProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Developer & Creator Card: "Made by Salman" with Cyber Glow
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E1B3B), const Color(0xFF0F172A)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFE0F2FE)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryIndigo.withValues(alpha: isDark ? 0.45 : 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.userAstronaut,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Made by Salman',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const FaIcon(
                              FontAwesomeIcons.circleCheck,
                              size: 16,
                              color: AppTheme.primaryCyan,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Senior Flutter Developer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.bolt, size: 12, color: AppTheme.primaryCyan),
                        const SizedBox(width: 6),
                        Text(
                          'Cyber Aurora Edition',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryIndigo,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'v3.0.0 Pro',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Device Storage Access Permission Switch
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: permissionGranted
                  ? AppTheme.primaryIndigo.withValues(alpha: 0.4)
                  : AppTheme.primaryCoral.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: permissionGranted ? AppTheme.primaryGradient : AppTheme.violetCoralGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (permissionGranted ? AppTheme.primaryIndigo : AppTheme.primaryCoral).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FaIcon(
                  permissionGranted ? FontAwesomeIcons.shieldHalved : FontAwesomeIcons.shieldCat,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Permission',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      permissionGranted ? 'Allowed (Full media discovery)' : 'Denied (Shows permission screen)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: permissionGranted ? AppTheme.primaryCyan : AppTheme.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: permissionGranted,
                activeColor: AppTheme.primaryIndigo,
                activeTrackColor: AppTheme.primaryIndigo.withValues(alpha: 0.4),
                inactiveThumbColor: AppTheme.primaryCoral,
                onChanged: (val) {
                  ref.read(permissionStateProvider.notifier).togglePermission(val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lockscreen Player Demo
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.lock,
          gradient: AppTheme.primaryGradient,
          title: 'Lock Screen Player View',
          subtitle: 'Preview lockscreen media card & clock',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LockscreenScreen()));
          },
        ),

        // Filter & Sort Settings
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.sliders,
          gradient: AppTheme.emeraldCyanGradient,
          title: 'Filter & Sorting Preferences',
          subtitle: 'Configure audio & video library filters',
          onTap: () => FilterBottomSheet.show(context),
        ),

        // Player Styles
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.palette,
          gradient: AppTheme.violetCoralGradient,
          title: 'Player Styles',
          subtitle: 'Turntable, Glass card, Waveform skins',
          onTap: () => PlayerStylesDialog.show(context),
        ),

        // Theme Mode
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.circleHalfStroke,
          gradient: AppTheme.amberCoralGradient,
          title: 'Theme Mode',
          subtitle: themeMode.name.toUpperCase(),
          onTap: () => _showThemeDialog(context, ref),
        ),

        // Update Automatically Switch
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
          ),
          child: SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldCyanGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(FontAwesomeIcons.arrowsRotate, color: Colors.white, size: 14),
            ),
            title: Text('Update automatically', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text('Auto-refresh new files in background', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
            value: _autoUpdate,
            activeColor: AppTheme.primaryIndigo,
            onChanged: (val) => setState(() => _autoUpdate = val),
          ),
        ),

        // FAQ & Feedback
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.headset,
          gradient: AppTheme.amberCoralGradient,
          title: 'FAQ & Feedback',
          subtitle: 'Help center & contact support',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqFeedbackScreen()));
          },
        ),

        // User Agreement
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.fileContract,
          gradient: AppTheme.emeraldCyanGradient,
          title: 'User Agreement',
          subtitle: 'Terms of service and licensing',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAgreementScreen()));
          },
        ),

        // Privacy Policy
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.userShield,
          gradient: AppTheme.violetCoralGradient,
          title: 'Privacy Policy',
          subtitle: 'Device data safety and encryption',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
          },
        ),

        // Full Settings
        _buildAccountTile(
          isDark: isDark,
          icon: FontAwesomeIcons.gear,
          gradient: AppTheme.primaryGradient,
          title: 'Advanced Settings',
          subtitle: 'Audio buffer, decoders & cache',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
        ),

        const SizedBox(height: 140),
      ],
    );
  }

  Widget _buildAccountTile({
    required bool isDark,
    required dynamic icon,
    required Gradient gradient,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: Colors.white, size: 14),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // 3-tab Bottom Navigation Bar with Glowing Pills & FontAwesomeIcons
  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0F17) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. My music
          _BottomNavItem(
            icon: FontAwesomeIcons.headphones,
            label: 'My music',
            isActive: _bottomNavIndex == 0,
            onTap: () => setState(() => _bottomNavIndex = 0),
          ),

          // 2. Videos
          _BottomNavItem(
            icon: FontAwesomeIcons.clapperboard,
            label: 'Videos',
            isActive: _bottomNavIndex == 1,
            onTap: () => setState(() => _bottomNavIndex = 1),
          ),

          // 3. Account / Settings
          _BottomNavItem(
            icon: FontAwesomeIcons.user,
            label: 'Account',
            isActive: _bottomNavIndex == 2,
            onTap: () => setState(() => _bottomNavIndex = 2),
          ),
        ],
      ),
    );
  }

  // 3 Quick Cards (Favourites, Playlists, Recent)
  Widget _buildQuickCards(BuildContext context) {
    final favSongs = ref.watch(favoriteSongsProvider).value ?? [];
    final recentSongs = ref.watch(recentSongsProvider).value ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // 1. Favourites Card
          Expanded(
            child: _QuickCard(
              title: 'Favourites',
              icon: FontAwesomeIcons.solidHeart,
              gradient: AppTheme.violetCoralGradient,
              onTap: () => _showFavoritesModal(context, favSongs),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Playlists Card
          Expanded(
            child: _QuickCard(
              title: 'Playlists',
              icon: FontAwesomeIcons.listUl,
              gradient: AppTheme.emeraldCyanGradient,
              onTap: () => _showPlaylistsModal(context),
            ),
          ),
          const SizedBox(width: 10),

          // 3. Recent Card
          Expanded(
            child: _QuickCard(
              title: 'Recent',
              icon: FontAwesomeIcons.clockRotateLeft,
              gradient: AppTheme.primaryGradient,
              hasArtworkOverlay: true,
              onTap: () => _showRecentModal(context, recentSongs),
            ),
          ),
        ],
      ),
    );
  }

  // 5 Subtabs (Songs, Videos, Artists, Albums, Folders)
  Widget _buildSubTabs(BuildContext context, SubTabOption activeTab, bool isDark) {
    final tabs = [
      {'tab': SubTabOption.songs, 'label': 'Songs', 'icon': FontAwesomeIcons.compactDisc},
      {'tab': SubTabOption.videos, 'label': 'Videos', 'icon': FontAwesomeIcons.film},
      {'tab': SubTabOption.artists, 'label': 'Artists', 'icon': FontAwesomeIcons.userAstronaut},
      {'tab': SubTabOption.albums, 'label': 'Albums', 'icon': FontAwesomeIcons.recordVinyl},
      {'tab': SubTabOption.folders, 'label': 'Folders', 'icon': FontAwesomeIcons.folderOpen},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: tabs.map((t) {
          final tab = t['tab'] as SubTabOption;
          final label = t['label'] as String;
          final dynamic icon = t['icon'];
          final isSelected = activeTab == tab;

          return GestureDetector(
            onTap: () => ref.read(selectedSubTabProvider.notifier).state = tab,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        icon,
                        size: 13,
                        color: isSelected
                            ? AppTheme.primaryIndigo
                            : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: isSelected ? 22 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Action Row: "Shuffle playback" + Filter & Sort
  Widget _buildShuffleActionBar(BuildContext context, bool isDark) {
    final audioAsync = ref.watch(filteredAudioProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              audioAsync.whenData((songs) {
                if (songs.isNotEmpty) {
                  final shuffled = List<MediaFile>.from(songs)..shuffle();
                  final items = shuffled.map((s) => MediaItem(
                    id: s.path,
                    album: s.album,
                    title: s.title,
                    artist: s.artist,
                    duration: Duration(milliseconds: s.duration),
                    extras: {'id': s.id},
                  )).toList();
                  ref.read(audioHandlerProvider).setPlaylist(items, 0);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioPlayerScreen()));
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.shuffle,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shuffle Playback',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Filter & Sort Options',
            icon: FaIcon(
              FontAwesomeIcons.sliders,
              size: 16,
              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
            ),
            onPressed: () => FilterBottomSheet.show(context),
          ),
          IconButton(
            tooltip: 'Batch Selection Mode',
            icon: FaIcon(
              FontAwesomeIcons.listCheck,
              size: 16,
              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Multi-select batch mode enabled')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Dynamic Content for Sub-tabs
  Widget _buildTabContent(SubTabOption tab, bool isDark) {
    switch (tab) {
      case SubTabOption.songs:
        return _buildSongsSliverList();
      case SubTabOption.videos:
        return _buildVideosSliverGrid();
      case SubTabOption.artists:
        return _buildArtistsSliverList(isDark);
      case SubTabOption.albums:
        return _buildAlbumsSliverList(isDark);
      case SubTabOption.folders:
        return _buildFoldersSliverList(isDark);
    }
  }

  // Songs List
  Widget _buildSongsSliverList() {
    final audioAsync = ref.watch(filteredAudioProvider);

    return audioAsync.when(
      data: (songs) {
        if (songs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  children: [
                    const FaIcon(FontAwesomeIcons.music, size: 40, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No matching tracks found',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = songs[index];
              return MediaListItem(
                file: song,
                onTap: () {
                  final items = songs.map((s) => MediaItem(
                    id: s.path,
                    album: s.album,
                    title: s.title,
                    artist: s.artist,
                    duration: Duration(milliseconds: s.duration),
                    extras: {'id': s.id},
                  )).toList();
                  ref.read(audioHandlerProvider).setPlaylist(items, index);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioPlayerScreen()));
                },
              );
            },
            childCount: songs.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo)),
        ),
      ),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  // Videos Grid
  Widget _buildVideosSliverGrid() {
    final videoAsync = ref.watch(filteredVideoProvider);
    return videoAsync.when(
      data: (videos) => _buildVideoGridList(videos),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo)),
      ),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildVideoGridList(List<MediaFile> videos) {
    if (videos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              children: [
                const FaIcon(FontAwesomeIcons.film, size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  'No matching videos found',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final video = videos[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videos: videos,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppTheme.emeraldCyanGradient,
                              ),
                              child: const Center(
                                child: FaIcon(FontAwesomeIcons.circlePlay, size: 40, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatDuration(video.duration),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: videos.length,
        ),
      ),
    );
  }

  // Artists List
  Widget _buildArtistsSliverList(bool isDark) {
    final artistsAsync = ref.watch(artistsProvider);

    return artistsAsync.when(
      data: (artistsMap) {
        final artistNames = artistsMap.keys.toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final artist = artistNames[index];
              final songs = artistsMap[artist]!;
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.userAstronaut, color: Colors.white, size: 16),
                  ),
                ),
                title: Text(artist, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('${songs.length} songs', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey),
                onTap: () => _showSongsListModal(context, artist, songs),
              );
            },
            childCount: artistNames.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo))),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  // Albums List
  Widget _buildAlbumsSliverList(bool isDark) {
    final albumsAsync = ref.watch(albumsProvider);

    return albumsAsync.when(
      data: (albumsMap) {
        final albumNames = albumsMap.keys.toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final album = albumNames[index];
              final songs = albumsMap[album]!;
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppTheme.violetCoralGradient,
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.recordVinyl, color: Colors.white, size: 18),
                  ),
                ),
                title: Text(album, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('${songs.length} songs', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey),
                onTap: () => _showSongsListModal(context, album, songs),
              );
            },
            childCount: albumNames.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo))),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  // Folders List
  Widget _buildFoldersSliverList(bool isDark) {
    final musicFolders = ref.watch(musicFoldersProvider);

    return musicFolders.when(
      data: (folders) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final folder = folders[index];
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppTheme.emeraldCyanGradient,
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.folderOpen, color: Colors.white, size: 16),
                  ),
                ),
                title: Text(folder.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('${folder.mediaCount} items', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FolderDetailScreen(folder: folder)),
                  );
                },
              );
            },
            childCount: folders.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo))),
      error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Theme', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _ThemeOption(mode: ThemeMode.system, icon: FontAwesomeIcons.circleHalfStroke, label: 'System Default'),
            _ThemeOption(mode: ThemeMode.light, icon: FontAwesomeIcons.sun, label: 'Light Mode'),
            _ThemeOption(mode: ThemeMode.dark, icon: FontAwesomeIcons.moon, label: 'Dark Mode'),
          ],
        ),
      ),
    );
  }

  void _showFavoritesModal(BuildContext context, List<MediaFile> favs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.solidHeart, color: AppTheme.primaryCoral, size: 22),
                  const SizedBox(width: 10),
                  Text('Favourites (${favs.length})', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: favs.isEmpty
                  ? const Center(child: Text('No favorite songs yet'))
                  : ListView.builder(
                      itemCount: favs.length,
                      itemBuilder: (context, i) => MediaListItem(
                        file: favs[i],
                        onTap: () {
                          final items = favs.map((s) => MediaItem(
                            id: s.path,
                            album: s.album,
                            title: s.title,
                            artist: s.artist,
                            duration: Duration(milliseconds: s.duration),
                            extras: {'id': s.id},
                          )).toList();
                          ref.read(audioHandlerProvider).setPlaylist(items, i);
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioPlayerScreen()));
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Playlists', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.listUl, color: AppTheme.primaryIndigo, size: 24),
              title: Text('Top Hits 2026', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              subtitle: const Text('9 songs'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.listUl, color: AppTheme.primaryIndigo, size: 24),
              title: Text('Bangla Vibes', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              subtitle: const Text('5 songs'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecentModal(BuildContext context, List<MediaFile> recents) {
    _showFavoritesModal(context, recents);
  }

  void _showSongsListModal(BuildContext context, String title, List<MediaFile> songs) {
    _showFavoritesModal(context, songs);
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}

// Quick Card Component
class _QuickCard extends StatelessWidget {
  final String title;
  final dynamic icon;
  final Gradient gradient;
  final bool hasArtworkOverlay;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.icon,
    required this.gradient,
    this.hasArtworkOverlay = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (hasArtworkOverlay)
              Positioned(
                right: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.15,
                  child: const FaIcon(FontAwesomeIcons.music, size: 65, color: Colors.white),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon, color: Colors.white, size: 18),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Nav Item Component
class _BottomNavItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.primaryIndigo;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 19,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends ConsumerWidget {
  final ThemeMode mode;
  final dynamic icon;
  final String label;

  const _ThemeOption({required this.mode, required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);
    final isSelected = currentMode == mode;

    return ListTile(
      leading: FaIcon(icon, color: isSelected ? AppTheme.primaryIndigo : Colors.grey, size: 18),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.primaryIndigo, size: 18) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
