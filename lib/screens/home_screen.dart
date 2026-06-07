import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/folder.dart';
import '../services/storage_service.dart';
import '../widgets/folder_item.dart';
import 'notes_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Folder> _folders = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() => setState(() => _folders = StorageService.getFolders());

  void _openFolder(Folder folder) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => NotesListScreen(folder: folder))
    ).then((_) => _loadFolders());
  }

  Future<void> _showAddFolderDialog() async {
    String name = '';
    String selectedIcon = 'star';
    final icons = {
      'star': Icons.star_outline_rounded,
      'work': Icons.work_outline_rounded,
      'book': Icons.book_outlined,
      'code': Icons.code_rounded,
      'music': Icons.music_note_outlined,
      'home': Icons.home_outlined,
      'photo': Icons.photo_outlined,
      'science': Icons.science_outlined,
      'heart': Icons.favorite_outline_rounded,
      'idea': Icons.lightbulb_outline_rounded,
      'travel': Icons.flight_outlined,
      'money': Icons.attach_money_rounded,
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              const Text('New Folder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Sodark')),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Sodark'),
                cursorColor: kGold,
                decoration: InputDecoration(
                  hintText: 'Folder name',
                  hintStyle: const TextStyle(color: Color(0xFF555555), fontFamily: 'Sodark'),
                  filled: true, fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 14),
              const Text('ICON', style: TextStyle(color: Color(0xFF555555), fontSize: 11, letterSpacing: 1.2, fontFamily: 'Sodark')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: icons.entries.map((e) {
                  final sel = selectedIcon == e.key;
                  return GestureDetector(
                    onTap: () => setModal(() => selectedIcon = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0x22D3AC00) : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: sel ? Border.all(color: kGold, width: 1) : null,
                      ),
                      child: Icon(e.value, color: sel ? kGold : Colors.grey, size: 22),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (name.trim().isEmpty) return;
                    await StorageService.createFolder(name.trim(), selectedIcon);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadFolders();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold, foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Sodark'),
                  ),
                  child: const Text('Create Folder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteFolder(Folder folder) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Folder', style: TextStyle(color: Colors.white, fontFamily: 'Sodark')),
        content: Text('Delete "${folder.name}" and all its notes?',
            style: const TextStyle(color: Color(0xFFAAAAAA), fontFamily: 'Sodark')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888), fontFamily: 'Sodark'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Color(0xFFE74C3C), fontFamily: 'Sodark'))),
        ],
      ),
    );
    if (ok == true) { await StorageService.deleteFolder(folder.id); _loadFolders(); }
  }

  List<Folder> get _userFolders => _folders.where((f) => !f.isSystem).toList();
  Folder? get _allFolder => _folders.where((f) => f.id == 'all').firstOrNull;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, elevation: 0,
        actions: [
          GoldButton(label: _isEditing ? 'Done' : 'Edit',
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isEditing = !_isEditing);
              }),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('blackPad', style: TextStyle(
                fontSize: 34, fontWeight: FontWeight.w800,
                letterSpacing: 0.5, color: Colors.white, fontFamily: 'Sodark',
              )),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  if (_allFolder != null) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => NotesListScreen(folder: _allFolder!, initialSearch: ''),
                    )).then((_) => _loadFolders());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14)),
                  child: const Row(children: [
                    Icon(Icons.search, color: Color(0xFF555555), size: 20),
                    SizedBox(width: 8),
                    Text('Search notes...', style: TextStyle(color: Color(0xFF555555), fontSize: 15, fontFamily: 'Sodark')),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_allFolder != null) ...[
                        _groupCard([
                          FolderItemTile(
                            title: 'All Notes', icon: Icons.notes_rounded,
                            noteCount: StorageService.getNoteCount('all'),
                            onTap: () => _openFolder(_allFolder!),
                          ),
                        ]),
                        const SizedBox(height: 16),
                      ],
                      if (_userFolders.isNotEmpty) ...[
                        const SectionLabel('My Folders'),
                        _groupCard(
                          _userFolders.asMap().entries.map((e) {
                            final i = e.key; final f = e.value;
                            return Column(children: [
                              FolderItemTile(
                                title: f.name, icon: f.icon,
                                noteCount: StorageService.getNoteCount(f.id),
                                isLocked: f.isLocked,
                                onTap: () => _openFolder(f),
                                onLongPress: _isEditing ? () => _confirmDeleteFolder(f) : null,
                              ),
                              if (i < _userFolders.length - 1) const SectionDivider(),
                            ]);
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SectionLabel('System'),
                      _groupCard([
                        FolderItemTile(
                          title: 'Pinned', icon: Icons.push_pin_rounded,
                          noteCount: StorageService.getNoteCount('pinned'),
                          onTap: () => _openFolder(Folder(id: 'pinned', name: 'Pinned', iconName: 'pin', isSystem: true)),
                        ),
                        const SectionDivider(),
                        FolderItemTile(
                          title: 'Recently Deleted', icon: Icons.delete_sweep_outlined,
                          noteCount: StorageService.getNoteCount('deleted'),
                          showRedBadge: true,
                          onTap: () => _openFolder(Folder(id: 'deleted', name: 'Recently Deleted', iconName: 'delete', isSystem: true)),
                        ),
                        const SectionDivider(),
                        FolderItemTile(
                          title: 'Settings', icon: Icons.settings_suggest_rounded,
                          noteCount: 0,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => _loadFolders()),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Center(child: Text(
                        '${StorageService.getNoteCount('all')} notes',
                        style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontFamily: 'Sodark'),
                      )),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _showAddFolderDialog,
                      icon: const Icon(Icons.create_new_folder_outlined, size: 26, color: kGold),
                    ),
                    IconButton(
                      onPressed: () async {
                        final folder = _allFolder ?? Folder(id: 'all', name: 'All Notes', iconName: 'notes', isSystem: true);
                        final note = await StorageService.createNote(folderId: folder.id);
                        if (mounted) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => NotesListScreen(folder: folder, openNoteId: note.id),
                          )).then((_) => _loadFolders());
                        }
                      },
                      icon: const Icon(Icons.note_add_outlined, size: 26, color: kGold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16)),
    child: Column(children: children),
  );
}
