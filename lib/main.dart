import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_player/core/services/audio_handler.dart';
import 'package:media_player/presentation/providers/audio_player_provider.dart';
import 'package:media_player/presentation/providers/theme_provider.dart';
import 'package:media_player/presentation/screens/main_screen.dart';

import 'core/theme/app_theme.dart';

late MyAudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.imsalluu.media_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(_audioHandler),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'EchoPlay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
