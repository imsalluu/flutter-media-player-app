import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:audio_service/audio_service.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LockscreenScreen extends ConsumerStatefulWidget {
  const LockscreenScreen({super.key});

  @override
  ConsumerState<LockscreenScreen> createState() => _LockscreenScreenState();
}

class _LockscreenScreenState extends ConsumerState<LockscreenScreen> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final playbackState = ref.watch(playerStateProvider).value;
    final isPlaying = playbackState?.playing ?? false;

    final id = mediaItem?.extras?['id']?.toString() ?? mediaItem?.id ?? '';
    final isFavorite = ref.watch(favoritesProvider).contains(id);

    final timeString = DateFormat('h:mm').format(_currentTime);
    final dateString = DateFormat('EEEE, MMM d').format(_currentTime);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
            // Swiped up -> Unlock
            Navigator.pop(context);
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF131528),
                Color(0xFF090A10),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Large Bold Clock
                Text(
                  timeString,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 76,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -2.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),

                // Date string
                Text(
                  dateString,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),

                const Spacer(flex: 2),

                // Center Album Art Card with Ambient Glow
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Artwork or fallback poster
                          _buildCardArtwork(mediaItem),

                          // Dark gradient overlay for crisp readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),

                          // Top Title & Artist
                          Positioned(
                            top: 18,
                            left: 18,
                            right: 54,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem?.title ?? 'Sitaare | Ikkis | Agastya Nanda, Si...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  mediaItem?.artist ?? 'Sony Music India',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Top Right Badge
                          Positioned(
                            top: 18,
                            right: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const FaIcon(FontAwesomeIcons.music, color: Colors.white, size: 12),
                            ),
                          ),

                          // Bottom Player Controls on the Card
                          Positioned(
                            bottom: 18,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Previous
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.backwardStep, size: 24, color: Colors.white),
                                  onPressed: () => handler.skipToPrevious(),
                                ),
                                // Play / Pause
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
                                        blurRadius: 14,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: FaIcon(
                                      isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => isPlaying ? handler.pause() : handler.play(),
                                  ),
                                ),
                                // Next
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.forwardStep, size: 24, color: Colors.white),
                                  onPressed: () => handler.skipToNext(),
                                ),
                                // Favorite Heart
                                IconButton(
                                  icon: FaIcon(
                                    isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                    size: 22,
                                    color: isFavorite ? AppTheme.primaryCoral : Colors.white,
                                  ),
                                  onPressed: () {
                                    if (id.isNotEmpty) {
                                      ref.read(favoritesProvider.notifier).toggleFavorite(id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                const Spacer(flex: 3),

                // Bottom "Swipe up to unlock"
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.chevronUp,
                        color: Colors.white70,
                        size: 18,
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).slideY(begin: 0, end: -0.2),
                      const SizedBox(height: 6),
                      Text(
                        'Swipe up to unlock',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardArtwork(MediaItem? item) {
    if (item != null) {
      final intId = int.tryParse(item.extras?['id']?.toString() ?? '');
      if (intId != null && intId > 9) {
        return QueryArtworkWidget(
          id: intId,
          type: ArtworkType.AUDIO,
          artworkFit: BoxFit.cover,
          nullArtworkWidget: _defaultLockArt(item.title),
        );
      }
      return _defaultLockArt(item.title);
    }
    return _defaultLockArt('Sitaare');
  }

  Widget _defaultLockArt(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.violetCoralGradient,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FaIcon(FontAwesomeIcons.recordVinyl, size: 140, color: Colors.white.withValues(alpha: 0.2)),
          Center(
            child: FaIcon(FontAwesomeIcons.music, size: 48, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
