import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';

class MediaListItem extends ConsumerWidget {
  final MediaFile file;
  final VoidCallback onTap;

  const MediaListItem({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = ref.watch(favoritesProvider).contains(file.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Album Artwork thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _getArtworkColor(file.id),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildArtwork(isDark),
              ),
            ),
            const SizedBox(width: 14),

            // Title and Subtitle with Device icon
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    file.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.mobileScreenButton,
                        size: 11,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _getSubtitle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3-dots Menu
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                size: 15,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              onPressed: () => _showItemMenu(context, ref, isFavorite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(bool isDark) {
    if (file.type == MediaType.audio) {
      final intId = int.tryParse(file.id);
      if (intId != null && intId > 9) {
        return QueryArtworkWidget(
          id: intId,
          type: ArtworkType.AUDIO,
          nullArtworkWidget: _defaultArt(),
        );
      }
      return _defaultArt();
    } else {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.emeraldCyanGradient,
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 20),
        ),
      );
    }
  }

  Widget _defaultArt() {
    final colors = _getGradientColors(file.title);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            left: 5,
            child: FaIcon(FontAwesomeIcons.music, size: 10, color: Colors.white.withValues(alpha: 0.6)),
          ),
          Center(
            child: FaIcon(
              FontAwesomeIcons.waveSquare,
              color: Colors.white.withValues(alpha: 0.9),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(String title) {
    final hash = title.hashCode.abs();
    final palettes = [
      [AppTheme.primaryIndigo, AppTheme.primaryCyan],
      [AppTheme.primaryViolet, AppTheme.primaryCoral],
      [AppTheme.primaryEmerald, AppTheme.primaryCyan],
      [AppTheme.primaryAmber, AppTheme.primaryCoral],
      [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
    ];
    return palettes[hash % palettes.length];
  }

  Color _getArtworkColor(String id) {
    final colors = [
      AppTheme.primaryIndigo,
      AppTheme.primaryViolet,
      AppTheme.primaryCyan,
      AppTheme.primaryCoral,
      AppTheme.primaryEmerald,
    ];
    final hash = (int.tryParse(id) ?? id.hashCode).abs();
    return colors[hash % colors.length];
  }

  String _getSubtitle() {
    if (file.type == MediaType.audio) {
      final artist = file.artist ?? 'Unknown artist';
      final album = file.album ?? 'Unknown album';
      return '$artist • $album';
    }
    return '${_formatSize(file.size)} • ${_formatDuration(file.duration)}';
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    var res = bytes / (1024 * (i == 0 ? 1 : i * 1024));
    return "${res.toStringAsFixed(1)} ${suffixes[i]}";
  }

  void _showItemMenu(BuildContext context, WidgetRef ref, bool isFavorite) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.music, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(file.artist ?? 'Unknown artist', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: FaIcon(
                isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                color: isFavorite ? AppTheme.primaryCoral : null,
                size: 18,
              ),
              title: Text(isFavorite ? 'Remove from Favourites' : 'Add to Favourites', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(file.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.listUl, size: 18),
              title: Text('Add to playlist', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Playlist')));
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.circleInfo, size: 18),
              title: Text('Track details', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Information', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${file.title}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Artist: ${file.artist ?? "Unknown"}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            const SizedBox(height: 6),
            Text('Album: ${file.album ?? "Unknown"}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            const SizedBox(height: 6),
            Text('Duration: ${_formatDuration(file.duration)}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            const SizedBox(height: 6),
            Text('Size: ${_formatSize(file.size)}', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryIndigo, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
