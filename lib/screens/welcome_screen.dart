import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background subtle gradients
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              ),
            ).animate().fade(duration: 1.seconds).scale(delay: 200.ms),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
              ),
            ).animate().fade(duration: 1.seconds).scale(delay: 400.ms),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
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
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              ),
                              child: Icon(
                                _pages[index]['icon'],
                                size: 80,
                                color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            )
                            .animate(target: _currentPage == index ? 1 : 0)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
                            .fadeIn(),
                            
                            const SizedBox(height: 24),
                            
                            Text(
                              _pages[index]['subtitle'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                
                // Bottom Section: Indicators and Button
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Next/Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ).animate().fade(duration: 800.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
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
