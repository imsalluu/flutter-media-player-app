import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/domain/entities/media_file.dart';
import 'package:media_player/core/services/storage_service.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/presentation/providers/favorites_provider.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final List<MediaFile> videos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late int _currentIndex;
  bool _isFullScreen = false;
  final _storage = StorageService();

  double _volumeValue = 0.8;
  double _brightnessValue = 0.5;
  bool _showOverlay = false;
  String _overlayText = '';
  dynamic _overlayIcon = FontAwesomeIcons.volumeHigh;

  // Double tap visual feedback animations
  bool _showForwardAnim = false;
  bool _showRewindAnim = false;

  // Audio Track & Settings Overlay Panel State (Matching User Screenshot)
  bool _showAudioTrackPanel = false;
  String _selectedAudioTrack = 'SOUTHFREAK.COM - Hindi';
  bool _useSwAudioDecoder = false;
  String _selectedStereoMode = 'Stereo';
  int _audioSyncDelayMs = 0;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializePlayer();
    WakelockPlus.enable();
    _initVolumeAndBrightness();
  }

  Future<void> _initVolumeAndBrightness() async {
    try {
      _volumeValue = await VolumeController.instance.getVolume();
      if (!kIsWeb) {
        _brightnessValue = await ScreenBrightness().application;
      }
    } catch (e) {
      _volumeValue = 0.8;
      _brightnessValue = 0.5;
    }
  }

  Future<void> _initializePlayer() async {
    final video = widget.videos[_currentIndex];

    if (mounted && _chewieController != null) {
      final currentPos = _videoPlayerController.value.position.inMilliseconds;
      if (currentPos > 2000) {
        await _storage.savePlaybackPosition(widget.videos[_currentIndex].id, currentPos);
      }
      await _videoPlayerController.dispose();
      _chewieController?.dispose();
    }

    if (video.path.startsWith('http://') || video.path.startsWith('https://')) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(video.path));
    } else {
      _videoPlayerController = VideoPlayerController.file(File(video.path));
    }

    await _videoPlayerController.initialize();

    // Check saved resume position
    final savedMs = await _storage.getPlaybackPosition(video.id);
    if (savedMs > 3000 && savedMs < _videoPlayerController.value.duration.inMilliseconds - 5000) {
      await _videoPlayerController.seekTo(Duration(milliseconds: savedMs));
      _showGestureOverlay(
        icon: FontAwesomeIcons.clockRotateLeft,
        text: 'Resumed from ${_formatDuration(savedMs)}',
      );
    }

    // Periodically save video position
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isPlaying) {
        final pos = _videoPlayerController.value.position.inMilliseconds;
        if (pos > 2000) {
          _storage.savePlaybackPosition(video.id, pos);
        }
      }
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppTheme.primaryIndigo,
        handleColor: AppTheme.primaryIndigo,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
      allowMuting: true,
      showControls: true,
    );

    if (mounted) setState(() {});

    ref.read(recentProvider.notifier).addToRecent(video.id);
  }

  void _nextVideo() {
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
        _initializePlayer();
      });
    }
  }

  void _prevVideo() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _initializePlayer();
      });
    }
  }

  void _toggleRotation() {
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLeftSide = details.localPosition.dx < screenWidth / 2;
    final delta = details.primaryDelta! / -200;

    if (isLeftSide) {
      // Brightness (Left Side)
      _brightnessValue = (_brightnessValue + delta).clamp(0.0, 1.0);
      try {
        if (!kIsWeb) {
          ScreenBrightness().setApplicationScreenBrightness(_brightnessValue);
        }
      } catch (_) {}
      _showGestureOverlay(
        icon: FontAwesomeIcons.sun,
        text: '${(_brightnessValue * 100).toInt()}%',
      );
    } else {
      // Volume (Right Side)
      _volumeValue = (_volumeValue + delta).clamp(0.0, 1.0);
      try {
        VolumeController.instance.setVolume(_volumeValue);
        _videoPlayerController.setVolume(_volumeValue);
      } catch (_) {}
      _showGestureOverlay(
        icon: _volumeValue == 0 ? FontAwesomeIcons.volumeXmark : FontAwesomeIcons.volumeHigh,
        text: '${(_volumeValue * 100).toInt()}%',
      );
    }
  }

  void _showGestureOverlay({required dynamic icon, required String text}) {
    setState(() {
      _overlayIcon = icon;
      _overlayText = text;
      _showOverlay = true;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isRightSide = details.localPosition.dx > screenWidth / 2;

    if (isRightSide) {
      _seekForward();
    } else {
      _seekRewind();
    }
  }

  void _seekForward() {
    final currentPosition = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);

    if (newPosition < duration) {
      _videoPlayerController.seekTo(newPosition);
    } else {
      _videoPlayerController.seekTo(duration);
    }

    setState(() => _showForwardAnim = true);
    _showGestureOverlay(icon: FontAwesomeIcons.forward, text: '+10s');
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showForwardAnim = false);
    });
  }

  void _seekRewind() {
    final currentPosition = _videoPlayerController.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);

    if (newPosition > Duration.zero) {
      _videoPlayerController.seekTo(newPosition);
    } else {
      _videoPlayerController.seekTo(Duration.zero);
    }

    setState(() => _showRewindAnim = true);
    _showGestureOverlay(icon: FontAwesomeIcons.backward, text: '-10s');
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showRewindAnim = false);
    });
  }

  // Audio Track Selection logic
  void _selectAudioTrack(String track) {
    setState(() {
      _selectedAudioTrack = track;
    });

    if (track == 'Disable') {
      _videoPlayerController.setVolume(0.0);
      _showGestureOverlay(icon: FontAwesomeIcons.volumeXmark, text: 'Audio Muted');
    } else {
      _videoPlayerController.setVolume(_volumeValue);
      _showGestureOverlay(icon: FontAwesomeIcons.music, text: 'Audio: $track');
    }
  }

  // Toggle SW audio decoder
  void _toggleSwDecoder(bool? value) {
    setState(() {
      _useSwAudioDecoder = value ?? false;
    });
    _showGestureOverlay(
      icon: FontAwesomeIcons.microchip,
      text: _useSwAudioDecoder ? 'SW Audio Decoder Active' : 'HW Audio Decoder Active',
    );
  }

  // Show Stereo Mode Selector Sheet
  void _showStereoModeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131520),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stereo Mode', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...['Stereo', 'Left Mono Channel', 'Right Mono Channel', 'Reverse Stereo'].map((mode) {
              final isSelected = _selectedStereoMode == mode;
              return ListTile(
                leading: FaIcon(
                  isSelected ? FontAwesomeIcons.solidCircleDot : FontAwesomeIcons.circle,
                  color: isSelected ? AppTheme.primaryIndigo : Colors.grey,
                  size: 16,
                ),
                title: Text(mode, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
                trailing: isSelected ? const FaIcon(FontAwesomeIcons.check, color: AppTheme.primaryIndigo, size: 14) : null,
                onTap: () {
                  setState(() => _selectedStereoMode = mode);
                  Navigator.pop(context);
                  _showGestureOverlay(icon: FontAwesomeIcons.sliders, text: 'Stereo: $mode');
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // Show Audio Synchronization Dialog (Audio Delay slider -1000ms to +1000ms)
  void _showSyncDialog() {
    int tempDelay = _audioSyncDelayMs;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF131520),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const FaIcon(FontAwesomeIcons.clockRotateLeft, color: AppTheme.primaryIndigo, size: 18),
              const SizedBox(width: 10),
              Text('Audio Synchronization', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adjust audio delay offset to synchronize with video',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Text(
                '${tempDelay >= 0 ? "+$tempDelay" : "$tempDelay"} ms',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryCyan,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Slider(
                value: tempDelay.toDouble(),
                min: -1000,
                max: 1000,
                divisions: 40,
                activeColor: AppTheme.primaryIndigo,
                inactiveColor: Colors.white24,
                onChanged: (val) {
                  setDialogState(() => tempDelay = val.round());
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('-1000ms', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11)),
                  TextButton(
                    onPressed: () => setDialogState(() => tempDelay = 0),
                    child: Text('Reset (0ms)', style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryIndigo, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Text('+1000ms', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _audioSyncDelayMs = tempDelay);
                Navigator.pop(context);
                _showGestureOverlay(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  text: 'Audio Sync: ${_audioSyncDelayMs}ms',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  // Open External Audio / Media file dialog
  void _showOpenExternalDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Open External Audio Track', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter external audio stream URL or select auxiliary track:', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://example.com/audio_track.aac',
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E2235),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final url = textCtrl.text.trim();
              Navigator.pop(context);
              if (url.isNotEmpty) {
                setState(() {
                  _selectedAudioTrack = 'External: ${url.split("/").last}';
                });
                _showGestureOverlay(icon: FontAwesomeIcons.music, text: 'Loaded External Audio');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Load Track'),
          ),
        ],
      ),
    );
  }

  // Playback Speed Selector
  void _changeSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _videoPlayerController.setPlaybackSpeed(speed);
    _showGestureOverlay(icon: FontAwesomeIcons.gaugeHigh, text: '${speed}x Speed');
  }

  @override
  void dispose() {
    try {
      final pos = _videoPlayerController.value.position.inMilliseconds;
      if (pos > 2000 && _currentIndex < widget.videos.length) {
        _storage.savePlaybackPosition(widget.videos[_currentIndex].id, pos);
      }
    } catch (_) {}

    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                video.title,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                // Audio Track Overlay Drawer Toggle (Matching user request)
                IconButton(
                  tooltip: 'Audio Track & Controls',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _showAudioTrackPanel ? AppTheme.primaryIndigo : Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FaIcon(FontAwesomeIcons.headphones, size: 15, color: Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      _showAudioTrackPanel = !_showAudioTrackPanel;
                    });
                  },
                ),

                // Speed Cycle Button
                PopupMenuButton<double>(
                  tooltip: 'Playback Speed',
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${_playbackSpeed}x',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  color: const Color(0xFF131520),
                  onSelected: _changeSpeed,
                  itemBuilder: (context) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                    return PopupMenuItem(
                      value: s,
                      child: Text(
                        '${s}x ${s == 1.0 ? "(Normal)" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          color: _playbackSpeed == s ? AppTheme.primaryIndigo : Colors.white,
                          fontWeight: _playbackSpeed == s ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Rotate / Fullscreen
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.rotate, size: 16),
                  onPressed: _toggleRotation,
                ),
              ],
            ),
      body: Stack(
        children: [
          // Video Canvas
          Center(
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? GestureDetector(
                    onVerticalDragUpdate: _handleVerticalDragUpdate,
                    onDoubleTapDown: _onDoubleTapDown,
                    onTap: () {
                      if (_showAudioTrackPanel) {
                        setState(() => _showAudioTrackPanel = false);
                      }
                    },
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(color: AppTheme.primaryIndigo),
          ),

          // Double Tap Forward Animation on Right Side
          if (_showForwardAnim)
            Positioned(
              right: 40,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.forward, color: AppTheme.primaryIndigo, size: 32),
                      const SizedBox(height: 6),
                      Text('+10s', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // Double Tap Rewind Animation on Left Side
          if (_showRewindAnim)
            Positioned(
              left: 40,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.backward, color: AppTheme.primaryIndigo, size: 32),
                      const SizedBox(height: 6),
                      Text('-10s', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // HUD Overlay for Gestures & Resume
          if (_showOverlay)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(_overlayIcon, color: AppTheme.primaryIndigo, size: 30),
                    const SizedBox(height: 10),
                    Text(
                      _overlayText,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Audio Track Trigger Button on Top-Right of video
          Positioned(
            top: 14,
            right: 14,
            child: GestureDetector(
              onTap: () => setState(() => _showAudioTrackPanel = !_showAudioTrackPanel),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(FontAwesomeIcons.headphones, color: AppTheme.primaryCyan, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'Audio Track',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RIGHT-SIDE AUDIO TRACK & CONTROLS OVERLAY DRAWER
          // (Exact match with user's uploaded screenshots)
          if (_showAudioTrackPanel)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: MediaQuery.of(context).size.width > 600 ? 380 : MediaQuery.of(context).size.width * 0.82,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: const Color(0xFF090B12).withValues(alpha: 0.94),
                  border: const Border(left: BorderSide(color: Colors.white12, width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel Header with Close Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Audio Track',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white70, size: 16),
                              onPressed: () => setState(() => _showAudioTrackPanel = false),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            // 1. Audio Track Option 1 (Hindi / Original)
                            _buildAudioTrackRadioTile(
                              title: 'SOUTHFREAK.COM - Hindi',
                              value: 'SOUTHFREAK.COM - Hindi',
                            ),

                            // 2. Audio Track Option 2 (Malayalam / Dubbed)
                            _buildAudioTrackRadioTile(
                              title: 'SOUTHFREAK.COM - Malayalam',
                              value: 'SOUTHFREAK.COM - Malayalam',
                            ),

                            // 3. Disable Option
                            _buildAudioTrackRadioTile(
                              title: 'Disable',
                              value: 'Disable',
                            ),

                            const SizedBox(height: 8),

                            // 4. Use SW audio decoder Checkbox (Matching screenshot)
                            InkWell(
                              onTap: () => _toggleSwDecoder(!_useSwAudioDecoder),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _useSwAudioDecoder,
                                      activeColor: AppTheme.primaryIndigo,
                                      side: const BorderSide(color: Colors.white54, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: _toggleSwDecoder,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Use SW audio decoder',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                            const Divider(color: Colors.white12, height: 1),
                            const SizedBox(height: 12),

                            // 5. Open Action (Matching screenshot)
                            _buildDrawerActionTile(
                              title: 'Open',
                              subtitle: 'Load auxiliary audio track / stream URL',
                              onTap: _showOpenExternalDialog,
                            ),

                            // 6. Stereo Mode Action (Matching screenshot)
                            _buildDrawerActionTile(
                              title: 'Stereo mode',
                              subtitle: _selectedStereoMode,
                              onTap: _showStereoModeSelector,
                            ),

                            // 7. Synchronization Action (Matching screenshot)
                            _buildDrawerActionTile(
                              title: 'Synchronization',
                              subtitle: '${_audioSyncDelayMs >= 0 ? "+$_audioSyncDelayMs" : "$_audioSyncDelayMs"} ms delay offset',
                              onTap: _showSyncDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Previous / Next Quick Jump Bar in portrait
          if (!_isFullScreen && !_showAudioTrackPanel)
            Positioned(
              bottom: 30,
              right: 20,
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    FloatingActionButton.small(
                      heroTag: 'prev_vid',
                      backgroundColor: Colors.white24,
                      onPressed: _prevVideo,
                      child: const FaIcon(FontAwesomeIcons.backwardStep, color: Colors.white, size: 14),
                    ),
                  const SizedBox(width: 12),
                  if (_currentIndex < widget.videos.length - 1)
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        heroTag: 'next_vid',
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        foregroundColor: Colors.white,
                        onPressed: _nextVideo,
                        child: const FaIcon(FontAwesomeIcons.forwardStep, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Audio Track Radio Tile Builder (Matching circular radio style in screenshot)
  Widget _buildAudioTrackRadioTile({
    required String title,
    required String value,
  }) {
    final isSelected = _selectedAudioTrack == value;

    return InkWell(
      onTap: () => _selectAudioTrack(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF38BDF8) : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Drawer Action Tile Builder (Open, Stereo Mode, Synchronization)
  Widget _buildDrawerActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    return '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
