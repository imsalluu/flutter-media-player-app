import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/presentation/screens/faq_feedback_screen.dart';
import 'package:media_player/presentation/screens/privacy_policy_screen.dart';
import 'package:media_player/presentation/screens/user_agreement_screen.dart';

class InfoDialogs {
  static void showFaqDialog(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqFeedbackScreen()));
  }

  static void showAgreementDialog(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAgreementScreen()));
  }

  static void showPrivacyDialog(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
  }

  static void showWidgetInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: const FaIcon(FontAwesomeIcons.shapes, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 12),
            Text('Home Widget', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          'To add the EchoPlay widget to your device home screen:\n\n'
          '1. Long-press on any empty space on your home screen.\n'
          '2. Tap "Widgets".\n'
          '3. Locate "EchoPlay" and drag the widget to your desired position.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.6, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryIndigo, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
