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
import 'saved_wallpapers_screen.dart';

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
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
                        iconColor: _isLoggedIn ? Colors.green : null,
                        title: _isLoggedIn ? (_userName ?? "User") : "Profile",
                        subtitle: _isLoggedIn
                            ? (_userEmail ?? "Logged in")
                            : "Login to sync favorites",
                        trailing: _isLoggedIn
                            ? TextButton(
                                onPressed: _handleLogout,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade400,
                                ),
                                child: const Text("Logout"),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                        onTap: _isLoggedIn ? null : _handleLogin,
                      ),
                      if (_isLoggedIn) ...[
                        Container(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.06)),
                        _SettingsTile(
                          icon: Iconsax.archive_tick,
                          title: "Saved Wallpapers",
                          subtitle: "View your saved collection",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SavedWallpapersScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOutCubic).moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 24),

                  // --- APPEARANCE SECTION ---
                  _SettingsSection(
                    title: "Appearance",
                    children: [
                      _SettingsTile(
                        icon: Iconsax.colors_square,
                        title: "Theme Mode",
                        subtitle: "Switch between light and dark",
                        trailing: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode, size: 16),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('Auto'),
                              icon: Icon(Icons.auto_mode, size: 16),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode, size: 16),
                            ),
                          ],
                          selected: {ThemeService.instance.themeMode},
                          onSelectionChanged: (Set<ThemeMode> selected) {
                            ThemeService.instance.setThemeMode(selected.first);
                            setState(() {});
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms, curve: Curves.easeOutCubic).moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 24),

                  // --- APP INFO SECTION ---
                  _SettingsSection(
                    title: "App Info",
                    children: [
                      _SettingsTile(
                        icon: Iconsax.info_circle,
                        title: "Version",
                        subtitle: "v$_version",
                        onTap: () {},
                      ),
                      Container(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.06)),
                      _SettingsTile(
                        icon: Iconsax.refresh,
                        title: "Check for updates",
                        subtitle: _isLoading ? "Checking..." : "Tap to check",
                        onTap: _isLoading ? null : _checkUpdate,
                        trailing: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                      ),
                      if (_updateInfo != null && _updateInfo!.isAvailable) ...[
                        Container(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.06)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Iconsax.radar, color: Colors.green, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "New version ${_updateInfo!.version} available!",
                                        style: GoogleFonts.outfit(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("Download Now"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms, curve: Curves.easeOutCubic).moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/icon/icon.png', height: 36, width: 36),
                        const SizedBox(height: 12),
                        Text(
                          "Wallora",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.25),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: isDark
                ? const Color(0xFF141B2D)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: trailing ??
          (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20) : null),
    );
  }
}
