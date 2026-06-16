// lib/widgets/common_widgets.dart
// ─────────────────────────────────────────────────────────
// Reusable UI components shared across screens.
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/complaint.dart';
 
// ═══════════════════════════════════════════════════════
// GRADIENT BUTTON
// ═══════════════════════════════════════════════════════
class GradientButton extends StatelessWidget {
  final String   label;
  final VoidCallback? onPressed;
  final bool     isLoading;
  final IconData? icon;
 
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? const LinearGradient(
                  colors: [AppTheme.text3, AppTheme.text3])
              : brandGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor:     Colors.transparent,
            foregroundColor: AppTheme.bgBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.bgBase),
                  ))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                      style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppTheme.bgBase)),
                  ],
                ),
        ),
      ),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// GLASS CARD  — frosted-glass style card container
// ═══════════════════════════════════════════════════════
class GlassCard extends StatelessWidget {
  final Widget  child;
  final EdgeInsetsGeometry? padding;
  final Color?  borderColor;
  final VoidCallback? onTap;
 
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppTheme.accentDim,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor ?? AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// SECTION HEADER  — labelled section title
// ═══════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String? subtitle;
 
  const SectionHeader({
    super.key,
    required this.tag,
    required this.title,
    this.subtitle,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.amberDim,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.borderAccent),
          ),
          child: Text(tag,
            style: GoogleFonts.dmMono(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: AppTheme.amber, letterSpacing: 0.12)),
        ),
        const SizedBox(height: 6),
        Text(title,
          style: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text1)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!,
            style: GoogleFonts.dmMono(fontSize: 11, color: AppTheme.text3)),
        ],
      ],
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// URGENCY BADGE
// ═══════════════════════════════════════════════════════
class UrgencyBadge extends StatelessWidget {
  final String urgency;
 
  const UrgencyBadge(this.urgency, {super.key});
 
  Color get _color {
    switch (urgency) {
      case 'High':   return AppTheme.urgencyHigh;
      case 'Medium': return AppTheme.urgencyMedium;
      default:       return AppTheme.urgencyLow;
    }
  }
 
  String get _emoji {
    switch (urgency) {
      case 'High':   return '🔴';
      case 'Medium': return '🟡';
      default:       return '🟢';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text('$_emoji $urgency',
        style: GoogleFonts.outfit(
          fontSize: 11, fontWeight: FontWeight.w700, color: _color)),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// META TAG  — small info chip
// ═══════════════════════════════════════════════════════
class MetaTag extends StatelessWidget {
  final String text;
  final String? emoji;
 
  const MetaTag(this.text, {super.key, this.emoji});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text('${emoji ?? ''} $text'.trim(),
        style: GoogleFonts.dmMono(fontSize: 10, color: AppTheme.text2)),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// STAT CARD  — used in admin + dashboard
// ═══════════════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final String  value;
  final String  label;
  final IconData icon;
  final Color   color;
 
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                  style: GoogleFonts.dmMono(
                    fontSize: 22, fontWeight: FontWeight.w500, color: color)),
                const SizedBox(height: 2),
                Text(label,
                  style: GoogleFonts.outfit(
                    fontSize: 11, color: AppTheme.text3,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.06)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// SCORE BAR  — animated score progress bar
// ═══════════════════════════════════════════════════════
class ScoreBar extends StatelessWidget {
  final double score;
  final double maxScore;
 
  const ScoreBar({super.key, required this.score, required this.maxScore});
 
  @override
  Widget build(BuildContext context) {
    final frac = maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dynamic Score',
              style: GoogleFonts.dmMono(
                fontSize: 10, color: AppTheme.text3, letterSpacing: 0.06)),
            Text(score.toStringAsFixed(2),
              style: GoogleFonts.dmMono(
                fontSize: 15, fontWeight: FontWeight.w500,
                color: AppTheme.accent)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:            frac,
            minHeight:        5,
            backgroundColor:  AppTheme.bgRaised,
            valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
          ),
        ),
      ],
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// RANK MEDAL  — #1 🥇, #2 🥈, #3 🥉
// ═══════════════════════════════════════════════════════
class RankMedal extends StatelessWidget {
  final int rank;
 
  const RankMedal(this.rank, {super.key});
 
  String get _emoji {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }
 
  Color get _color {
    if (rank == 1) return AppTheme.rankGold;
    if (rank == 2) return AppTheme.rankSilver;
    if (rank == 3) return AppTheme.rankBronze;
    return AppTheme.text3;
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Center(
        child: rank <= 3
            ? Text(_emoji, style: const TextStyle(fontSize: 16))
            : Text('#$rank',
                style: GoogleFonts.dmMono(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _color)),
      ),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// CATEGORY PILL
// ═══════════════════════════════════════════════════════
class CategoryPill extends StatelessWidget {
  final String category;
 
  const CategoryPill(this.category, {super.key});
 
  String get _emoji {
    const map = {
      'Infrastructure': '🏗',
      'Sanitation':     '🗑',
      'Safety':         '🛡',
      'Utilities':      '💡',
      'Transport':      '🚌',
      'Environment':    '🌿',
      'Healthcare':     '🏥',
      'Education':      '📚',
      'Network':        '📡',
      'Food':           '🍔',
      'General':        '🗂',
    };
    return map[category] ?? '📌';
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: Text('$_emoji $category',
        style: GoogleFonts.dmMono(
          fontSize: 10, fontWeight: FontWeight.w500,
          color: AppTheme.accent)),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// EMPTY STATE WIDGET
// ═══════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
 
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(title,
              style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppTheme.text1)),
            const SizedBox(height: 8),
            Text(subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13, color: AppTheme.text3)),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
 
// ═══════════════════════════════════════════════════════
// COMPLAINT CARD  — used in lists
// ═══════════════════════════════════════════════════════
class ComplaintListCard extends StatefulWidget {
  final Complaint complaint;
  final int       rank;
  final double    maxScore;
  final VoidCallback? onTap;
  final Future<void> Function(int id)? onLike;
 
  const ComplaintListCard({
    super.key,
    required this.complaint,
    required this.rank,
    required this.maxScore,
    this.onTap,
    this.onLike,
  });
 
  @override
  State<ComplaintListCard> createState() => _ComplaintListCardState();
}
 
class _ComplaintListCardState extends State<ComplaintListCard>
    with SingleTickerProviderStateMixin {
  bool  _liking   = false;
  bool  _liked    = false;
  late AnimationController _bounce;
  late Animation<double>   _scale;
 
  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
    _scale  = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));
  }
 
  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }
 
  Future<void> _handleLike() async {
    if (_liking || widget.onLike == null) return;
    setState(() => _liking = true);
    _bounce.forward(from: 0);
    try {
      await widget.onLike!(widget.complaint.id);
      setState(() => _liked = true);
    } catch (_) {}
    setState(() => _liking = false);
  }
 
  // Urgency accent colour for the top border stripe
  Color get _urgencyColor {
    switch (widget.complaint.urgency) {
      case 'High':   return AppTheme.urgencyHigh;
      case 'Medium': return AppTheme.urgencyMedium;
      default:       return AppTheme.urgencyLow;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Urgency stripe on top
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(height: 3, color: _urgencyColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RankMedal(widget.rank),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                              style: GoogleFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppTheme.text1),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(c.description,
                              style: GoogleFonts.outfit(
                                fontSize: 12, color: AppTheme.text2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
 
                  const SizedBox(height: 12),
 
                  // Score bar
                  ScoreBar(score: c.score, maxScore: widget.maxScore),
 
                  const SizedBox(height: 12),
 
                  // Meta + Like row
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            UrgencyBadge(c.urgency),
                            CategoryPill(c.category),
                            MetaTag(c.location, emoji: '📍'),
                            if (c.timeAgo.isNotEmpty)
                              MetaTag(c.timeAgo, emoji: '🕐'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Like button
                      GestureDetector(
                        onTap: _handleLike,
                        child: AnimatedBuilder(
                          animation: _scale,
                          builder: (_, child) => Transform.scale(
                            scale: _scale.value, child: child),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: _liked
                                  ? AppTheme.accentDim
                                  : AppTheme.bgInput,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _liked
                                    ? AppTheme.accent
                                    : AppTheme.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _liking
                                  ? const SizedBox(
                                      width: 14, height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: AppTheme.accent))
                                  : Text('👍',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _liked
                                          ? AppTheme.accent
                                          : AppTheme.text2)),
                                const SizedBox(width: 5),
                                Text(
                                  '${c.likes + (_liked ? 1 : 0)}',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _liked
                                      ? AppTheme.accent
                                      : AppTheme.text2)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
 
            // Full-card tap
            if (widget.onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    splashColor: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}