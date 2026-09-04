import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/domain/entities/media_folder.dart';

class MediaService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  static final List<MediaFile> sampleSongs = [
    MediaFile(
      id: '1',
      title: 'AUD-20260823-WA0055',
      artist: 'Unknown artist',
      album: 'Unknown album',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      duration: 372000,
      size: 6140000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MediaFile(
      id: '2',
      title: 'Rabindra Sangeet By Arijit Singh | B...',
      artist: 'Jamming With NJ',
      album: 'Jamming With NJ',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      duration: 295000,
      size: 4800000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MediaFile(
      id: '3',
      title: '@SaiAbhyankkar - Pavazha Malli (Mu...',
      artist: 'Think Music India',
      album: 'Think Music India',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      duration: 218000,
      size: 3500000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MediaFile(
      id: '4',
      title: 'Udi Udi',
      artist: 'Aneesh, Sarkar, Hruday',
      album: 'Udi Udi',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      duration: 242000,
      size: 3900000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 4)),
    ),
    MediaFile(
      id: '5',
      title: 'Sitaare | Ikkis | Agastya Nanda, Simar...',
      artist: 'Sony Music India',
      album: 'Sony Music India',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      duration: 198000,
      size: 3200000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MediaFile(
      id: '6',
      title: 'Shaky',
      artist: 'Sanju Rathod, G-SPXRK',
      album: 'Shaky',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      duration: 180000,
      size: 2900000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 6)),
    ),
    MediaFile(
      id: '7',
      title: 'Sahiba',
      artist: 'Aditya Rikhari',
      album: 'Sahiba',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      duration: 210000,
      size: 3400000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 7)),
    ),
    MediaFile(
      id: '8',
      title: 'Patar Bashori | Coke Studio Bangla | ...',
      artist: 'Coke Studio Bangla',
      album: 'Season 2',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      duration: 260000,
      size: 4200000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 8)),
    ),
    MediaFile(
      id: '9',
      title: 'কিছু মানুষ মরে যায় পঁচিশে',
      artist: 'Saif Zohan',
      album: 'Single',
      path: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      duration: 275000,
      size: 4500000,
      type: MediaType.audio,
      dateAdded: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  static final List<MediaFile> sampleVideos = [
    MediaFile(
      id: 'v1',
      title: 'Coke Studio Bangla - Season 2 Behind The Scenes',
      path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      duration: 596000,
      size: 158000000,
      type: MediaType.video,
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MediaFile(
      id: 'v2',
      title: 'Arijit Singh Live Concert Kolkata 4K',
      path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      duration: 653000,
      size: 180000000,
      type: MediaType.video,
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MediaFile(
      id: 'v3',
      title: 'Pavazha Malli Official 4K Video Song',
      path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      duration: 150000,
      size: 45000000,
      type: MediaType.video,
      dateAdded: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MediaFile(
      id: 'v4',
      title: 'MIUI 14 Visual Experience & Animations',
      path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      duration: 180000,
      size: 52000000,
      type: MediaType.video,
      dateAdded: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  Future<List<MediaFile>> fetchAudioFiles() async {
    if (kIsWeb) {
      return sampleSongs;
    }

    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      if (songs.isEmpty) {
        return sampleSongs;
      }

      return songs.map((song) => MediaFile(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        path: song.data,
        duration: song.duration ?? 0,
        size: song.size,
        type: MediaType.audio,
        dateAdded: DateTime.fromMillisecondsSinceEpoch((song.dateAdded ?? 0) * 1000),
      )).toList();
    } catch (e) {
      debugPrint('Error fetching audio files: $e');
      return sampleSongs;
    }
  }

  Future<List<MediaFolder>> fetchAudioFolders() async {
    if (kIsWeb) {
      return [
        MediaFolder(id: '1', name: 'WhatsApp Audio', path: '/storage/WhatsApp Audio', mediaCount: 12, type: MediaType.audio),
        MediaFolder(id: '2', name: 'Download', path: '/storage/Download', mediaCount: 28, type: MediaType.audio),
        MediaFolder(id: '3', name: 'Music', path: '/storage/Music', mediaCount: 45, type: MediaType.audio),
        MediaFolder(id: '4', name: 'Coke Studio', path: '/storage/Coke Studio', mediaCount: 8, type: MediaType.audio),
        MediaFolder(id: '5', name: 'Rabindra Sangeet', path: '/storage/Rabindra Sangeet', mediaCount: 14, type: MediaType.audio),
      ];
    }

    try {
      final List<AlbumModel> albums = await _audioQuery.queryAlbums(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      if (albums.isEmpty) {
        return [
          MediaFolder(id: '1', name: 'WhatsApp Audio', path: '', mediaCount: 12, type: MediaType.audio),
          MediaFolder(id: '2', name: 'Download', path: '', mediaCount: 28, type: MediaType.audio),
          MediaFolder(id: '3', name: 'Music', path: '', mediaCount: 45, type: MediaType.audio),
        ];
      }

      return albums.map((album) => MediaFolder(
        id: album.id.toString(),
        name: album.album,
        path: '',
        mediaCount: album.numOfSongs,
        type: MediaType.audio,
      )).toList();
    } catch (e) {
      debugPrint('Error fetching audio albums: $e');
      return [
        MediaFolder(id: '1', name: 'WhatsApp Audio', path: '', mediaCount: 12, type: MediaType.audio),
        MediaFolder(id: '2', name: 'Download', path: '', mediaCount: 28, type: MediaType.audio),
      ];
    }
  }

  Future<List<MediaFile>> fetchVideoFiles() async {
    if (kIsWeb) {
      return sampleVideos;
    }

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) return sampleVideos;

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      List<MediaFile> videos = [];
      final Set<String> seenIds = {};

      for (var path in paths) {
        final List<AssetEntity> assets = await path.getAssetListRange(
          start: 0,
          end: 1000,
        );

        for (var asset in assets) {
          if (seenIds.contains(asset.id)) continue;
          seenIds.add(asset.id);

          final file = await asset.file;
          if (file == null) continue;

          videos.add(MediaFile(
            id: asset.id,
            title: asset.title ?? 'Unknown Video',
            path: file.path,
            duration: asset.duration * 1000,
            size: await file.length(),
            type: MediaType.video,
            dateAdded: asset.createDateTime,
            thumbnailPath: asset.id,
          ));
        }
      }
      return videos.isEmpty ? sampleVideos : videos;
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      return sampleVideos;
    }
  }

  Future<List<MediaFolder>> fetchVideoFolders() async {
    if (kIsWeb) {
      return [
        MediaFolder(id: 'v_f1', name: 'Camera', path: '/storage/DCIM/Camera', mediaCount: 15, type: MediaType.video),
        MediaFolder(id: 'v_f2', name: 'WhatsApp Video', path: '/storage/WhatsApp Video', mediaCount: 24, type: MediaType.video),
        MediaFolder(id: 'v_f3', name: 'Screen Recorder', path: '/storage/Movies/ScreenRecorder', mediaCount: 7, type: MediaType.video),
        MediaFolder(id: 'v_f4', name: 'Movies', path: '/storage/Movies', mediaCount: 4, type: MediaType.video),
      ];
    }

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        return [
          MediaFolder(id: 'v_f1', name: 'Camera', path: '', mediaCount: 15, type: MediaType.video),
          MediaFolder(id: 'v_f2', name: 'WhatsApp Video', path: '', mediaCount: 24, type: MediaType.video),
        ];
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      final List<MediaFolder> folders = await Future.wait(paths.map((path) async {
        final count = await path.assetCountAsync;
        return MediaFolder(
          id: path.id,
          name: path.name,
          path: '',
          mediaCount: count,
          type: MediaType.video,
          firstMediaThumbnail: path.id,
        );
      }));
      return folders.isEmpty ? [
        MediaFolder(id: 'v_f1', name: 'Camera', path: '', mediaCount: 15, type: MediaType.video),
        MediaFolder(id: 'v_f2', name: 'WhatsApp Video', path: '', mediaCount: 24, type: MediaType.video),
      ] : folders;
    } catch (e) {
      debugPrint('Error fetching video folders: $e');
      return [
        MediaFolder(id: 'v_f1', name: 'Camera', path: '', mediaCount: 15, type: MediaType.video),
        MediaFolder(id: 'v_f2', name: 'WhatsApp Video', path: '', mediaCount: 24, type: MediaType.video),
      ];
    }
  }

  Future<List<MediaFile>> fetchAudioByAlbum(String albumId) async {
    if (kIsWeb) {
      return sampleSongs;
    }

    try {
      final List<SongModel> songs = await _audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM_ID,
        int.parse(albumId),
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        ignoreCase: true,
      );

      return songs.map((song) => MediaFile(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        path: song.data,
        duration: song.duration ?? 0,
        size: song.size,
        type: MediaType.audio,
        dateAdded: DateTime.fromMillisecondsSinceEpoch((song.dateAdded ?? 0) * 1000),
      )).toList();
    } catch (e) {
      return sampleSongs;
    }
  }

  Future<List<MediaFile>> fetchVideosByFolder(String folderId) async {
    if (kIsWeb) {
      return sampleVideos;
    }

    try {
      final path = await AssetPathEntity.fromId(folderId, type: RequestType.video);
      if (path == null) return sampleVideos;

      final assets = await path.getAssetListRange(start: 0, end: 1000);
      List<MediaFile> videos = [];
      for (var asset in assets) {
        final file = await asset.file;
        if (file == null) continue;
        videos.add(MediaFile(
          id: asset.id,
          title: asset.title ?? 'Unknown Video',
          path: file.path,
          duration: asset.duration * 1000,
          size: await file.length(),
          type: MediaType.video,
          dateAdded: asset.createDateTime,
          thumbnailPath: asset.id,
        ));
      }
      return videos.isEmpty ? sampleVideos : videos;
    } catch (e) {
      return sampleVideos;
    }
  }
}

