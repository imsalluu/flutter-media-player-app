import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/media_service.dart';
import 'package:media_player/core/services/permission_service.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/domain/entities/media_folder.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';

final mediaServiceProvider = Provider((ref) => MediaService());

// Permission state provider (supports allow / deny simulation & native check)
final permissionStateProvider = StateNotifierProvider<PermissionStateNotifier, bool>((ref) {
  return PermissionStateNotifier();
});

class PermissionStateNotifier extends StateNotifier<bool> {
  PermissionStateNotifier() : super(true) {
    checkPermission();
  }

  Future<void> checkPermission() async {
    final granted = await PermissionService.checkPermissionStatus();
    state = granted;
  }

  Future<void> requestPermission() async {
    final granted = await PermissionService.requestStoragePermission();
    state = granted;
  }

  void togglePermission(bool allow) {
    PermissionService.setMockPermission(allow);
    state = allow;
  }
}

final audioFilesProvider = FutureProvider<List<MediaFile>>((ref) {
  return ref.watch(mediaServiceProvider).fetchAudioFiles();
});

final videoFilesProvider = FutureProvider<List<MediaFile>>((ref) {
  return ref.watch(mediaServiceProvider).fetchVideoFiles();
});

enum SortField { name, dateAdded, duration, size }
enum SortOrder { ascending, descending }
enum DurationFilter { all, under1Min, oneToFiveMins, overFiveMins }
enum FormatFilter { all, mp3, mp4, wav, flac, aac, m4a, mkv }
enum SubTabOption { songs, videos, artists, albums, folders }

class MediaFilterState {
  final SortField sortField;
  final SortOrder sortOrder;
  final DurationFilter durationFilter;
  final FormatFilter formatFilter;

  const MediaFilterState({
    this.sortField = SortField.dateAdded,
    this.sortOrder = SortOrder.descending,
    this.durationFilter = DurationFilter.all,
    this.formatFilter = FormatFilter.all,
  });

  bool get isDefault =>
      sortField == SortField.dateAdded &&
      sortOrder == SortOrder.descending &&
      durationFilter == DurationFilter.all &&
      formatFilter == FormatFilter.all;

  int get activeFiltersCount {
    int count = 0;
    if (sortField != SortField.dateAdded || sortOrder != SortOrder.descending) count++;
    if (durationFilter != DurationFilter.all) count++;
    if (formatFilter != FormatFilter.all) count++;
    return count;
  }

  MediaFilterState copyWith({
    SortField? sortField,
    SortOrder? sortOrder,
    DurationFilter? durationFilter,
    FormatFilter? formatFilter,
  }) {
    return MediaFilterState(
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      durationFilter: durationFilter ?? this.durationFilter,
      formatFilter: formatFilter ?? this.formatFilter,
    );
  }
}

class MediaFilterNotifier extends StateNotifier<MediaFilterState> {
  MediaFilterNotifier() : super(const MediaFilterState());

  void setSortField(SortField field) {
    state = state.copyWith(sortField: field);
  }

  void toggleSortOrder() {
    state = state.copyWith(
      sortOrder: state.sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending,
    );
  }

  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void setDurationFilter(DurationFilter filter) {
    state = state.copyWith(durationFilter: filter);
  }

  void setFormatFilter(FormatFilter filter) {
    state = state.copyWith(formatFilter: filter);
  }

  void resetFilters() {
    state = const MediaFilterState();
  }
}

final mediaFilterProvider = StateNotifierProvider<MediaFilterNotifier, MediaFilterState>((ref) {
  return MediaFilterNotifier();
});

final selectedSubTabProvider = StateProvider<SubTabOption>((ref) => SubTabOption.songs);
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered audio for search, sorting and advanced filtering
final filteredAudioProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final audioAsync = ref.watch(audioFilesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(mediaFilterProvider);

  return audioAsync.whenData((list) {
    var filtered = list.where((item) {
      // Search matching
      final matchesQuery = item.title.toLowerCase().contains(query) ||
          (item.artist?.toLowerCase().contains(query) ?? false) ||
          (item.album?.toLowerCase().contains(query) ?? false);
      if (!matchesQuery) return false;

      // Duration filtering
      final durSec = (item.duration / 1000).toInt();
      switch (filter.durationFilter) {
        case DurationFilter.under1Min:
          if (durSec >= 60) return false;
          break;
        case DurationFilter.oneToFiveMins:
          if (durSec < 60 || durSec > 300) return false;
          break;
        case DurationFilter.overFiveMins:
          if (durSec <= 300) return false;
          break;
        case DurationFilter.all:
          break;
      }

      // Format filtering
      if (filter.formatFilter != FormatFilter.all) {
        final pathLower = item.path.toLowerCase();
        final formatName = filter.formatFilter.name.toLowerCase();
        if (!pathLower.endsWith('.$formatName') &&
            !(formatName == 'mp3' && (pathLower.contains('.mp3') || item.type == MediaType.audio))) {
          // If extension not explicitly in name, match general audio
        }
      }

      return true;
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (filter.sortField) {
        case SortField.name:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortField.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
        case SortField.duration:
          comparison = a.duration.compareTo(b.duration);
          break;
        case SortField.size:
          comparison = a.size.compareTo(b.size);
          break;
      }
      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filtered;
  });
});

// Grouped by Artist
final artistsProvider = Provider<AsyncValue<Map<String, List<MediaFile>>>>((ref) {
  final audioAsync = ref.watch(filteredAudioProvider);
  return audioAsync.whenData((songs) {
    final Map<String, List<MediaFile>> grouped = {};
    for (var song in songs) {
      final artist = (song.artist == null || song.artist!.isEmpty) ? 'Unknown Artist' : song.artist!;
      grouped.putIfAbsent(artist, () => []).add(song);
    }
    return grouped;
  });
});

// Grouped by Album
final albumsProvider = Provider<AsyncValue<Map<String, List<MediaFile>>>>((ref) {
  final audioAsync = ref.watch(filteredAudioProvider);
  return audioAsync.whenData((songs) {
    final Map<String, List<MediaFile>> grouped = {};
    for (var song in songs) {
      final album = (song.album == null || song.album!.isEmpty) ? 'Unknown Album' : song.album!;
      grouped.putIfAbsent(album, () => []).add(song);
    }
    return grouped;
  });
});

// Favourites songs
final favoriteSongsProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final audioAsync = ref.watch(filteredAudioProvider);
  final favIds = ref.watch(favoritesProvider);
  return audioAsync.whenData((songs) {
    return songs.where((s) => favIds.contains(s.id)).toList();
  });
});

// Recent songs
final recentSongsProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final audioAsync = ref.watch(filteredAudioProvider);
  final recentIds = ref.watch(recentProvider);
  return audioAsync.whenData((songs) {
    if (recentIds.isEmpty) {
      return songs.take(5).toList();
    }
    return songs.where((s) => recentIds.contains(s.id)).toList();
  });
});

// Filtered videos for search, sort and advanced filters
final filteredVideoProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final videoAsync = ref.watch(videoFilesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final filter = ref.watch(mediaFilterProvider);

  return videoAsync.whenData((list) {
    var filtered = list.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      // Duration filtering
      final durSec = (item.duration / 1000).toInt();
      switch (filter.durationFilter) {
        case DurationFilter.under1Min:
          if (durSec >= 60) return false;
          break;
        case DurationFilter.oneToFiveMins:
          if (durSec < 60 || durSec > 300) return false;
          break;
        case DurationFilter.overFiveMins:
          if (durSec <= 300) return false;
          break;
        case DurationFilter.all:
          break;
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (filter.sortField) {
        case SortField.name:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortField.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
        case SortField.duration:
          comparison = a.duration.compareTo(b.duration);
          break;
        case SortField.size:
          comparison = a.size.compareTo(b.size);
          break;
      }
      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filtered;
  });
});

final videoFoldersProvider = FutureProvider<List<MediaFolder>>((ref) {
  return ref.watch(mediaServiceProvider).fetchVideoFolders();
});

final musicFoldersProvider = FutureProvider<List<MediaFolder>>((ref) {
  return ref.watch(mediaServiceProvider).fetchAudioFolders();
});

final audioByFolderProvider = FutureProvider.family<List<MediaFile>, String>((ref, folderId) {
  return ref.watch(mediaServiceProvider).fetchAudioByAlbum(folderId);
});

final videoByFolderProvider = FutureProvider.family<List<MediaFile>, String>((ref, folderId) {
  return ref.watch(mediaServiceProvider).fetchVideosByFolder(folderId);
});
