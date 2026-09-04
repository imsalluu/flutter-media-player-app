import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_player/presentation/providers/media_provider.dart';
import 'package:media_player/presentation/screens/faq_feedback_screen.dart';
import 'package:media_player/presentation/screens/privacy_policy_screen.dart';
import 'package:media_player/presentation/screens/settings_screen.dart';
import 'package:media_player/presentation/screens/user_agreement_screen.dart';
import 'package:media_player/presentation/widgets/info_dialogs.dart';
import 'package:media_player/presentation/widgets/player_styles_dialog.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _autoUpdate = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permissionGranted = ref.watch(permissionStateProvider);

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF18181A) : Colors.white,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.78,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header: Profile Avatar + Xiaomi Account text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEEEEF0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 28,
                      color: isDark ? Colors.white70 : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Xiaomi Account',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Divider(color: isDark ? Colors.white10 : const Color(0xFFF0F0F2), height: 1),
            const SizedBox(height: 8),

            // Top Menu Items matching Screenshot 1
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.hexagon_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'FAQ & feedback',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FaqFeedbackScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.article_outlined,
                    title: 'User Agreement',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserAgreementScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Divider(color: isDark ? Colors.white10 : const Color(0xFFF0F0F2), height: 1),
                  ),

                  // Bottom Menu Items matching Screenshot 1
                  _DrawerItem(
                    icon: Icons.sync_rounded,
                    title: 'Update automatically',
                    trailing: Switch(
                      value: _autoUpdate,
                      activeColor: const Color(0xFFFF003A),
                      onChanged: (val) {
                        setState(() => _autoUpdate = val);
                      },
                    ),
                    onTap: () {
                      setState(() => _autoUpdate = !_autoUpdate);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.checkroom_outlined,
                    title: 'Player styles',
                    onTap: () {
                      Navigator.pop(context);
                      PlayerStylesDialog.show(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.widgets_outlined,
                    title: 'Home screen widget',
                    onTap: () {
                      Navigator.pop(context);
                      InfoDialogs.showWidgetInfoDialog(context);
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Divider(color: isDark ? Colors.white10 : const Color(0xFFF0F0F2), height: 1),
                  ),

                  // Device Storage Permission Toggle (Requested by user)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222226) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: permissionGranted 
                            ? const Color(0xFF1B7575).withOpacity(0.3)
                            : const Color(0xFFFF003A).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          permissionGranted ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
                          color: permissionGranted ? const Color(0xFF1B7575) : const Color(0xFFFF003A),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Device Access',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                permissionGranted ? 'Permission Allowed' : 'Permission Denied',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: permissionGranted ? const Color(0xFF1B7575) : const Color(0xFFFF003A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: permissionGranted,
                          activeColor: const Color(0xFF1B7575),
                          inactiveThumbColor: const Color(0xFFFF003A),
                          onChanged: (val) {
                            ref.read(permissionStateProvider.notifier).togglePermission(val);
                            if (!val) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(
        icon,
        size: 24,
        color: isDark ? Colors.white70 : const Color(0xFF2C2C2E),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1F1F1F),
        ),
      ),
      trailing: trailing,
    );
  }
}
