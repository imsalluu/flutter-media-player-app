import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'User Agreement',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
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
                  child: const FaIcon(FontAwesomeIcons.fileContract, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms of Service & Licensing',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last revised: September 2026 • v3.0 Pro',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSection(
            isDark: isDark,
            number: '1',
            title: 'Acceptance of Terms',
            content:
                'By downloading, installing, accessing, or using this Media Player application ("Software"), you agree to be bound by the terms and conditions set forth in this User Agreement. If you do not agree to these terms, please discontinue using the application immediately.',
          ),

          _buildSection(
            isDark: isDark,
            number: '2',
            title: 'Local Media Rights & Ownership',
            content:
                'All media content—including songs, playlists, podcasts, videos, subtitles, and artwork—played or indexed through this application remains the exclusive intellectual property of their respective copyright holders. This application acts solely as a client playback interface and does not claim ownership or rights to your media files.',
          ),

          _buildSection(
            isDark: isDark,
            number: '3',
            title: 'Device Access & Sandboxing',
            content:
                'The application requests local storage permission exclusively to enumerate and decode audio and video files found on your device. All playback indexing, state saving, and folder caching operations execute entirely in local sandboxed memory without third-party network telemetry.',
          ),

          _buildSection(
            isDark: isDark,
            number: '4',
            title: 'Hardware Acceleration & Codecs',
            content:
                'Software and Hardware audio/video decoding modules (including SW audio decoders, OpenGL/Vulkan rendering, and Chewie/ExoPlayer native pipelines) are provided "as-is" for optimal battery efficiency and ultra-low latency playback.',
          ),

          _buildSection(
            isDark: isDark,
            number: '5',
            title: 'Limitation of Liability',
            content:
                'Under no circumstances shall the developer or contributors be liable for any direct, indirect, incidental, or consequential damages resulting from the use or inability to use this media player software.',
          ),

          const SizedBox(height: 16),

          // Accept Action
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.emeraldCyanGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 16),
                        const SizedBox(width: 10),
                        Text('Agreement acknowledged. Thank you!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const FaIcon(FontAwesomeIcons.circleCheck, size: 16, color: Colors.white),
              label: Text(
                'I Understand & Accept',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String number,
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
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.55,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
