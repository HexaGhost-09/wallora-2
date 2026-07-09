import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _blobController;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Wallora',
      'subtitle': 'Your ultimate destination for stunning, high-quality wallpapers.',
      'icon': Iconsax.magic_star5,
    },
    {
      'title': 'Vast Collection',
      'subtitle': 'Explore thousands of wallpapers carefully curated just for you.',
      'icon': Iconsax.gallery5,
    },
    {
      'title': 'Personalize',
      'subtitle': 'Make your device truly yours with a single tap.',
      'icon': Iconsax.mobile5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient blobs
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -80 + sin(_blobController.value * pi) * 40,
                    right: -60 + cos(_blobController.value * pi * 0.7) * 30,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withOpacity(0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40 + sin(_blobController.value * pi * 1.3) * 30,
                    left: -40 + cos(_blobController.value * pi * 0.9) * 20,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF06B6D4).withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 300 + sin(_blobController.value * pi * 0.5) * 50,
                    right: -20,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withOpacity(0.08),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() { _currentPage = index; });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    primary.withOpacity(0.15),
                                    const Color(0xFF8B5CF6).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Icon(
                                  _pages[index]['icon'],
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            .animate(target: _currentPage == index ? 1 : 0)
                            .scale(duration: 600.ms, curve: Curves.easeOutBack)
                            .fadeIn(),

                            const SizedBox(height: 60),

                            Text(
                              _pages[index]['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -1,
                              ),
                            )
                            .animate(target: _currentPage == index ? 1 : 0)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
                            .fadeIn(),

                            const SizedBox(height: 24),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _pages[index]['subtitle'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            )
                            .animate(target: _currentPage == index ? 1 : 0)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 100.ms, curve: Curves.easeOutCubic)
                            .fadeIn(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 28 : 8,
                            decoration: BoxDecoration(
                              gradient: _currentPage == index
                                  ? const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    )
                                  : null,
                              color: _currentPage != index
                                  ? primary.withOpacity(0.2)
                                  : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                );
                              } else {
                                _completeOnboarding();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fade(duration: 800.ms, delay: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    ],
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
