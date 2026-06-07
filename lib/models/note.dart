import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String content;
  @HiveField(3)
  String folderId;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  DateTime updatedAt;
  @HiveField(6)
  bool isPinned;
  @HiveField(7)
  bool isDeleted;
  @HiveField(8)
  int colorIndex;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.folderId,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isDeleted = false,
    this.colorIndex = 0,
  });

  Note copyWith({
    String? title,
    String? content,
    String? folderId,
    bool? isPinned,
    bool? isDeleted,
    int? colorIndex,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
