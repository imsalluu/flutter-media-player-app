import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isShuffle = false;
  bool _isRepeat = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);
    final mediaItem = ref.watch(currentMediaItemProvider).value;
    final playbackState = ref.watch(playerStateProvider).value;

    if (mediaItem == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No song selected', style: TextStyle(color: Colors.white))),
      );
    }

    final isPlaying = playbackState?.playing ?? false;
    final isFavorite = ref.watch(favoritesProvider).contains(mediaItem.extras?['id']?.toString() ?? mediaItem.id);

    if (isPlaying) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      _rotationController.stop();
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: isFavorite ? AppTheme.primaryCoral : Colors.white70,
              size: 22,
            ),
            onPressed: () {
              final id = mediaItem.extras?['id']?.toString() ?? mediaItem.id;
              ref.read(favoritesProvider.notifier).toggleFavorite(id);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, color: Colors.white70, size: 18),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Cyber Ambient Glow Background
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Turntable & Controls Area
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Vinyl Disc Turntable
                Expanded(
                  flex: 5,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F111A),
                          border: Border.all(color: const Color(0xFF222638), width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Vinyl grooves
                            for (var r in [220.0, 180.0, 140.0])
                              Container(
                                width: r,
                                height: r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
                                ),
                              ),
                            // Center Artwork Disc
                            Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryGradient,
                              ),
                              child: ClipOval(
                                child: QueryArtworkWidget(
                                  id: int.tryParse(mediaItem.extras?['id']?.toString() ?? '') ?? 0,
                                  type: ArtworkType.AUDIO,
                                  artworkWidth: 300,
                                  artworkHeight: 300,
                                  nullArtworkWidget: const Center(
                                    child: FaIcon(FontAwesomeIcons.music, size: 36, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            // Center Spindle Hole
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF090A10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title & Artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      Text(
                        mediaItem.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mediaItem.artist ?? 'Unknown Artist',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Progress Bar & Duration
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: _ProgressControls(),
                ),

                const SizedBox(height: 24),

                // Playback Controls Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.shuffle,
                          color: _isShuffle ? AppTheme.primaryIndigo : Colors.white38,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _isShuffle = !_isShuffle);
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.backwardStep, size: 28, color: Colors.white),
                        onPressed: () => handler.skipToPrevious(),
                      ),
                      _PlayCircleButton(
                        isPlaying: isPlaying,
                        onTap: () => isPlaying ? handler.pause() : handler.play(),
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.forwardStep, size: 28, color: Colors.white),
                        onPressed: () => handler.skipToNext(),
                      ),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.repeat,
                          color: _isRepeat ? AppTheme.primaryIndigo : Colors.white38,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _isRepeat = !_isRepeat);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayCircleButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: FaIcon(
            isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ProgressControls extends ConsumerWidget {
  const _ProgressControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final item = ref.watch(currentMediaItemProvider).value;
    final duration = item?.duration ?? Duration.zero;

    return Column(
      children: [
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppTheme.primaryIndigo,
            inactiveTrackColor: Color(0xFF222638),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0),
            max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
            onChanged: (val) => ref.read(audioHandlerProvider).seek(Duration(milliseconds: val.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position), style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
              Text(_formatDuration(duration), style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
