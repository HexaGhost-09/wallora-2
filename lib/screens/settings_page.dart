import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/update_service.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';
  UpdateInfo? _updateInfo;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkAuth();
    _updateInfo = UpdateService.instance.latestUpdate;
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
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

  Future<void> _checkUpdate() async {
    setState(() => _isLoading = true);
    final info = await UpdateService.instance.checkForUpdates(force: true);
    setState(() {
      _updateInfo = info;
      _isLoading = false;
    });

    if (mounted) {
       if (info == null || !info.isAvailable) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text("You are up to date!"),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           ),
         );
       }
    }
  }

  Future<void> _launchGitHubUrl() async {
    final uri = Uri.parse('https://github.com/HexaGhost-09/wallora-2/releases');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch GitHub URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Settings",
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Customize your experience",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- PROFILE SECTION ---
              _SettingsSection(
                title: "Account",
                children: [
                   _SettingsTile(
                    icon: _isLoggedIn ? Iconsax.user_tick : Iconsax.user,
                    title: _isLoggedIn ? (_userName ?? "User") : "Profile",
                    subtitle: _isLoggedIn ? (_userEmail ?? "Logged in") : "Login to sync favorites",
                    trailing: _isLoggedIn 
                      ? TextButton(
                          onPressed: _handleLogout,
                          child: const Text("Logout", style: TextStyle(color: Colors.red)),
                        )
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Login", style: TextStyle(fontSize: 12)),
                        ),
                    onTap: _isLoggedIn ? null : _handleLogin,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 24),
              
              _SettingsSection(
                title: "Appearance",
                children: [
                  _SettingsTile(
                    icon: Iconsax.colors_square,
                    title: "Theme Mode",
                    subtitle: "Switch between light and dark",
                    trailing: DropdownButton<ThemeMode>(
                      value: ThemeService.instance.themeMode,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(16),
                      style: GoogleFonts.outfit(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (ThemeMode? newMode) {
                        if (newMode != null) {
                          ThemeService.instance.setThemeMode(newMode);
                          setState(() {});
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                        DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                      ],
                    ),
                  ),
                ],
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 24),
              
              _SettingsSection(
                title: "App Info",
                children: [
                  _SettingsTile(
                    icon: Iconsax.info_circle,
                    title: "Version",
                    subtitle: "v$_version",
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Iconsax.refresh,
                    title: "Check for updates",
                    subtitle: _isLoading ? "Checking..." : "Click to check",
                    onTap: _isLoading ? null : _checkUpdate,
                    trailing: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  ),
                  if (_updateInfo != null && _updateInfo!.isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Iconsax.radar, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "New version ${_updateInfo!.version} available!",
                                    style: GoogleFonts.outfit(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _launchGitHubUrl,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Download Now"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).moveY(begin: 20, end: 0),
              
              const SizedBox(height: 40),
              
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/icon/icon.png', height: 40, width: 40),
                    const SizedBox(height: 12),
                    Text(
                      "Wallora",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Iconsax.arrow_right_3, size: 18) : null),
    );
  }
}
