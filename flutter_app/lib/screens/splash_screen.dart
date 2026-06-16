// lib/screens/splash_screen.dart
// ─────────────────────────────────────────────────────────
// Animated splash screen shown on app launch.
// Navigates to Login after 2.5s.
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
 
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
 
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
 
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;
 
  @override
  void initState() {
    super.initState();
 
    // Logo animation
    _logoCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.3, end: 1.0));
    _logoFade  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
 
    // Text animation (delayed)
    _textCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(
          begin: const Offset(0, 0.3),
          end:   Offset.zero));
 
    // Glow pulse
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.5, end: 1.0));
 
    // Sequence
    _logoCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100),
          () => _textCtrl.forward());
    });
 
    // Navigate after 2.8s
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }
 
  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgVoid,
      body: Stack(
        children: [
          // Animated background grid dots
          const _GridBackground(),
 
          // Radial glow behind logo
          Center(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppTheme.accent.withOpacity(_pulse.value * 0.15),
                    blurRadius: 80,
                    spreadRadius: 40,
                  )],
                ),
              ),
            ),
          ),
 
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        gradient: brandGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(
                          color: AppTheme.accent.withOpacity(0.4),
                          blurRadius: 30, offset: const Offset(0, 8))],
                      ),
                      child: const Center(
                        child: Text('⚖', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                  ),
                ),
 
                const SizedBox(height: 28),
 
                // App name + taglines
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              brandGradient.createShader(bounds),
                          child: Text('ComplaintRank',
                            style: GoogleFonts.outfit(
                              fontSize: 32, fontWeight: FontWeight.w800,
                              color: Colors.white)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dynamic Top-K Complaint Ranking System',
                          style: GoogleFonts.dmMono(
                            fontSize: 11, color: AppTheme.text3),
                        ),
                        const SizedBox(height: 20),
                        // Tech chips
                        Wrap(
                          spacing: 8,
                          children: [
                            _TechChip('Min-Heap'),
                            _TechChip('Time Decay'),
                            _TechChip('Clustering'),
                            _TechChip('Spam Detection'),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Loading indicator
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            backgroundColor: AppTheme.bgRaised,
                            valueColor: const AlwaysStoppedAnimation(
                              AppTheme.accent),
                            minHeight: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('DAA Semester Project',
                          style: GoogleFonts.dmMono(
                            fontSize: 10, color: AppTheme.text3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip(this.label);
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderAccent),
      ),
      child: Text(label,
        style: GoogleFonts.dmMono(
          fontSize: 10, color: AppTheme.accent, fontWeight: FontWeight.w500)),
    );
  }
}
 
// Simple grid-dot background
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
      ..color = AppTheme.accent.withOpacity(0.04)
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