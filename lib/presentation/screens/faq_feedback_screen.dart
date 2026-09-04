import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';

class FaqFeedbackScreen extends StatefulWidget {
  const FaqFeedbackScreen({super.key});

  @override
  State<FaqFeedbackScreen> createState() => _FaqFeedbackScreenState();
}

class _FaqFeedbackScreenState extends State<FaqFeedbackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  int _selectedRating = 5;
  String _selectedCategory = 'Playback';
  String _searchQuery = '';

  final List<Map<String, String>> _allFaqs = [
    {
      'category': 'Playback',
      'q': 'How do I resume video from where I left off?',
      'a': 'The app automatically saves your exact playback timestamp every few seconds. When you reopen any video, it will resume right where you stopped.'
    },
    {
      'category': 'Playback',
      'q': 'How does double-tap fast forward and rewind work?',
      'a': 'Double-tap on the right half of the video to jump forward +10 seconds, or double-tap on the left half to rewind -10 seconds. You can also swipe vertically for brightness and volume.'
    },
    {
      'category': 'Playback',
      'q': 'Can I switch audio tracks and stereo modes during video playback?',
      'a': 'Yes! Tap the Audio Track icon at the top of the video player to open the audio drawer where you can select tracks, toggle SW decoder, change stereo channels, or adjust audio sync delay.'
    },
    {
      'category': 'Storage',
      'q': 'How do I grant or revoke device storage access?',
      'a': 'Go to the Account tab or Settings screen and toggle the "Storage Access" switch. When denied, the app switches to safe mock media mode.'
    },
    {
      'category': 'Storage',
      'q': 'Does the app upload or scan any personal media?',
      'a': 'No! 100% of your media library is queried directly from local storage. No media files or personal logs are uploaded to external servers.'
    },
    {
      'category': 'Audio Engine',
      'q': 'Which audio and video codecs are supported?',
      'a': 'MP3, AAC, FLAC Lossless, WAV, OGG, M4A for audio; MP4, MKV, WebM, MOV, and AVI for video with hardware acceleration support.'
    },
    {
      'category': 'Audio Engine',
      'q': 'How do I activate the lockscreen media widget?',
      'a': 'Open the Lock Screen player from the Account tab or Quick Actions to view real-time time, date, track info, artwork, and playback controls.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'FAQ & Feedback',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryIndigo,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryIndigo,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [
            Tab(text: 'Help & FAQ', icon: FaIcon(FontAwesomeIcons.circleQuestion, size: 16)),
            Tab(text: 'Send Feedback', icon: FaIcon(FontAwesomeIcons.envelopeOpenText, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(isDark),
          _buildFeedbackTab(isDark),
        ],
      ),
    );
  }

  Widget _buildFaqTab(bool isDark) {
    final filteredFaqs = _allFaqs.where((f) {
      final matchesQuery = _searchQuery.isEmpty ||
          f['q']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f['a']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search help topics...',
              hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13.5),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 14, color: AppTheme.primaryIndigo),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Hero card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const FaIcon(FontAwesomeIcons.headset, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Extra Assistance?',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Browse our knowledge base or send our team feedback directly.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'POPULAR TOPICS (${filteredFaqs.length})',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppTheme.primaryIndigo,
          ),
        ),

        const SizedBox(height: 10),

        if (filteredFaqs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 36, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No questions found for "$_searchQuery"',
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        else
          ...filteredFaqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const FaIcon(FontAwesomeIcons.question, size: 12, color: AppTheme.primaryIndigo),
                    ),
                    title: Text(
                      faq['q']!,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Text(
                        faq['a']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          height: 1.5,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildFeedbackTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate Your Experience',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'How satisfied are you with this media player app?',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  final isFilled = starNum <= _selectedRating;
                  return IconButton(
                    iconSize: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: FaIcon(
                      isFilled ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                      color: isFilled ? const Color(0xFFF59E0B) : Colors.grey.withValues(alpha: 0.4),
                    ),
                    onPressed: () => setState(() => _selectedRating = starNum),
                  );
                }),
              ),
              const SizedBox(height: 20),

              Text(
                'Category',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Playback', 'Video Player', 'Audio Engine', 'UI/Design', 'Bug Report', 'Feature Request'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppTheme.primaryIndigo,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Text(
                'Your Message or Bug Details',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
                ),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Describe your issue, feedback, or suggestions in detail...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = _feedbackController.text.trim();
                    _feedbackController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        content: Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                text.isEmpty
                                    ? 'Thank you for your $_selectedRating-star rating!'
                                    : 'Feedback submitted successfully. Thank you for helping us improve!',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 14, color: Colors.white),
                  label: Text(
                    'Submit Feedback',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Quick Contacts
        Text(
          'DIRECT CHANNELS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppTheme.primaryIndigo,
          ),
        ),
        const SizedBox(height: 10),

        _buildContactTile(
          isDark: isDark,
          icon: FontAwesomeIcons.envelope,
          gradient: AppTheme.primaryGradient,
          title: 'Email Support',
          subtitle: 'support@cyberauroramedia.app',
        ),
        _buildContactTile(
          isDark: isDark,
          icon: FontAwesomeIcons.bug,
          gradient: AppTheme.violetCoralGradient,
          title: 'GitHub Issues',
          subtitle: 'github.com/imsalluu/flutter-media-player-app',
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required bool isDark,
    required dynamic icon,
    required Gradient gradient,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.cardBorderDark : AppTheme.cardBorderLight),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
          child: FaIcon(icon, color: Colors.white, size: 14),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5)),
        subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey)),
        trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title ($subtitle)...')),
          );
        },
      ),
    );
  }
}
