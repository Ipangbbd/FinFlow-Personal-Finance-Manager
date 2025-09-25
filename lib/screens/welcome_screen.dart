import 'package:flutter/material.dart';
import 'package:finance_manager/main.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed to match home_screen style
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _buttonScaleAnimation;

  // bool _isLoading = false; // DISABLED FOR TESTING

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _mainController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched_before', true);
  }

  Future<void> _handleGetStarted() async {
    // if (_isLoading) return; // DISABLED FOR TESTING

    // setState(() => _isLoading = true); // DISABLED FOR TESTING
    _buttonController.forward();

    await _markFirstLaunchComplete();

    if (!mounted) return;

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hardcoded theme colors from home_screen.dart
    const primary = Color(0xFF00D4FF);
    const backgroundColor = Color(0xFF0A0E21);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E3A5F),
              backgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            _buildBackgroundDecorations(size, primary),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom - 48,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated app icon
                            AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatingAnimation.value),
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 30,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: primary.withValues(alpha: 0.1),
                                            blurRadius: 40,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),

                            // Welcome text with staggered animation
                            _buildAnimatedText(
                              'Welcome to Finance Manager!',
                              const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: 0.5,
                              ),
                              delay: 0.3,
                            ),
                            const SizedBox(height: 16),

                            // Description text
                            _buildAnimatedText(
                              'Your personal assistant to track income, expenses, and manage your financial health with ease.',
                              TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.5,
                                letterSpacing: 0.3,
                              ),
                              delay: 0.5,
                            ),
                            const SizedBox(height: 40),

                            // Feature highlights
                            // _buildFeatureHighlights(primary),
                            const SizedBox(height: 40),

                            // Get Started button
                            ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      primary,
                                      primary.withValues(alpha: 0.86),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.28),
                                      blurRadius: 30,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  // onPressed: _isLoading ? null : _handleGetStarted, // DISABLED FOR TESTING
                                  onPressed: _handleGetStarted, // Always enabled for testing
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: /* _isLoading
                                      ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                                    ),
                                  )
                                      : */ Row( // DISABLED LOADING INDICATOR FOR TESTING
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations(Size size, Color primary) {
    return Stack(
      children: [
        // Floating circles
        Positioned(
          top: size.height * 0.1,
          right: size.width * 0.1,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_floatingAnimation.value * 0.5, _floatingAnimation.value * 0.3),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * 0.05,
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-_floatingAnimation.value * 0.3, _floatingAnimation.value * 0.5),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Additional decorative elements
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.8,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primary.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedText(String text, TextStyle style, {double delay = 0.0}) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          (((_mainController.value - delay).clamp(0.0, 1.0)) / (1.0 - delay)).clamp(0.0, 1.0),
        );

        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        );
      },
    );
  }

  // Widget _buildFeatureHighlights(Color primary) {
  //   final features = [
  //     {'icon': Icons.trending_up, 'text': 'Track\nIncome'},
  //     {'icon': Icons.analytics, 'text': 'Financial\nAnalytics'},
  //     {'icon': Icons.category, 'text': 'Smart\nCategories'},
  //   ];
  //
  //   return AnimatedBuilder(
  //     animation: _mainController,
  //     builder: (context, child) {
  //       final animationValue = Curves.easeOut.transform(
  //         ((_mainController.value - 0.7).clamp(0.0, 1.0) / 0.3).clamp(0.0, 1.0),
  //       );
  //
  //       return Opacity(
  //         opacity: animationValue,
  //         child: Transform.translate(
  //           offset: Offset(0, 30 * (1 - animationValue)),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: features.map((feature) {
  //               return Flexible(
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
  //                   margin: const EdgeInsets.symmetric(horizontal: 4),
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       begin: Alignment.topLeft,
  //                       end: Alignment.bottomRight,
  //                       colors: [
  //                         const Color(0xFF1A1F3A),
  //                         const Color(0xFF151929),
  //                       ],
  //                     ),
  //                     borderRadius: BorderRadius.circular(16),
  //                     border: Border.all(
  //                       color: Colors.white.withValues(alpha: 0.08),
  //                       width: 1,
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withValues(alpha: 0.2),
  //                         blurRadius: 8,
  //                         offset: const Offset(0, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         feature['icon'] as IconData,
  //                         color: primary,
  //                         size: 24,
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         feature['text'] as String,
  //                         style: TextStyle(
  //                           fontSize: 11,
  //                           color: Colors.white.withValues(alpha: 0.9),
  //                           fontWeight: FontWeight.w500,
  //                           letterSpacing: 0.2,
  //                         ),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}