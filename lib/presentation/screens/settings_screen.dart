import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/providers/theme_provider.dart';
import 'package:media_player/presentation/screens/faq_feedback_screen.dart';
import 'package:media_player/presentation/screens/privacy_policy_screen.dart';
import 'package:media_player/presentation/screens/user_agreement_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final permissionGranted = ref.watch(permissionStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Settings',
          style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const _SectionHeader(title: 'DEVICE PERMISSION'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
              ),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: permissionGranted ? AppTheme.primaryGradient : AppTheme.violetCoralGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  permissionGranted ? FontAwesomeIcons.shieldHalved : FontAwesomeIcons.shieldCat,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: Text(
                'Storage Access',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
              subtitle: Text(
                permissionGranted ? 'Allowed (Full media access)' : 'Denied (Shows permission screen)',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
              ),
              value: permissionGranted,
              activeColor: AppTheme.primaryIndigo,
              inactiveThumbColor: AppTheme.primaryCoral,
              onChanged: (val) {
                ref.read(permissionStateProvider.notifier).togglePermission(val);
                if (!val) {
                  Navigator.pop(context);
                }
              },
            ),
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'APPEARANCE'),
          _SettingsTile(
            icon: FontAwesomeIcons.palette,
            gradient: AppTheme.violetCoralGradient,
            title: 'Theme Mode',
            subtitle: themeMode.name.toUpperCase(),
            onTap: () => _showThemeDialog(context, ref),
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'PLAYBACK & AUDIO ENGINE'),
          _SettingsSwitchTile(
            icon: FontAwesomeIcons.forwardFast,
            gradient: AppTheme.primaryGradient,
            title: 'Auto-play Next Track',
            subtitle: 'Play subsequent track automatically from queue',
            value: true,
            onChanged: (val) {},
          ),
          _SettingsSwitchTile(
            icon: FontAwesomeIcons.bolt,
            gradient: AppTheme.emeraldCyanGradient,
            title: 'Hi-Fi Hardware Acceleration',
            subtitle: 'Ultra-low latency audio & video decoding',
            value: true,
            onChanged: (val) {},
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'SUPPORT & LEGAL'),
          _SettingsTile(
            icon: FontAwesomeIcons.headset,
            gradient: AppTheme.amberCoralGradient,
            title: 'FAQ & Feedback',
            subtitle: 'Help center, answers & suggestions',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqFeedbackScreen()));
            },
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.fileContract,
            gradient: AppTheme.emeraldCyanGradient,
            title: 'User Agreement',
            subtitle: 'Terms of service and licensing',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAgreementScreen()));
            },
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.userShield,
            gradient: AppTheme.violetCoralGradient,
            title: 'Privacy Policy',
            subtitle: 'Device data safety and encryption',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
            },
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'ABOUT & CREATOR'),
          _SettingsTile(
            icon: FontAwesomeIcons.userAstronaut,
            gradient: AppTheme.primaryGradient,
            title: 'Made by Salman',
            subtitle: 'Senior Flutter Developer',
            onTap: () {},
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '3.0.0';
              return _SettingsTile(
                icon: FontAwesomeIcons.circleInfo,
                gradient: AppTheme.amberCoralGradient,
                title: 'App Version',
                subtitle: 'v$version (Cyber Aurora Pro)',
              );
            },
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.code,
            gradient: AppTheme.emeraldCyanGradient,
            title: 'Built with Flutter',
            subtitle: 'Next-Gen Cross-Platform Media Engine',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Theme', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const _ThemeOption(mode: ThemeMode.system, icon: FontAwesomeIcons.circleHalfStroke, label: 'System Default'),
            const _ThemeOption(mode: ThemeMode.light, icon: FontAwesomeIcons.sun, label: 'Light Mode'),
            const _ThemeOption(mode: ThemeMode.dark, icon: FontAwesomeIcons.moon, label: 'Dark Mode'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: AppTheme.primaryIndigo,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final dynamic icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.gradient, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: Colors.white, size: 14),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        trailing: onTap != null ? const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey) : null,
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final dynamic icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({required this.icon, required this.gradient, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight,
        ),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: Colors.white, size: 14),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        value: value,
        activeTrackColor: AppTheme.primaryIndigo.withValues(alpha: 0.5),
        activeThumbColor: AppTheme.primaryIndigo,
        onChanged: onChanged,
      ),
    );
  }
}

class _ThemeOption extends ConsumerWidget {
  final ThemeMode mode;
  final dynamic icon;
  final String label;

  const _ThemeOption({required this.mode, required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);
    final isSelected = currentMode == mode;

    return ListTile(
      leading: FaIcon(icon, color: isSelected ? AppTheme.primaryIndigo : Colors.grey, size: 18),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.primaryIndigo, size: 18) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
