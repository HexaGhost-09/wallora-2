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
  
  // Check for updates from GitHub releases
  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse(_repoUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UpdateInfo.fromJson(data);
      } else {
        print('Failed to check for updates: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error checking for updates: $e');
      return null;
    }
  }

  // Check if update is available by comparing versions
  static Future<bool> isUpdateAvailable() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
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

  // Compare two version strings (returns -1 if v1 < v2, 0 if equal, 1 if v1 > v2)
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;
    
    for (int i = 0; i < maxLength; i++) {
      final part1 = i < parts1.length ? parts1[i] : 0;
      final part2 = i < parts2.length ? parts2[i] : 0;
      
      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    
    return 0;
  }

  // Show update dialog
  static void showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              if (updateInfo.description.isNotEmpty) ...[
                Text(
                  'What\'s New:',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Later',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl(updateInfo.downloadUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Download'),
            ),
          ],
        );
      },
    );
  }

  // Launch URL in browser
  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  // Check for updates automatically (call this on app startup)
  static Future<void> checkForUpdatesAutomatically(BuildContext context) async {
    try {
      final isAvailable = await isUpdateAvailable();
      if (isAvailable) {
        final updateInfo = await checkForUpdates();
        if (updateInfo != null) {
          // Show update dialog after a short delay to ensure UI is ready
          Future.delayed(Duration(seconds: 2), () {
            showUpdateDialog(context, updateInfo);
          });
        }
      }
    } catch (e) {
      print('Error in automatic update check: $e');
    }
  }

  // Manual update check (call this from settings)
  static Future<void> checkForUpdatesManually(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Row(
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
      Navigator.of(context).pop(); // Close loading dialog

      if (isAvailable) {
        final updateInfo = await checkForUpdates();
        if (updateInfo != null) {
          showUpdateDialog(context, updateInfo);
        }
      } else {
        // Show "up to date" message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You\'re using the latest version!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check for updates. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Get current app version
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return 'Unknown';
    }
  }
}