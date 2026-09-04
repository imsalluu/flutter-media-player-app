import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/widgets/media_list_item.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/screens/audio_player_screen.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicListScreen extends ConsumerWidget {
  const MusicListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioAsync = ref.watch(filteredAudioProvider);
    final searchController = TextEditingController(text: ref.read(searchQueryProvider));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              title: const Text('My Music', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortDialog(context, ref),
                ),
                const SizedBox(width: 16),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search your mobile music...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FeaturedSection(audioAsync: audioAsync),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: const Text('Recent Tracks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            audioAsync.when(
              data: (songs) => SliverList(
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
                    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
                  },
                  childCount: songs.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131520),
        title: const Text('Sort By', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SortOption(label: 'Date Added', option: SortField.dateAdded),
            _SortOption(label: 'Name', option: SortField.name),
            _SortOption(label: 'Size', option: SortField.size),
            _SortOption(label: 'Duration', option: SortField.duration),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends ConsumerWidget {
  final String label;
  final SortField option;
  const _SortOption({required this.label, required this.option});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(mediaFilterProvider);
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      leading: Radio<SortField>(
        value: option,
        groupValue: currentFilter.sortField,
        activeColor: const Color(0xFF6366F1),
        onChanged: (val) {
          if (val != null) {
            ref.read(mediaFilterProvider.notifier).setSortField(val);
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  final AsyncValue<List<MediaFile>> audioAsync;
  const _FeaturedSection({required this.audioAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Featured', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: audioAsync.when(
            data: (songs) {
              if (songs.isEmpty) return const SizedBox();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: songs.take(5).length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Container(
                    width: 320,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF003A).withOpacity(0.8),
                          const Color(0xFF000000),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: QueryArtworkWidget(
                            id: int.parse(song.id),
                            type: ArtworkType.AUDIO,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(song.artist ?? 'Unknown Artist', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          ),
                        ),
                        const Center(child: Icon(Icons.play_circle_fill, size: 50, color: Color(0xFFFF003A))),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}
