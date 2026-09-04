# ⚡ Cyber Aurora Media Player

A state-of-the-art, ultra-premium offline media player built with **Flutter**. Engineered with an **Electric Indigo & Neon Cyan Cyber Aurora** aesthetic, **Google Fonts typography**, and **FontAwesome Icons**, it delivers an unmatched audio and video experience for mobile, web, and desktop.

> **Crafted with passion • Made by Salman**

---

## ✨ Key Features & Architecture

### 🎬 Advanced Video Player Engine
- **Right-Side Audio Track Overlay Drawer**: Slide-in translucent panel for real-time audio track switching (Original / Dubbed / Mute).
- **SW / HW Audio Decoder Toggle**: Switch between software and hardware audio decoders on the fly.
- **Audio Synchronization**: Real-time interactive audio delay sync slider (-1000ms to +1000ms) with instant seek offset.
- **Stereo Mode Channel Selector**: Toggle Stereo, Left Mono Channel, Right Mono Channel, and Reverse Stereo.
- **External Track Loader**: Load auxiliary external audio tracks or live stream URLs directly into playback.
- **Gesture Controls**:
  - Double-tap right side for **+10s Fast-Forward** with animated visual feedback.
  - Double-tap left side for **-10s Rewind** with animated visual feedback.
  - Vertical swipe on the left for **Brightness adjustment**.
  - Vertical swipe on the right for **Volume control**.
- **Playback State Persistence**: Automatically resumes videos at the exact millisecond where you left off across app restarts.
- **Variable Playback Speed**: 0.5x, 0.75x, 1.0x (Normal), 1.25x, 1.5x, and 2.0x.
- **Orientation & Fullscreen**: Smooth orientation lock and landscape switching.

---

### 🎵 Hi-Fi Audio Player & Turntable
- **Cyber Vinyl Turntable**: Spinning vinyl disc record visualizer with glowing ambient aurora aura.
- **Background Audio Service**: Seamless background audio playback with lock screen media notifications.
- **Player Skin Customization**: Choose between Classic Cyber Vinyl, Glassmorphism Card, and Minimal Frequency Wave.
- **Interactive Equalizer**: Multi-band frequency equalizer presets (Rock, Pop, Bass Boost, Jazz, Vocal).
- **Favorites & Recent Tracks**: Instant bookmarking and recent playback tracking.

---

### 📱 Lock Screen Media Widget
- **Live Lock Screen Card**: Real-time live digital clock and date display matching modern OS lockscreen widgets.
- **Full Media Controls**: Track details, album artwork, interactive seek slider, previous/next and play/pause controls.
- **Swipe-up to Unlock**: Intuitive upward swipe gesture with responsive physics to unlock into the main player.

---

### 📂 Folder-Wise Media Library & Filtering
- **3-Tab Bottom Navigation Bar**:
  1. `My music`: Quick Cards (Favourites, Playlists, Recent), Sub-tabs (Songs, Videos, Artists, Albums, Folders), and Shuffle action bar.
  2. `Videos`: Dual mode viewing — **Folder Hierarchy** drilldown and switch to **All Videos** library with duration & size badges.
  3. `Account`: Storage access toggle, Theme switcher, Equalizer, FAQ, User Agreement, Privacy Policy, and "Made by Salman" developer profile.
- **Comprehensive Filter & Sort Bottom Sheet**:
  - **Sort By**: Date Added, Title Name, Duration, File Size (Ascending / Descending order toggle).
  - **Duration Filter**: All, < 1 min, 1 - 5 mins, > 5 mins.
  - **Format Filter**: All, MP3, MP4, WAV, FLAC, AAC, M4A, MKV.

---

### 🛡️ Dedicated Support & Legal Screens
- **[FAQ & Feedback Screen](file:///lib/presentation/screens/faq_feedback_screen.dart)**:
  - Searchable interactive FAQ knowledge base with categorized accordion questions.
  - 1-5 star user satisfaction rating selector.
  - Category selector chips and rich feedback message submission with confirmation toast.
  - Direct support channels (Email Support, GitHub issues).
- **[User Agreement Screen](file:///lib/presentation/screens/user_agreement_screen.dart)**:
  - Clear sections covering Terms of Service, Local Media Ownership Rights, Hardware Acceleration & Codecs, and Liability.
- **[Privacy Policy Screen](file:///lib/presentation/screens/privacy_policy_screen.dart)**:
  - 100% Offline & Sandboxed: Zero analytics tracking, no third-party telemetry, local device caching, and permission revocation management.

---

## 🛠️ Technology Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart 3.x) |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) |
| **Audio Engine** | `just_audio` & `audio_service` |
| **Video Engine** | `video_player` & `chewie` |
| **Icons** | `font_awesome_flutter` |
| **Typography** | `google_fonts` (Plus Jakarta Sans) |
| **Local Persistence** | `shared_preferences` |
| **Device Services** | `screen_brightness`, `volume_controller`, `wakelock_plus` |
| **Media Scanning** | `on_audio_query`, `photo_manager` |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24.x or newer)
- Android Studio / VS Code with Flutter extensions
- Android device or Emulator (or Chrome for web testing)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/imsalluu/flutter-media-player-app.git
   cd flutter-media-player-app
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Connected Device / Emulator**:
   ```bash
   flutter run
   ```

4. **Run on Web Server (Port 8080)**:
   ```bash
   flutter run -d web-server --web-port 8080 --web-hostname 127.0.0.1
   ```

---

## 🔐 Android Permissions

The app requests appropriate media permissions to discover and decode files safely:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

*Note: Storage permission can be simulated and toggled directly inside the app.*

---

## 🎨 Theme & Typography

- **Primary Colors**: Electric Indigo (`#6366F1`), Neon Cyan (`#06B6D4`), Cyber Violet (`#8B5CF6`), Cyber Coral (`#FF3366`).
- **Dark Theme**: Deep Obsidian (`#090A10`), Dark Slate Card (`#131520`), Fine Border (`#222638`).
- **Font Family**: [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans) via `google_fonts`.

---

## 👨‍💻 Developer & Credits

Designed and developed by **Salman** (`imsalluu`).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
