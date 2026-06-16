// lib/screens/signup_screen.dart
// ─────────────────────────────────────────────────────────
// Signup screen — UI only.
// On submit, navigates to Dashboard.
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart';
 
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
 
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}
 
class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _userCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;
  bool  _loading    = false;
 
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
 
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _animCtrl.forward();
  }
 
  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          username: _nameCtrl.text.trim())),
      (_) => false,
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgVoid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
            color: AppTheme.text2, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          gradient: brandGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                            color: AppTheme.accent.withOpacity(0.3),
                            blurRadius: 20, offset: const Offset(0, 6),
                          )],
                        ),
                        child: const Center(
                          child: Text('⚖', style: TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(height: 14),
                      Text('Create Account',
                        style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppTheme.text1)),
                      const SizedBox(height: 4),
                      Text('Join the ComplaintRank platform',
                        style: GoogleFonts.dmMono(
                          fontSize: 11, color: AppTheme.text3)),
                    ],
                  ),
                ),
 
                const SizedBox(height: 28),
 
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full name
                        _buildField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          hint: 'Ahmed Ali',
                          icon: Icons.badge_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter your name' : null,
                        ),
 
                        const SizedBox(height: 14),
 
                        // Email
                        _buildField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter email';
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
 
                        const SizedBox(height: 14),
 
                        // Username
                        _buildField(
                          controller: _userCtrl,
                          label: 'Username',
                          hint: 'choose_a_username',
                          icon: Icons.alternate_email,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter username' : null,
                        ),
 
                        const SizedBox(height: 14),
 
                        // Password
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.text3, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                                color: AppTheme.text3, size: 20),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          style: GoogleFonts.outfit(
                            color: AppTheme.text1, fontSize: 14),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
 
                        const SizedBox(height: 24),
 
                        GradientButton(
                          label: 'Create Account',
                          onPressed: _signup,
                          isLoading: _loading,
                          icon: Icons.person_add_outlined,
                        ),
 
                        const SizedBox(height: 14),
 
                        Center(
                          child: Text('Demo: any credentials work',
                            style: GoogleFonts.dmMono(
                              fontSize: 10, color: AppTheme.text3)),
                        ),
                      ],
                    ),
                  ),
                ),
 
                const SizedBox(height: 16),
 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                      style: GoogleFonts.outfit(
                        fontSize: 13, color: AppTheme.text2)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.text3, size: 20),
      ),
      style: GoogleFonts.outfit(color: AppTheme.text1, fontSize: 14),
      validator: validator,
    );
  }
}