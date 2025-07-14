import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:cached_network_image/cached_network_image.dart'; // Added for image caching

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _autoWallpaper = false;
  double _downloadQuality = 1.0; // 0.0 = Low, 0.5 = Medium, 1.0 = High
  String _selectedLanguage = 'English';

  // Sample data for settings sections
  final List<Map<String, dynamic>> _settingsData = [
    {
      'title': 'Display',
      'icon': Icons.display_settings,
      'items': [
        {'title': 'Dark Mode', 'type': 'switch', 'value': true},
        {'title': 'Theme Color', 'type': 'navigation', 'subtitle': 'Deep Purple'},
      ]
    },
    {
      'title': 'Wallpaper',
      'icon': Icons.wallpaper,
      'items': [
        {'title': 'Download Quality', 'type': 'slider', 'value': 1.0},
        {'title': 'Auto Wallpaper', 'type': 'switch', 'value': false},
        {'title': 'Download Location', 'type': 'navigation', 'subtitle': 'Internal Storage'},
      ]
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications,
      'items': [
        {'title': 'Push Notifications', 'type': 'switch', 'value': true},
        {'title': 'New Wallpapers', 'type': 'switch', 'value': true},
        {'title': 'Updates', 'type': 'switch', 'value': false},
      ]
    },
    {
      'title': 'General',
      'icon': Icons.settings,
      'items': [
        {'title': 'Language', 'type': 'navigation', 'subtitle': 'English'},
        {'title': 'Cache Size', 'type': 'navigation', 'subtitle': '124 MB'},
        {'title': 'Clear Cache', 'type': 'action'},
      ]
    },
    {
      'title': 'About',
      'icon': Icons.info,
      'items': [
        {'title': 'Version', 'type': 'navigation', 'subtitle': '1.0.0'},
        {'title': 'Privacy Policy', 'type': 'navigation'},
        {'title': 'Terms of Service', 'type': 'navigation'},
        {'title': 'Rate App', 'type': 'action'},
      ]
    }
  ];

  String _getQualityText(double value) {
    if (value <= 0.33) return 'Low';
    if (value <= 0.66) return 'Medium';
    return 'High';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSettingItem(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'switch':
        return SwitchListTile(
          title: Text(
            item['title'],
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          value: item['value'] ?? false,
          onChanged: (bool value) {
            setState(() {
              // Handle switch changes based on title
              switch (item['title']) {
                case 'Dark Mode':
                  _darkMode = value;
                  break;
                case 'Push Notifications':
                  _notifications = value;
                  break;
                case 'Auto Wallpaper':
                  _autoWallpaper = value;
                  break;
                // Add more cases as needed
              }
            });
            _showSnackBar('${item['title']} ${value ? 'enabled' : 'disabled'}');
          },
          activeColor: Colors.deepPurpleAccent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        );
      
      case 'slider':
        return Column(
          children: [
            ListTile(
              title: Text(
                item['title'],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Text(
                _getQualityText(_downloadQuality),
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Slider(
                value: _downloadQuality,
                onChanged: (double value) {
                  setState(() {
                    _downloadQuality = value;
                  });
                },
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.grey[600],
                divisions: 2,
                label: _getQualityText(_downloadQuality),
              ),
            ),
          ],
        );
      
      case 'navigation':
        return ListTile(
          title: Text(
            item['title'],
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          subtitle: item['subtitle'] != null
              ? Text(
                  item['subtitle'],
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                )
              : null,
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          onTap: () {
            _showSnackBar('${item['title']} tapped');
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        );
      
      case 'action':
        return ListTile(
          title: Text(
            item['title'],
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          onTap: () {
            _showSnackBar('${item['title']} executed');
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        itemCount: _settingsData.length,
        itemBuilder: (context, index) {
          final section = _settingsData[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.grey[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          section['icon'],
                          color: Colors.deepPurpleAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          section['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Section Items
                  ...section['items'].map<Widget>((item) {
                    return Column(
                      children: [
                        _buildSettingItem(item),
                        if (item != section['items'].last)
                          Divider(
                            color: Colors.grey[700],
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}