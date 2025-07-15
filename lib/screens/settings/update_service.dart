// lib/screens/settings/update_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String description;
  final DateTime publishedAt;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.description,
    required this.publishedAt,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['tag_name'] as String,
      downloadUrl: (json['assets'] as List)
          .firstWhere((asset) => asset['name'].toString().endsWith('.apk'))['browser_download_url'] as String,
      description: json['body'] as String? ?? '',
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }
}

class UpdateService {
  static const String _repoUrl = 'https://api.github.com/repos/HexaGhost-09/wallora-2/releases/latest';
  static const String _lastCheckKey = 'last_update_check';
  
  // Cache for version info to avoid repeated API calls
  static String? _cachedCurrentVersion;
  static UpdateInfo? _cachedUpdateInfo;
  static DateTime? _lastUpdateCheck;
  static const Duration _cacheExpiration = Duration(hours: 1);
  
  // HTTP client with timeout configuration
  static final http.Client _httpClient = http.Client();
  static const Duration _timeoutDuration = Duration(seconds: 10);
  
  // Check for updates from GitHub releases with caching
  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      // Return cached result if it's still valid
      if (_cachedUpdateInfo != null && 
          _lastUpdateCheck != null && 
          DateTime.now().difference(_lastUpdateCheck!) < _cacheExpiration) {
        return _cachedUpdateInfo;
      }

      final response = await _httpClient.get(
        Uri.parse(_repoUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedUpdateInfo = UpdateInfo.fromJson(data);
        _lastUpdateCheck = DateTime.now();
        return _cachedUpdateInfo;
      } else {
        print('Failed to check for updates: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error checking for updates: $e');
      return null;
    }
  }

  // Check if update is available by comparing versions with caching
  static Future<bool> isUpdateAvailable() async {
    try {
      final currentVersion = await getCurrentVersion();
      
      final updateInfo = await checkForUpdates();
      if (updateInfo == null) return false;

      // Remove 'v' prefix if present in the GitHub release tag
      final latestVersion = updateInfo.version.startsWith('v') 
          ? updateInfo.version.substring(1) 
          : updateInfo.version;

      return _compareVersions(currentVersion, latestVersion) < 0;
    } catch (e) {
      print('Error checking if update is available: $e');
      return false;
    }
  }

  // Optimized version comparison with early returns
  static int _compareVersions(String v1, String v2) {
    if (v1 == v2) return 0;
    
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;
    
    for (int i = 0; i < maxLength; i++) {
      final part1 = i < parts1.length ? parts1[i] : 0;
      final part2 = i < parts2.length ? parts2[i] : 0;
      
      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    
    return 0;
  }

  // Show update dialog with improved UI
  static void showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Colors.deepPurpleAccent),
              SizedBox(width: 10),
              Text(
                'Update Available',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${updateInfo.version} is now available!',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              if (updateInfo.description.isNotEmpty) ...[
                const Text(
                  'What\'s New:',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Text(
                      updateInfo.description,
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Later',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _launchUrl(updateInfo.downloadUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  // Launch URL in browser with error handling
  static Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // Check for updates automatically with debouncing
  static Future<void> checkForUpdatesAutomatically(BuildContext context) async {
    if (!context.mounted) return;
    
    try {
      final isAvailable = await isUpdateAvailable();
      if (isAvailable && context.mounted) {
        final updateInfo = await checkForUpdates();
        if (updateInfo != null && context.mounted) {
          // Show update dialog after a short delay to ensure UI is ready
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              showUpdateDialog(context, updateInfo);
            }
          });
        }
      }
    } catch (e) {
      print('Error in automatic update check: $e');
    }
  }

  // Manual update check with improved error handling
  static Future<void> checkForUpdatesManually(BuildContext context) async {
    if (!context.mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: const Row(
            children: [
              CircularProgressIndicator(color: Colors.deepPurpleAccent),
              SizedBox(width: 20),
              Text(
                'Checking for updates...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );

    try {
      final isAvailable = await isUpdateAvailable();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (isAvailable) {
          final updateInfo = await checkForUpdates();
          if (updateInfo != null && context.mounted) {
            showUpdateDialog(context, updateInfo);
          }
        } else {
          // Show "up to date" message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You\'re using the latest version!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to check for updates. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Get current app version with caching
  static Future<String> getCurrentVersion() async {
    if (_cachedCurrentVersion != null) {
      return _cachedCurrentVersion!;
    }
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _cachedCurrentVersion = packageInfo.version;
      return _cachedCurrentVersion!;
    } catch (e) {
      return 'Unknown';
    }
  }
  
  // Clear cache method for testing or force refresh
  static void clearCache() {
    _cachedCurrentVersion = null;
    _cachedUpdateInfo = null;
    _lastUpdateCheck = null;
  }
  
  // Dispose method to clean up resources
  static void dispose() {
    _httpClient.close();
    clearCache();
  }
}