import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_player/core/theme/app_theme.dart';
import 'package:media_player/presentation/providers/media_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(mediaFilterProvider);
    final filterNotifier = ref.read(mediaFilterProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10121B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? const Color(0xFF222638) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with Active Count & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.sliders,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter & Sort Library',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (filterState.activeFiltersCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filterState.activeFiltersCount}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton.icon(
                onPressed: () => filterNotifier.resetFilters(),
                icon: const FaIcon(FontAwesomeIcons.rotateLeft, size: 13, color: Colors.grey),
                label: Text(
                  'Reset',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 1. Sort By Section
          Text(
            'SORT BY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip(
                      context,
                      label: 'Date Added',
                      icon: FontAwesomeIcons.calendarDay,
                      field: SortField.dateAdded,
                      current: filterState.sortField,
                      onSelect: () => filterNotifier.setSortField(SortField.dateAdded),
                    ),
                    _buildSortChip(
                      context,
                      label: 'Title Name',
                      icon: FontAwesomeIcons.arrowDownAZ,
                      field: SortField.name,
                      current: filterState.sortField,
                      onSelect: () => filterNotifier.setSortField(SortField.name),
                    ),
                    _buildSortChip(
                      context,
                      label: 'Duration',
                      icon: FontAwesomeIcons.stopwatch,
                      field: SortField.duration,
                      current: filterState.sortField,
                      onSelect: () => filterNotifier.setSortField(SortField.duration),
                    ),
                    _buildSortChip(
                      context,
                      label: 'File Size',
                      icon: FontAwesomeIcons.hardDrive,
                      field: SortField.size,
                      current: filterState.sortField,
                      onSelect: () => filterNotifier.setSortField(SortField.size),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Order button (Asc / Desc)
              IconButton(
                tooltip: filterState.sortOrder == SortOrder.ascending ? 'Ascending' : 'Descending',
                onPressed: () => filterNotifier.toggleSortOrder(),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(12),
                ),
                icon: FaIcon(
                  filterState.sortOrder == SortOrder.ascending
                      ? FontAwesomeIcons.arrowUpWideShort
                      : FontAwesomeIcons.arrowDownShortWide,
                  color: AppTheme.primaryIndigo,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 2. Duration Filter
          Text(
            'DURATION RANGE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDurationChip(
                context,
                label: 'All Lengths',
                value: DurationFilter.all,
                current: filterState.durationFilter,
                onSelect: () => filterNotifier.setDurationFilter(DurationFilter.all),
              ),
              _buildDurationChip(
                context,
                label: '< 1 min (Shorts)',
                value: DurationFilter.under1Min,
                current: filterState.durationFilter,
                onSelect: () => filterNotifier.setDurationFilter(DurationFilter.under1Min),
              ),
              _buildDurationChip(
                context,
                label: '1 - 5 mins (Standard)',
                value: DurationFilter.oneToFiveMins,
                current: filterState.durationFilter,
                onSelect: () => filterNotifier.setDurationFilter(DurationFilter.oneToFiveMins),
              ),
              _buildDurationChip(
                context,
                label: '> 5 mins (Extended)',
                value: DurationFilter.overFiveMins,
                current: filterState.durationFilter,
                onSelect: () => filterNotifier.setDurationFilter(DurationFilter.overFiveMins),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 3. Format / Type Filter
          Text(
            'FORMAT & EXTENSION',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFormatChip(
                context,
                label: 'All Formats',
                value: FormatFilter.all,
                current: filterState.formatFilter,
                onSelect: () => filterNotifier.setFormatFilter(FormatFilter.all),
              ),
              _buildFormatChip(
                context,
                label: 'MP3 Audio',
                value: FormatFilter.mp3,
                current: filterState.formatFilter,
                onSelect: () => filterNotifier.setFormatFilter(FormatFilter.mp3),
              ),
              _buildFormatChip(
                context,
                label: 'MP4 Video',
                value: FormatFilter.mp4,
                current: filterState.formatFilter,
                onSelect: () => filterNotifier.setFormatFilter(FormatFilter.mp4),
              ),
              _buildFormatChip(
                context,
                label: 'FLAC Lossless',
                value: FormatFilter.flac,
                current: filterState.formatFilter,
                onSelect: () => filterNotifier.setFormatFilter(FormatFilter.flac),
              ),
              _buildFormatChip(
                context,
                label: 'WAV Studio',
                value: FormatFilter.wav,
                current: filterState.formatFilter,
                onSelect: () => filterNotifier.setFormatFilter(FormatFilter.wav),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Apply Button with Gradient
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.circleCheck, size: 16, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Apply Filter & Sort',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required dynamic icon,
    required SortField field,
    required SortField current,
    required VoidCallback onSelect,
  }) {
    final isSelected = field == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      avatar: FaIcon(
        icon,
        size: 13,
        color: isSelected ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF64748B)),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
      ),
      backgroundColor: isDark ? const Color(0xFF191D2C) : const Color(0xFFF1F5F9),
      selectedColor: AppTheme.primaryIndigo,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryIndigo
              : (isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildDurationChip(
    BuildContext context, {
    required String label,
    required DurationFilter value,
    required DurationFilter current,
    required VoidCallback onSelect,
  }) {
    final isSelected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
      ),
      backgroundColor: isDark ? const Color(0xFF191D2C) : const Color(0xFFF1F5F9),
      selectedColor: AppTheme.primaryIndigo,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryIndigo
              : (isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildFormatChip(
    BuildContext context, {
    required String label,
    required FormatFilter value,
    required FormatFilter current,
    required VoidCallback onSelect,
  }) {
    final isSelected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
      ),
      backgroundColor: isDark ? const Color(0xFF191D2C) : const Color(0xFFF1F5F9),
      selectedColor: AppTheme.primaryIndigo,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryIndigo
              : (isDark ? const Color(0xFF262C40) : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
