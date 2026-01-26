
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String version;
  final String url;
  final String releaseNotes;
  final bool isAvailable;

  UpdateInfo({
    required this.version,
    required this.url,
    required this.releaseNotes,
    required this.isAvailable,
  });
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  UpdateInfo? _latestUpdate;
  UpdateInfo? get latestUpdate => _latestUpdate;

  bool _isChecking = false;
  
  // Cache the update info to avoid repeated API calls if not forced
  Future<UpdateInfo?> checkForUpdates({bool force = false}) async {
    if (_latestUpdate != null && !force) return _latestUpdate;
    if (_isChecking) return null;

    _isChecking = true;

    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Fetch latest release from GitHub
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/HexaGhost-09/wallora-2/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String tagName = data['tag_name'] ?? '';
        final String htmlUrl = data['html_url'] ?? '';
        final String body = data['body'] ?? '';
        
        // Clean tag name (remove 'v' prefix if present)
        final cleanTag = tagName.startsWith('v') ? tagName.substring(1) : tagName;
        
        // Simple string comparison for now, or use a semver parser if strict
        // Assuming format 1.2.6
        final isAvailable = _isVersionNewer(currentVersion, cleanTag);

        _latestUpdate = UpdateInfo(
          version: tagName,
          url: htmlUrl,
          releaseNotes: body,
          isAvailable: isAvailable,
        );
        
        return _latestUpdate;
      }
    } catch (e) {
      print('Error checking for updates: $e');
    } finally {
      _isChecking = false;
    }
    return null;
  }
  
  // Compares two version strings (e.g., "1.2.6" vs "1.2.7")
  // Returns true if remote is newer than local
  bool _isVersionNewer(String local, String remote) {
    try {
      // Remove any build metadata involved (e.g. +1)
      final localClean = local.split('+')[0];
      final remoteClean = remote.split('+')[0]; // Just in case
      
      List<int> localParts = localClean.split('.').map(int.parse).toList();
      List<int> remoteParts = remoteClean.split('.').map(int.parse).toList();
      
      for (int i = 0; i < localParts.length && i < remoteParts.length; i++) {
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }
      
      // If we are here, prefix matches. If remote has more parts, it's newer (usually)
      if (remoteParts.length > localParts.length) return true;
      
    } catch (e) {
      print("Version parse error: $e");
    }
    return false;
  }

  Future<void> initialize() async {
    await checkForUpdates();
  }
}
