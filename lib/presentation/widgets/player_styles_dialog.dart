import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';

class PlayerStylesDialog {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Player Appearance Skins', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Choose your preferred vinyl turntable layout and visualizer style',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: Colors.grey)),
            const SizedBox(height: 20),
            _StyleOption(
              title: 'Classic Cyber Vinyl (Active)',
              subtitle: 'Rotating vinyl disc record with glowing ambient neon aura',
              isSelected: true,
              icon: FontAwesomeIcons.recordVinyl,
            ),
            _StyleOption(
              title: 'Glassmorphism Card',
              subtitle: 'Translucent frosted glass with dynamic aurora blur',
              isSelected: false,
              icon: FontAwesomeIcons.wandMagicSparkles,
            ),
            _StyleOption(
              title: 'Minimal Frequency Wave',
              subtitle: 'Clean geometric typography with live frequency bars',
              isSelected: false,
              icon: FontAwesomeIcons.waveSquare,
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final dynamic icon;

  const _StyleOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryIndigo.withValues(alpha: isDark ? 0.18 : 0.08)
            : (isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryIndigo : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: isSelected ? Colors.white : Colors.grey, size: 16),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey)),
        trailing: isSelected ? const FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.primaryIndigo, size: 18) : null,
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Applied style: $title')),
          );
        },
      ),
    );
  }
}
