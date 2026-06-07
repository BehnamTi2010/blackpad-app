import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'folder.g.dart';

@HiveType(typeId: 1)
class Folder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconName; // نام آیکون به صورت string

  @HiveField(3)
  bool isLocked;

  @HiveField(4)
  bool isSystem; // فولدرهای سیستمی مثل Pinned, Deleted قابل حذف نیستن

  @HiveField(5)
  int sortOrder;

  Folder({
    required this.id,
    required this.name,
    required this.iconName,
    this.isLocked = false,
    this.isSystem = false,
    this.sortOrder = 0,
  });

  // تبدیل نام آیکون به IconData
  IconData get icon {
    const icons = {
      'notes': Icons.notes_rounded,
      'science': Icons.science_outlined,
      'book': Icons.book_outlined,
      'meeting': Icons.diversity_3_outlined,
      'lock': Icons.lock_outline_rounded,
      'pin': Icons.push_pin_rounded,
      'delete': Icons.delete_sweep_outlined,
      'settings': Icons.settings_suggest_rounded,
      'star': Icons.star_outline_rounded,
      'work': Icons.work_outline_rounded,
      'home': Icons.home_outlined,
      'code': Icons.code_rounded,
      'music': Icons.music_note_outlined,
      'photo': Icons.photo_outlined,
    };
    return icons[iconName] ?? Icons.folder_outlined;
  }

  static List<Folder> defaultFolders() {
    return [
      Folder(id: 'all', name: 'All Notes', iconName: 'notes', isSystem: true, sortOrder: 0),
      Folder(id: 'pinned', name: 'Pinned', iconName: 'pin', isSystem: true, sortOrder: 98),
      Folder(id: 'deleted', name: 'Recently Deleted', iconName: 'delete', isSystem: true, sortOrder: 99),
    ];
  }
}
