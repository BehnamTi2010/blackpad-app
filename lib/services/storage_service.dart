import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/folder.dart';

class StorageService {
  static const String _notesBox = 'notes';
  static const String _foldersBox = 'folders';
  static const _uuid = Uuid();

  static late Box<Note> _notes;
  static late Box<Folder> _folders;

  // ── Cache ──────────────────────────────────────────────
  static List<Folder>? _folderCache;
  static final Map<String, List<Note>> _noteCache = {};

  static void _invalidateFolderCache() => _folderCache = null;
  static void _invalidateNoteCache([String? folderId]) {
    if (folderId != null) {
      _noteCache.remove(folderId);
      _noteCache.remove('all');
      _noteCache.remove('pinned');
      _noteCache.remove('deleted');
    } else {
      _noteCache.clear();
    }
  }

  // ── Init ───────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(FolderAdapter());

    _notes = await Hive.openBox<Note>(_notesBox);
    _folders = await Hive.openBox<Folder>(_foldersBox);

    if (_folders.isEmpty) {
      for (final f in Folder.defaultFolders()) {
        await _folders.put(f.id, f);
      }
    }
  }

  // ── Folders ────────────────────────────────────────────

  static List<Folder> getFolders() {
    if (_folderCache != null) return _folderCache!;
    final all = _folders.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _folderCache = all;
    return all;
  }

  static List<Folder> getUserFolders() =>
      getFolders().where((f) => !f.isSystem || f.id == 'all').toList();

  static Future<Folder> createFolder(String name, String iconName) async {
    final folder = Folder(
      id: _uuid.v4(),
      name: name,
      iconName: iconName,
      sortOrder: _folders.length,
    );
    await _folders.put(folder.id, folder);
    _invalidateFolderCache();
    return folder;
  }

  static Future<void> updateFolder(Folder folder) async {
    await _folders.put(folder.id, folder);
    _invalidateFolderCache();
  }

  static Future<void> deleteFolder(String folderId) async {
    final notesToDelete =
        _notes.values.where((n) => n.folderId == folderId).toList();
    for (final n in notesToDelete) {
      await _notes.delete(n.id);
    }
    await _folders.delete(folderId);
    _invalidateFolderCache();
    _invalidateNoteCache();
  }

  // ── Notes ──────────────────────────────────────────────

  static List<Note> getNotes({
    String? folderId,
    bool includeDeleted = false,
    String? searchQuery,
  }) {
    // فقط وقتی سرچ نداریم از کش استفاده کن
    final cacheKey = folderId ?? 'all';
    if (searchQuery == null || searchQuery.isEmpty) {
      if (_noteCache.containsKey(cacheKey)) return _noteCache[cacheKey]!;
    }

    var notes = _notes.values.toList();

    if (folderId == 'pinned') {
      notes = notes.where((n) => n.isPinned && !n.isDeleted).toList();
    } else if (folderId == 'deleted') {
      notes = notes.where((n) => n.isDeleted).toList();
    } else if (folderId == 'all' || folderId == null) {
      notes = notes.where((n) => !n.isDeleted).toList();
    } else {
      notes = notes
          .where((n) => n.folderId == folderId && !n.isDeleted)
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      notes = notes
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q))
          .toList();
    }

    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    if (searchQuery == null || searchQuery.isEmpty) {
      _noteCache[cacheKey] = notes;
    }
    return notes;
  }

  static int getNoteCount(String folderId) =>
      getNotes(folderId: folderId).length;

  static Future<Note> createNote({
    required String folderId,
    String title = '',
    String content = '',
  }) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      folderId:
          folderId == 'all' || folderId == 'pinned' ? 'all' : folderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _notes.put(note.id, note);
    _invalidateNoteCache(note.folderId);
    return note;
  }

  static Future<void> saveNote(Note note) async {
    await _notes.put(note.id, note);
    _invalidateNoteCache(note.folderId);
  }

  static Future<void> pinNote(String noteId, bool pin) async {
    final note = _notes.get(noteId);
    if (note != null) {
      await _notes.put(noteId, note.copyWith(isPinned: pin));
      _invalidateNoteCache(note.folderId);
    }
  }

  static Future<void> moveToTrash(String noteId) async {
    final note = _notes.get(noteId);
    if (note != null) {
      await _notes.put(
          noteId, note.copyWith(isDeleted: true, isPinned: false));
      _invalidateNoteCache();
    }
  }

  static Future<void> restoreNote(String noteId) async {
    final note = _notes.get(noteId);
    if (note != null) {
      await _notes.put(noteId, note.copyWith(isDeleted: false));
      _invalidateNoteCache();
    }
  }

  static Future<void> deletePermanently(String noteId) async {
    await _notes.delete(noteId);
    _invalidateNoteCache();
  }

  static Future<void> emptyTrash() async {
    final deleted = _notes.values.where((n) => n.isDeleted).toList();
    for (final n in deleted) {
      await _notes.delete(n.id);
    }
    _invalidateNoteCache();
  }
}