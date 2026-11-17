import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'notification_service.dart';

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
  Future<UpdateInfo?> checkForUpdates({
    bool force = false,
    bool showNotification = false,
  }) async {
    if (_latestUpdate != null && !force) return _latestUpdate;
    if (_isChecking) return null;

    _isChecking = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // GitHub Releases is the primary source for update metadata and downloads.
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/HexaGhost-09/wallora-2/releases/latest',
        ),
        headers: const {'Accept': 'application/vnd.github+json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String tagName = data['tag_name'] ?? '';
        final String htmlUrl = data['html_url'] ??
            'https://github.com/HexaGhost-09/wallora-2/releases/latest';
        final String body = data['body'] ?? '';

        final cleanTag =
            tagName.startsWith('v') ? tagName.substring(1) : tagName;
        final isAvailable = _isVersionNewer(currentVersion, cleanTag);

        _latestUpdate = UpdateInfo(
          version: tagName,
          url: htmlUrl,
          releaseNotes: body,
          isAvailable: isAvailable,
        );

        if (isAvailable && showNotification) {
          final apkUrl =
              'https://github.com/HexaGhost-09/wallora-2/releases/latest/download/Wallora-v$cleanTag.apk';
          await NotificationService.instance.showUpdateNotification(
            cleanTag,
            apkUrl,
          );
        }

        return _latestUpdate;
      }
    } catch (e) {
      print('Error checking for updates: $e');
    } finally {
      _isChecking = false;
    }
    return null;
  }

  bool _isVersionNewer(String local, String remote) {
    try {
      final localParts = local.split('+').first.split('.').map(int.parse).toList();
      final remoteParts =
          remote.split('+').first.split('.').map(int.parse).toList();

      for (int i = 0; i < localParts.length && i < remoteParts.length; i++) {
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }

      return remoteParts.length > localParts.length;
    } catch (e) {
      print("Version parse error: $e");
      return false;
    }
  }

  Future<void> initialize() async {
    await checkForUpdates(showNotification: true);
  }
}
