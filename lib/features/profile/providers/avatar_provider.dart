import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      'icon': FontAwesomeIcons.cat,
      'colors': [Color(0xFF8B5CF6), Color(0xFFC084FC)],
      'name': 'Kedi',
    },
    {
      'icon': FontAwesomeIcons.dog,
      'colors': [Color(0xFFF59E0B), Color(0xFFFCD34D)],
      'name': 'Köpek',
    },
    {
      'icon': FontAwesomeIcons.frog,
      'colors': [Color(0xFF10B981), Color(0xFF6EE7B7)],
      'name': 'Kurbağa',
    },
    {
      'icon': FontAwesomeIcons.otter,
      'colors': [Color(0xFF0EA5E9), Color(0xFF7DD3FC)],
      'name': 'Su Samuru',
    },
    {
      'icon': FontAwesomeIcons.hippo,
      'colors': [Color(0xFF6366F1), Color(0xFFA5B4FC)],
      'name': 'Su Aygırı',
    },

    {
      'icon': FontAwesomeIcons.fish,
      'colors': [Color(0xFF3B82F6), Color(0xFF93C5FD)],
      'name': 'Balık',
    },
    {
      'icon': FontAwesomeIcons.horseHead,
      'colors': [Color(0xFFD946EF), Color(0xFFF0ABFC)],
      'name': 'At',
    },
    {
      'icon': FontAwesomeIcons.dove,
      'colors': [Color(0xFF14B8A6), Color(0xFF5EEAD4)],
      'name': 'Güvercin',
    },
    {
      'icon': FontAwesomeIcons.dragon,
      'colors': [Color(0xFFEF4444), Color(0xFFFCA5A5)],
      'name': 'Ejderha',
    },
  ];

  static Map<String, dynamic> getAvatar(int index) {
    if (index < 0 || index >= avatars.length) {
      return avatars[0];
    }
    return avatars[index];
  }
}
