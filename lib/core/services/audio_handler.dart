import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_player/core/services/storage_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _storage = StorageService();

  MyAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.currentIndexStream.listen((index) async {
      if (index != null && queue.value.isNotEmpty && index < queue.value.length) {
        final current = queue.value[index];
        mediaItem.add(current);
        // Resume from saved position if any
        final savedMs = await _storage.getPlaybackPosition(current.id);
        if (savedMs > 3000 && _player.position.inMilliseconds < 1000) {
          _player.seek(Duration(milliseconds: savedMs));
        }
      }
    });

    // Periodically save playback position
    _player.positionStream.listen((pos) {
      final current = mediaItem.value;
      if (current != null && pos.inMilliseconds > 2000) {
        _storage.savePlaybackPosition(current.id, pos.inMilliseconds);
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() async {
    final current = mediaItem.value;
    if (current != null) {
      await _storage.savePlaybackPosition(current.id, _player.position.inMilliseconds);
    }
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    final current = mediaItem.value;
    if (current != null) {
      await _storage.savePlaybackPosition(current.id, _player.position.inMilliseconds);
    }
    await _player.stop();
    mediaItem.add(null);
  }

  Future<void> setPlaylist(List<MediaItem> items, int index) async {
    final playlist = ConcatenatingAudioSource(
      children: items.map((item) {
        final uri = item.id.startsWith('http://') || item.id.startsWith('https://')
            ? Uri.parse(item.id)
            : Uri.file(item.id);
        return AudioSource.uri(uri, tag: item);
      }).toList(),
    );
    queue.add(items);
    await _player.setAudioSource(playlist, initialIndex: index);
    
    // Check saved position for initial track
    if (index < items.length) {
      final savedMs = await _storage.getPlaybackPosition(items[index].id);
      if (savedMs > 3000) {
        await _player.seek(Duration(milliseconds: savedMs));
      }
    }
    _player.play();
  }
}


