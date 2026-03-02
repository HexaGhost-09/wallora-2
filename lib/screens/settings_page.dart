
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';
  UpdateInfo? _updateInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    // Load cached update info if available
    setState(() {
      _updateInfo = UpdateService.instance.latestUpdate;
    });
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _checkUpdate() async {
    setState(() => _isLoading = true);
    final info = await UpdateService.instance.checkForUpdates(force: true);
    setState(() {
      _updateInfo = info;
      _isLoading = false;
    });

    if (mounted) {
       if (info != null && info.isAvailable) {
         // Optionally show a snackbar or dialog, but the UI updates anyway
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("You are up to date!")),
         );
       }
    }
  }

  Future<void> _launchGitHubUrl() async {
    if (_updateInfo != null) {
      final uri = Uri.parse('https://github.com/HexaGhost-09/wallora-2/releases');
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch GitHub URL: $e');
      }
    }
  }

  Future<void> _launchSourceForgeUrl() async {
    if (_updateInfo != null) {
      final String version = _updateInfo!.version.startsWith('v') 
          ? _updateInfo!.version 
          : 'v${_updateInfo!.version}';
      final uri = Uri.parse('https://sourceforge.net/projects/wallora-android-app/files/$version/app-release.apk/download');
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch SourceForge URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit from theme/main scaffold
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Theme Settings Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.palette_outlined, color: Colors.purple, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Theme",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DropdownButton<ThemeMode>(
                      value: ThemeService.instance.themeMode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      onChanged: (ThemeMode? newMode) {
                        if (newMode != null) {
                          ThemeService.instance.setThemeMode(newMode);
                          setState(() {}); // Update the dropdown selection
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text("Light"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text("Dark"),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text("System Default"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // App Version Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Current Version",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "v$_version",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Update Status Area
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_updateInfo != null && _updateInfo!.isAvailable)
                       Column(
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                             decoration: BoxDecoration(
                               color: Colors.green.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(
                               children: [
                                 const Icon(Icons.new_releases_rounded, color: Colors.green),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       const Text(
                                         "Update Available",
                                         style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                       Text(
                                         "Version ${_updateInfo!.version}",
                                         style: TextStyle(
                                           color: Colors.green.shade700,
                                           fontSize: 12,
                                         )
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(height: 16),
                           Row(
                             children: [
                               Expanded(
                                 child: FilledButton.icon(
                                   onPressed: _launchGitHubUrl,
                                   icon: const Icon(Icons.code_rounded),
                                   label: const Text("GitHub"),
                                   style: FilledButton.styleFrom(
                                     backgroundColor: Colors.black,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(vertical: 16),
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Expanded(
                                 child: FilledButton.icon(
                                   onPressed: _launchSourceForgeUrl,
                                   icon: const Icon(Icons.download_rounded),
                                   label: const Text("SourceForge"),
                                   style: FilledButton.styleFrom(
                                     backgroundColor: Colors.orange.shade800,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(vertical: 16),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ],
                       )
                    else
                       SizedBox(
                         width: double.infinity,
                         child: OutlinedButton.icon(
                           onPressed: _checkUpdate,
                           icon: const Icon(Icons.refresh_rounded),
                           label: const Text("Check for Updates"),
                           style: OutlinedButton.styleFrom(
                             padding: const EdgeInsets.symmetric(vertical: 16),
                             side: BorderSide(color: Theme.of(context).dividerColor),
                           ),
                         ),
                       ),
                  ],
                ),
              ),
              
              const Spacer(),
              Center(
                child: Text(
                  "Wallora App",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for nav bar
            ],
          ),
        ),
      ),
    );
  }
}
