// lib/screens/login_screen.dart
// ─────────────────────────────────────────────────────────
// Login screen — UI only, no backend auth needed.
// Any username/password navigates to Dashboard.
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure   = true;
  bool _loading   = false;
 
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
 
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut)
        .drive(Tween(
          begin: const Offset(0, 0.15), end: Offset.zero));
    _animCtrl.forward();
  }
 
  @override
  void dispose() {
    _animCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // Simulate short delay (no real auth)
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(username: _userCtrl.text.trim())),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgVoid,
      body: Stack(
        children: [
          const _GridBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo + Brand
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 68, height: 68,
                                decoration: BoxDecoration(
                                  gradient: brandGradient,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [BoxShadow(
                                    color: AppTheme.accent.withOpacity(0.35),
                                    blurRadius: 24,
                                    offset: const Offset(0, 6),
                                  )],
                                ),
                                child: const Center(
                                  child: Text('⚖',
                                    style: TextStyle(fontSize: 32))),
                              ),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (b) =>
                                    brandGradient.createShader(b),
                                child: Text('ComplaintRank',
                                  style: GoogleFonts.outfit(
                                    fontSize: 26, fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                              ),
                              const SizedBox(height: 4),
                              Text('Admin Console · DAA Project',
                                style: GoogleFonts.dmMono(
                                  fontSize: 11, color: AppTheme.text3)),
                            ],
                          ),
                        ),
 
                        const SizedBox(height: 36),
 
                        // Card
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
                                Text('Welcome back',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20, fontWeight: FontWeight.w800,
                                    color: AppTheme.text1)),
                                const SizedBox(height: 4),
                                Text('Sign in to access your dashboard',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13, color: AppTheme.text3)),
 
                                const SizedBox(height: 24),
 
                                // Username
                                TextFormField(
                                  controller: _userCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    prefixIcon: Icon(Icons.person_outline,
                                      color: AppTheme.text3, size: 20),
                                  ),
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.text1, fontSize: 14),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter username' : null,
                                ),
 
                                const SizedBox(height: 14),
 
                                // Password
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline,
                                      color: AppTheme.text3, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure ? Icons.visibility_off_outlined
                                                 : Icons.visibility_outlined,
                                        color: AppTheme.text3, size: 20),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.text1, fontSize: 14),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter password' : null,
                                ),
 
                                const SizedBox(height: 8),
 
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
 
                                const SizedBox(height: 8),
 
                                GradientButton(
                                  label: 'Sign In',
                                  onPressed: _login,
                                  isLoading: _loading,
                                  icon: Icons.login,
                                ),
 
                                const SizedBox(height: 16),
 
                                Center(
                                  child: Text('Demo: any credentials work',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 10, color: AppTheme.text3)),
                                ),
                              ],
                            ),
                          ),
                        ),
 
                        const SizedBox(height: 20),
 
                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                              style: GoogleFonts.outfit(
                                fontSize: 13, color: AppTheme.text2)),
                            TextButton(
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen())),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
// Grid background shared
class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}
 
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
 
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}