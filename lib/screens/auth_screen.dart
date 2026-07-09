import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late final AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }
    if (!_isLogin && _nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    bool success = false;
    if (_isLogin) {
      success = await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      success = await AuthService.instance.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        final msg = _isLogin
            ? 'Sign in failed. Please check your email and password.'
            : 'Sign up failed. This email may already be registered.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Subtle animated blobs
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -40 + sin(_blobController.value * pi) * 20,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60 + cos(_blobController.value * pi * 0.7) * 30,
                    left: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withOpacity(0.06),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(curve: Curves.easeOutCubic).slideX(curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Sign in to access your wallpapers'
                      : 'Join Wallora and sync your favorite backgrounds',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 48),

                if (!_isLogin)
                  _buildField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'John Doe',
                    icon: Iconsax.user,
                  ).animate().fadeIn(curve: Curves.easeOutCubic).slideY(curve: Curves.easeOutCubic),

                if (!_isLogin) const SizedBox(height: 16),

                _buildField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'hello@wallora.com',
                  icon: Iconsax.sms,
                  keyboardType: TextInputType.emailAddress,
                ).animate().fadeIn(delay: 200.ms, curve: Curves.easeOutCubic).slideY(curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                _buildField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Iconsax.lock,
                  isPassword: true,
                ).animate().fadeIn(delay: 300.ms, curve: Curves.easeOutCubic).slideY(curve: Curves.easeOutCubic),

                const SizedBox(height: 40),

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
                          color: primary.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, curve: Curves.easeOutCubic).scale(curve: Curves.easeOutCubic),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "OR",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.login,
                      label: 'Google',
                      onPressed: () =>
                          AuthService.instance.signInWithProvider('google'),
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      icon: Icons.code,
                      label: 'GitHub',
                      onPressed: () =>
                          AuthService.instance.signInWithProvider('github'),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms, curve: Curves.easeOutCubic).slideY(curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _isLogin = !_isLogin);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: _isLogin
                                ? "Don't have an account? "
                                : "Already have an account? ",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          TextSpan(
                            text: _isLogin ? "Sign Up" : "Sign In",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF141B2D)
                : theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF141B2D)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
