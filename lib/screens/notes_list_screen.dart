import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/folder_item.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatefulWidget {
  final Folder folder;
  final String? initialSearch;
  final String? openNoteId;

  const NotesListScreen({super.key, required this.folder, this.initialSearch, this.openNoteId});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showSearch = false;

  bool get _isDeletedFolder => widget.folder.id == 'deleted';

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null) {
      _searchQuery = widget.initialSearch!;
      _searchController.text = _searchQuery;
      _showSearch = true;
    }
    _loadNotes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openNoteId != null) {
        final note = _notes.where((n) => n.id == widget.openNoteId).firstOrNull;
        if (note != null) _openNote(note);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    setState(() {
      _notes = StorageService.getNotes(
        folderId: widget.folder.id,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
    });
  }

  void _openNote(Note note) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note, folder: widget.folder))).then((_) => _loadNotes());
  }

  Future<void> _createNote() async {
    final folderId = _isDeletedFolder ? 'all' : widget.folder.id;
    final note = await StorageService.createNote(folderId: folderId);
    if (mounted) _openNote(note);
  }

  Future<void> _pinNote(Note note) async {
    await StorageService.pinNote(note.id, !note.isPinned);
    _loadNotes();
  }

  Future<void> _trashNote(Note note) async {
    await StorageService.moveToTrash(note.id);
    _loadNotes();
  }

  Future<void> _restoreNote(Note note) async {
    await StorageService.restoreNote(note.id);
    _loadNotes();
  }

  Future<void> _deletePermanently(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontFamily: 'Sodark')),
        content: const Text('This cannot be undone.', style: TextStyle(color: Color(0xFFAAAAAA), fontFamily: 'Sodark')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888), fontFamily: 'Sodark'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFE74C3C), fontFamily: 'Sodark'))),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.deletePermanently(note.id);
      _loadNotes();
    }
  }

  Future<void> _emptyTrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Empty Trash', style: TextStyle(color: Colors.white, fontFamily: 'Sodark')),
        content: const Text('Delete all notes permanently?', style: TextStyle(color: Color(0xFFAAAAAA), fontFamily: 'Sodark')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888), fontFamily: 'Sodark'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Empty', style: TextStyle(color: Color(0xFFE74C3C), fontFamily: 'Sodark'))),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.emptyTrash();
      _loadNotes();
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: kGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Sodark'),
                cursorColor: kGold,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Color(0xFF666666), fontFamily: 'Sodark'),
                ),
                onChanged: (v) { _searchQuery = v; _loadNotes(); },
              )
            : Text(widget.folder.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Sodark')),
        actions: [
          if (_isDeletedFolder && _notes.isNotEmpty)
            TextButton(onPressed: _emptyTrash, child: const Text('Empty', style: TextStyle(color: Color(0xFFE74C3C), fontSize: 14, fontFamily: 'Sodark'))),
          IconButton(icon: Icon(_showSearch ? Icons.close : Icons.search, color: kGold, size: 22),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) { _searchQuery = ''; _searchController.clear(); _loadNotes(); }
                });
              }),
        ],
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isDeletedFolder ? Icons.delete_outline : Icons.note_outlined, color: const Color(0xFF333333), size: 60),
                  const SizedBox(height: 12),
                  Text(_isDeletedFolder ? 'Trash is empty' : 'No notes yet', style: const TextStyle(color: Color(0xFF444444), fontSize: 16, fontFamily: 'Sodark')),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _notes.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0x10FFFFFF), height: 1, thickness: 0.5),
              itemBuilder: (_, i) {
                final note = _notes[i];
                return Dismissible(
                  key: Key(note.id),
                  background: Container(color: const Color(0xFF1A3A1A), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.push_pin_rounded, color: kGold, size: 24)),
                  secondaryBackground: Container(color: const Color(0xFF3A1A1A), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                      child: Icon(_isDeletedFolder ? Icons.delete_forever : Icons.delete_outline, color: const Color(0xFFE74C3C), size: 24)),
                  confirmDismiss: (dir) async {
                    if (dir == DismissDirection.startToEnd) {
                      if (!_isDeletedFolder) await _pinNote(note);
                      return false;
                    } else {
                      if (_isDeletedFolder) {
                        await _deletePermanently(note);
                        return true;
                      } else {
                        await _trashNote(note);
                        return true;
                      }
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    title: Row(
                      children: [
                        if (note.isPinned) ...[const Icon(Icons.push_pin_rounded, size: 13, color: kGold), const SizedBox(width: 4)],
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? 'Untitled' : note.title,
                            style: TextStyle(color: note.title.isEmpty ? const Color(0xFF555555) : Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Sodark'),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(children: [
                      Text(_formatDate(note.updatedAt), style: const TextStyle(color: Color(0xFF666666), fontSize: 12, fontFamily: 'Sodark')),
                      const SizedBox(width: 8),
                      Expanded(child: Text(note.content.replaceAll('\n', ' '), style: const TextStyle(color: Color(0xFF555555), fontSize: 13, fontFamily: 'Sodark'), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    trailing: _isDeletedFolder ? TextButton(onPressed: () => _restoreNote(note), child: const Text('Restore', style: TextStyle(color: kGold, fontSize: 13, fontFamily: 'Sodark'))) : null,
                    onTap: () => _openNote(note),
                  ),
                );
              },
            ),
      floatingActionButton: _isDeletedFolder ? null : FloatingActionButton(
        onPressed: _createNote,
        backgroundColor: kGold,
        foregroundColor: Colors.black,
        elevation: 0,
        child: const Icon(Icons.edit_outlined, size: 22),
      ),
    );
  }
}
