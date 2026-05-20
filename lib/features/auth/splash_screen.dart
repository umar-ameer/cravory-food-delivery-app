import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/role_redirect.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController introController;
  late final AnimationController glowController;
  late final AnimationController progressController;

  late final Animation<double> fadeAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<double> rotateAnimation;
  late final Animation<double> floatAnimation;
  late final Animation<double> glowAnimation;

  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();

    introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: introController,
        curve: Curves.easeOut,
      ),
    );

    scaleAnimation = Tween<double>(
      begin: 0.55,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: introController,
        curve: Curves.elasticOut,
      ),
    );

    rotateAnimation = Tween<double>(
      begin: -0.18,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: introController,
        curve: Curves.easeOutBack,
      ),
    );

    floatAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );

    glowAnimation = Tween<double>(
      begin: 0.45,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );

    introController.forward();
    progressController.forward();

    Future.delayed(const Duration(milliseconds: 4600), () {
      _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    if (hasNavigated) return;

    hasNavigated = true;

    try {
      await ref
          .read(authProvider.notifier)
          .loadCurrentUser()
          .timeout(const Duration(seconds: 3));

      final user = ref.read(authProvider).value;

      if (!mounted) return;

      if (user == null) {
        context.go('/login');
        return;
      }

      redirectUserByRole(context, user);
    } catch (_) {
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  void dispose() {
    introController.dispose();
    glowController.dispose();
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const _SplashBackground(),

          Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        rotateAnimation,
                        floatAnimation,
                        glowAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, floatAnimation.value),
                          child: Transform.rotate(
                            angle: rotateAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _CravoryLogo(
                        glowAnimation: glowAnimation,
                      ),
                    ),

                    const SizedBox(height: 46),

                    const Text(
                      'Cravory',
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Delicious food, delivered fast',
                      style: TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 44),

                    SizedBox(
                      width: 230,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedBuilder(
                          animation: progressController,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: progressController.value,
                              minHeight: 7,
                              backgroundColor: AppTheme.surface,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Preparing your experience...',
                      style: TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
}

class _CravoryLogo extends StatelessWidget {
  final Animation<double> glowAnimation;

  const _CravoryLogo({
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 250,
          width: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 230,
                width: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(
                        0.22 + glowAnimation.value * 0.24,
                      ),
                      blurRadius: 70,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),

              Transform.rotate(
                angle: 0.20,
                child: ClipPath(
                  clipper: _CravoryShapeClipper(),
                  child: Container(
                    height: 190,
                    width: 190,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00C8FF),
                          Color(0xFF008BC9),
                          Color(0xFF04212C),
                          Color(0xFF01080C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              Transform.rotate(
                angle: 0.20,
                child: ClipPath(
                  clipper: _CravoryShapeClipper(),
                  child: Container(
                    height: 190,
                    width: 190,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 52,
                right: 48,
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 56,
                left: 46,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.6),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 118,
                width: 118,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 68,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CravoryShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    path.moveTo(w * 0.50, 0);
    path.cubicTo(w * 0.68, h * 0.02, w * 0.92, h * 0.13, w * 0.96, h * 0.34);
    path.cubicTo(w * 1.05, h * 0.55, w * 0.88, h * 0.82, w * 0.66, h * 0.94);
    path.cubicTo(w * 0.50, h * 1.06, w * 0.24, h * 0.98, w * 0.10, h * 0.74);
    path.cubicTo(w * -0.04, h * 0.52, w * 0.02, h * 0.23, w * 0.24, h * 0.10);
    path.cubicTo(w * 0.32, h * 0.04, w * 0.41, h * 0.01, w * 0.50, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -120,
          child: Container(
            height: 340,
            width: 340,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          bottom: -170,
          left: -130,
          child: Container(
            height: 360,
            width: 360,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          top: 135,
          left: 55,
          child: Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.32),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          bottom: 180,
          right: 85,
          child: Container(
            height: 13,
            width: 13,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}