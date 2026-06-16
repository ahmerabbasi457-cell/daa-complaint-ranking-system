// lib/screens/dashboard_screen.dart
// ─────────────────────────────────────────────────────────
// Main dashboard — bottom nav with 3 tabs:
//   0: Top-K Rankings  (complaint list)
//   1: Submit           (submit form)
//   2: Admin            (admin analytics)
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/complaint.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
import 'submit_complaint_screen.dart';
import 'admin_dashboard_screen.dart';
import 'complaint_detail_screen.dart';
 
class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});
 
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
 
class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;
  List<Complaint> _complaints = [];
  bool   _loading = true;
  String _error   = '';
  bool   _online  = false;
 
  // Filters
  String _filterUrgency  = '';
  String _filterCategory = '';
 
  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }
 
  Future<void> _loadComplaints({bool silent = false}) async {
    if (!silent) setState(() { _loading = true; _error = ''; });
    try {
      final data = await ApiService.getComplaints();
      final ping = await ApiService.ping();
      if (!mounted) return;
      setState(() {
        _complaints = data;
        _loading    = false;
        _online     = ping;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error   = e.toString();
        _online  = false;
      });
    }
  }
 
  Future<void> _likeComplaint(int id) async {
    await ApiService.likeComplaint(id);
    _loadComplaints(silent: true);
  }
 
  List<Complaint> get _filtered {
    return _complaints.where((c) {
      final uMatch = _filterUrgency.isEmpty  || c.urgency  == _filterUrgency;
      final cMatch = _filterCategory.isEmpty || c.category == _filterCategory;
      return uMatch && cMatch;
    }).toList();
  }
 
  double get _maxScore =>
      _complaints.isEmpty ? 1
      : _complaints.map((c) => c.score).reduce((a, b) => a > b ? a : b);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: _currentTab == 0 ? _buildAppBar() : null,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildRankingsTab(),
          SubmitComplaintScreen(
            onSubmitted: () {
              setState(() => _currentTab = 0);
              _loadComplaints();
            },
          ),
          AdminDashboardScreen(
            complaints: _complaints,
            onRefresh: _loadComplaints,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
 
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.bgSurface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top-K Rankings',
            style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.text1)),
          Text('Heap-sorted · Time-decayed',
            style: GoogleFonts.dmMono(fontSize: 10, color: AppTheme.text3)),
        ],
      ),
      actions: [
        // Backend status dot
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Center(
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _online ? AppTheme.urgencyLow : AppTheme.urgencyHigh,
                boxShadow: [BoxShadow(
                  color: (_online ? AppTheme.urgencyLow : AppTheme.urgencyHigh)
                      .withOpacity(0.5),
                  blurRadius: 6,
                )],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppTheme.text2),
          onPressed: _loadComplaints,
          tooltip: 'Refresh',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentDim,
              child: Text(
                widget.username.isNotEmpty
                    ? widget.username[0].toUpperCase() : 'U',
                style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppTheme.accent)),
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildRankingsTab() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.accent),
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text('Fetching ranked complaints…',
              style: TextStyle(color: AppTheme.text3, fontSize: 13)),
          ],
        ),
      );
    }
 
    if (_error.isNotEmpty) {
      return EmptyState(
        emoji: '⚠️',
        title: 'Backend Unreachable',
        subtitle: 'Make sure Flask is running on port 5000.\n$_error',
        onRetry: _loadComplaints,
      );
    }
 
    final filtered = _filtered;
 
    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.bgCard,
      onRefresh: _loadComplaints,
      child: CustomScrollView(
        slivers: [
          // Stat strip
          SliverToBoxAdapter(child: _buildStatStrip()),
 
          // Filters
          SliverToBoxAdapter(child: _buildFilters()),
 
          // List
          if (filtered.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                emoji: '📭',
                title: 'No Complaints Found',
                subtitle: 'Submit a complaint or adjust your filters.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ComplaintListCard(
                    complaint: filtered[i],
                    rank:      i + 1,
                    maxScore:  _maxScore,
                    onLike:    _likeComplaint,
                    onTap: () => Navigator.push(ctx,
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailScreen(
                          complaint: filtered[i],
                          rank:      i + 1,
                          maxScore:  _maxScore,
                          onLike:    _likeComplaint,
                        ))),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
 
  Widget _buildStatStrip() {
    final total   = _complaints.length;
    final high    = _complaints.where((c) => c.urgency == 'High').length;
    final topScore = total > 0
        ? _complaints.map((c) => c.score).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final cats    = _complaints.map((c) => c.category).toSet().length;
 
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          StatCard(
            value: '$total',
            label: 'TOTAL COMPLAINTS',
            icon:  Icons.article_outlined,
            color: AppTheme.accent,
          ),
          StatCard(
            value: '$high',
            label: 'HIGH URGENCY',
            icon:  Icons.local_fire_department_outlined,
            color: AppTheme.urgencyHigh,
          ),
          StatCard(
            value: topScore.toStringAsFixed(1),
            label: 'TOP SCORE',
            icon:  Icons.leaderboard_outlined,
            color: AppTheme.amber,
          ),
          StatCard(
            value: '$cats',
            label: 'CATEGORIES',
            icon:  Icons.category_outlined,
            color: AppTheme.clusterColor,
          ),
        ],
      ),
    );
  }
 
  Widget _buildFilters() {
    final urgencies  = ['', 'High', 'Medium', 'Low'];
    final categories = ['', ..._complaints.map((c) => c.category).toSet()];
 
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _DropdownFilter(
              label: 'Urgency',
              value: _filterUrgency,
              items: urgencies,
              onChanged: (v) => setState(() => _filterUrgency = v!),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DropdownFilter(
              label: 'Category',
              value: _filterCategory,
              items: categories,
              onChanged: (v) => setState(() => _filterCategory = v!),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(
          fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Rankings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
 
// ── Filter dropdown ─────────────────────────────────────
class _DropdownFilter extends StatelessWidget {
  final String   label;
  final String   value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
 
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.bgCard,
          style: GoogleFonts.outfit(
            fontSize: 12, color: AppTheme.text1),
          hint: Text(label,
            style: GoogleFonts.outfit(
              fontSize: 12, color: AppTheme.text3)),
          icon: const Icon(Icons.keyboard_arrow_down,
            color: AppTheme.text3, size: 18),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item.isEmpty ? 'All $label' : item,
              style: GoogleFonts.outfit(
                fontSize: 12, color: AppTheme.text1)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}