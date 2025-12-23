import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';

class AvatarNotifier extends StateNotifier<int> {
  final LocalStorageService _storageService;

  AvatarNotifier(this._storageService) : super(0) {
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final savedAvatar = await _storageService.getSelectedAvatar();
    state = savedAvatar;
  }

  Future<void> setAvatar(int avatarIndex) async {
    state = avatarIndex;
    await _storageService.saveSelectedAvatar(avatarIndex);
  }
}

final avatarProvider = StateNotifierProvider<AvatarNotifier, int>((ref) {
  return AvatarNotifier(LocalStorageService());
});

class AvatarData {
  static const List<Map<String, dynamic>> avatars = [
    {
      'icon': Icons.person_rounded,
      'colors': [Color(0xFF4F46E5), Color(0xFF10B981)],
      'name': 'Varsayılan',
    },
    {
      'icon': Icons.rocket_launch_rounded,
      'colors': [Color(0xFFEC4899), Color(0xFFF59E0B)],
      'name': 'Roket',
    },
    {
      'icon': Icons.psychology_rounded,
      'colors': [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
      'name': 'Beyin',
    },
    {
      'icon': Icons.star_rounded,
      'colors': [Color(0xFFFBBF24), Color(0xFFF97316)],
      'name': 'Yıldız',
    },
    {
      'icon': Icons.favorite_rounded,
      'colors': [Color(0xFFEF4444), Color(0xFFEC4899)],
      'name': 'Kalp',
    },
    {
      'icon': Icons.emoji_events_rounded,
      'colors': [Color(0xFF10B981), Color(0xFF3B82F6)],
      'name': 'Kupa',
    },
  ];

  static Map<String, dynamic> getAvatar(int index) {
    if (index < 0 || index >= avatars.length) {
      return avatars[0];
    }
    return avatars[index];
  }
}
