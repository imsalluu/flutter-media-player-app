import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Security Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.violetCoralGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryViolet.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const FaIcon(FontAwesomeIcons.userShield, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Privacy is Absolute',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '100% Offline • Zero Remote Data Logging',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3 Privacy Highlights Cards
          Row(
            children: [
              Expanded(
                child: _buildHighlightCard(
                  isDark: isDark,
                  icon: FontAwesomeIcons.ban,
                  title: 'No Tracking',
                  desc: 'Zero telemetry & ads',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHighlightCard(
                  isDark: isDark,
                  icon: FontAwesomeIcons.hardDrive,
                  title: 'Local Only',
                  desc: 'Media stays on phone',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHighlightCard(
                  isDark: isDark,
                  icon: FontAwesomeIcons.lock,
                  title: 'Encrypted',
                  desc: 'Sandboxed state cache',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSection(
            isDark: isDark,
            icon: FontAwesomeIcons.folderTree,
            title: 'Storage & Media Permission',
            content:
                'We request access to device media (audio, video, photos/thumbnails) solely to populate your in-app library. No media file metadata, audio fingerprint, or file content is ever uploaded, indexed by third parties, or sent outside your device.',
          ),

          _buildSection(
            isDark: isDark,
            icon: FontAwesomeIcons.clockRotateLeft,
            title: 'Playback Position & Favorites Cache',
            content:
                'Saved timestamps (resume video where you stopped), recent track histories, equalizer presets, and favorites are stored strictly in local on-device key-value storage (SharedPreferences / Hive). Clearing app data will safely remove all saved states.',
          ),

          _buildSection(
            isDark: isDark,
            icon: FontAwesomeIcons.networkWired,
            title: 'Network & Internet Usage',
            content:
                'Network requests occur strictly when user explicitly plays an external stream URL or loads sample preview video streams on web demo mode. No background background beaconing or analytics tracking takes place.',
          ),

          _buildSection(
            isDark: isDark,
            icon: FontAwesomeIcons.shieldHalved,
            title: 'User Control & Revocation',
            content:
                'You retain complete control over your permissions. You can grant or revoke storage permissions at any time from the app Settings or through native OS App Settings.',
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required bool isDark,
    required dynamic icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
      ),
      child: Column(
        children: [
          FaIcon(icon, size: 16, color: AppTheme.primaryIndigo),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 3),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required dynamic icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.emeraldCyanGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, color: Colors.white, size: 13),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.55,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
