// lib/screens/submit_complaint_screen.dart
// ─────────────────────────────────────────────────────────
// Form to submit a new complaint to Flask backend.
// POST /submit-complaint
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';
 
class SubmitComplaintScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;
  const SubmitComplaintScreen({super.key, this.onSubmitted});
 
  @override
  State<SubmitComplaintScreen> createState() =>
      _SubmitComplaintScreenState();
}
 
class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _locationCtrl= TextEditingController();
 
  String _category = 'General';
  String _urgency  = 'Medium';
  bool   _loading  = false;
 
  static const _categories = [
    'Infrastructure', 'Sanitation', 'Safety', 'Utilities',
    'Transport', 'Environment', 'Healthcare', 'Education',
    'Network', 'Food', 'General', 'Other',
  ];
 
  static const _urgencies = ['Low', 'Medium', 'High'];
 
  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
 
    try {
      await ApiService.submitComplaint(
        title:       _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category:    _category,
        urgency:     _urgency,
        location:    _locationCtrl.text.trim(),
      );
 
      if (!mounted) return;
      _showSuccess();
      _formKey.currentState!.reset();
      _titleCtrl.clear();
      _descCtrl.clear();
      _locationCtrl.clear();
      setState(() { _category = 'General'; _urgency = 'Medium'; });
      widget.onSubmitted?.call();
 
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
 
  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.urgencyLow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Text('✓', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Complaint submitted & ranked!',
                style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
 
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.urgencyHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Text('✕', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Error: $msg',
                style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
 
  Color get _urgencyColor {
    switch (_urgency) {
      case 'High':   return AppTheme.urgencyHigh;
      case 'Medium': return AppTheme.urgencyMedium;
      default:       return AppTheme.urgencyLow;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit Complaint',
              style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: AppTheme.text1)),
            Text('Scored via Min-Heap algorithm',
              style: GoogleFonts.dmMono(
                fontSize: 10, color: AppTheme.text3)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.accentDim,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderAccent),
                ),
                child: Row(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Complaints are scored using:\n'
                        'Score = (Urgency × Weight + Likes) × e⁻λt',
                        style: GoogleFonts.dmMono(
                          fontSize: 10, color: AppTheme.accent,
                          height: 1.5)),
                    ),
                  ],
                ),
              ),
 
              const SizedBox(height: 20),
 
              // Title
              _buildLabel('Complaint Title *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: 'Brief title describing the issue',
                  prefixIcon: Icon(Icons.title,
                    color: AppTheme.text3, size: 20),
                  counterStyle: TextStyle(color: AppTheme.text3),
                ),
                style: GoogleFonts.outfit(
                  color: AppTheme.text1, fontSize: 14),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required' : null,
              ),
 
              const SizedBox(height: 14),
 
              // Description
              _buildLabel('Description *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Detailed description of the problem…',
                  alignLabelWithHint: true,
                  counterStyle: TextStyle(color: AppTheme.text3),
                ),
                style: GoogleFonts.outfit(
                  color: AppTheme.text1, fontSize: 14),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required' : null,
              ),
 
              const SizedBox(height: 14),
 
              // Category
              _buildLabel('Category *'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.bgInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    dropdownColor: AppTheme.bgCard,
                    style: GoogleFonts.outfit(
                      color: AppTheme.text1, fontSize: 14),
                    icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.text3),
                    items: _categories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    )).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
              ),
 
              const SizedBox(height: 14),
 
              // Urgency
              _buildLabel('Urgency Level *'),
              const SizedBox(height: 8),
              Row(
                children: _urgencies.map((u) {
                  final selected = _urgency == u;
                  final color = u == 'High'   ? AppTheme.urgencyHigh
                              : u == 'Medium' ? AppTheme.urgencyMedium
                                              : AppTheme.urgencyLow;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _urgency = u),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.15)
                              : AppTheme.bgInput,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? color : AppTheme.borderColor,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              u == 'High' ? '🔴'
                              : u == 'Medium' ? '🟡' : '🟢',
                              style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(u,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? color : AppTheme.text2)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
 
              const SizedBox(height: 14),
 
              // Location
              _buildLabel('Location *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Block 5, Gulshan, Karachi',
                  prefixIcon: Icon(Icons.location_on_outlined,
                    color: AppTheme.text3, size: 20),
                ),
                style: GoogleFonts.outfit(
                  color: AppTheme.text1, fontSize: 14),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Location is required' : null,
              ),
 
              const SizedBox(height: 28),
 
              // Urgency indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _urgencyColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _urgencyColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                      color: _urgencyColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _urgency == 'High'
                        ? 'High urgency adds 3× weight to score'
                        : _urgency == 'Medium'
                          ? 'Medium urgency adds 2× weight to score'
                          : 'Low urgency adds 1× weight to score',
                      style: GoogleFonts.dmMono(
                        fontSize: 10, color: _urgencyColor),
                    ),
                  ],
                ),
              ),
 
              const SizedBox(height: 20),
 
              GradientButton(
                label: 'Submit Complaint',
                onPressed: _submit,
                isLoading: _loading,
                icon: Icons.send_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildLabel(String text) {
    return Text(text,
      style: GoogleFonts.outfit(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: AppTheme.text2,
        letterSpacing: 0.04));
  }
}