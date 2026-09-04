import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/domain/entities/media_folder.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/widgets/media_list_item.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/screens/audio_player_screen.dart';
import 'package:media_player/presentation/screens/video_player_screen.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FolderDetailScreen extends ConsumerWidget {
  final MediaFolder folder;
  const FolderDetailScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = folder.type == MediaType.audio 
      ? ref.watch(audioByFolderProvider(folder.id))
      : ref.watch(videoByFolderProvider(folder.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          folder.name,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: filesAsync.when(
        data: (files) => files.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.folderOpen, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No media files in this folder',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return MediaListItem(
                    file: file,
                    onTap: () {
                      if (file.type == MediaType.audio) {
                        final items = files.map((f) => MediaItem(
                          id: f.path,
                          album: f.album,
                          title: f.title,
                          artist: f.artist,
                          duration: Duration(milliseconds: f.duration),
                          extras: {'id': f.id},
                        )).toList();
                        ref.read(audioHandlerProvider).setPlaylist(items, index);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioPlayerScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videos: files, initialIndex: index)));
                      }
                    },
                  ).animate().fadeIn(delay: (40 * index).ms).slideX(begin: 0.08, end: 0);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white54))),
      ),
    );
  }
}
