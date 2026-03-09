import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final status = await AuthService.instance.checkAuthStatus();
    if (mounted) {
      setState(() {
        _isLoggedIn = status;
        _userName = AuthService.instance.currentUser?.name;
        _userEmail = AuthService.instance.currentUser?.email;
      });
    }
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    if (result == true) {
      _checkAuth();
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.signOut();
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLoggedIn ? Iconsax.user_tick : Iconsax.user,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isLoggedIn ? (_userName ?? 'Welcome Back!') : 'Join Wallora',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLoggedIn ? (_userEmail ?? '') : 'Log in to sync your favorites across devices',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoggedIn ? _handleLogout : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: _isLoggedIn 
                      ? Colors.red.withOpacity(0.1) 
                      : Theme.of(context).colorScheme.primary,
                    foregroundColor: _isLoggedIn 
                      ? Colors.red 
                      : Colors.white,
                  ),
                  child: Text(
                    _isLoggedIn ? 'Logout' : 'Login with Email',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
