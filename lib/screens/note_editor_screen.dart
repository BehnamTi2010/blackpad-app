import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../services/storage_service.dart';
import '../services/settings_service.dart';
import '../widgets/folder_item.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note note;
  final Folder folder;
  const NoteEditorScreen(
      {super.key, required this.note, required this.folder});
  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late Note _note;
  Timer? _autoSaveTimer;
  bool _isSaved = true;
  int _wordCount = 0;
  bool _showToolbar = false;

  // Focus nodes برای کنترل بهتر کیبورد
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  bool get _isDeleted => _note.isDeleted;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleCtrl = TextEditingController(text: _note.title);
    _contentCtrl = TextEditingController(text: _note.content);
    _wordCount = _calcWordCount(_note.content);
    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveSync();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_isSaved) setState(() => _isSaved = false);
    final wc = _calcWordCount(_contentCtrl.text);
    if (wc != _wordCount) setState(() => _wordCount = wc);
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(
        Duration(milliseconds: SettingsService.autoSaveInterval), _save);
  }

  int _calcWordCount(String text) =>
      text.trim().isEmpty
          ? 0
          : text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  // ذخیره async برای autosave
  Future<void> _save() async {
    if (_isDeleted) return;
    final updated =
        _note.copyWith(title: _titleCtrl.text, content: _contentCtrl.text);
    await StorageService.saveNote(updated);
    _note = updated;
    if (mounted) setState(() => _isSaved = true);
  }

  // ذخیره sync برای dispose (بدون await)
  void _saveSync() {
    if (_isDeleted) return;
    final updated =
        _note.copyWith(title: _titleCtrl.text, content: _contentCtrl.text);
    StorageService.saveNote(updated);
  }

  // ── Formatting helpers ──────────────────────────────────

  void _wrapSelection(String before, String after) {
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    if (!sel.isValid) return;
    final text = ctrl.text;
    final selected = sel.textInside(text);
    final newText =
        text.replaceRange(sel.start, sel.end, '$before$selected$after');
    final cursor = sel.start + before.length + selected.length + after.length;
    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
    _onChanged();
  }

  void _insertAtLineStart(String prefix) {
    final ctrl = _contentCtrl;
    if (!ctrl.selection.isValid) return;
    final pos = ctrl.selection.start;
    final text = ctrl.text;
    // پیدا کردن ابتدای خط فعلی
    final lineStart = text.lastIndexOf('\n', pos - 1) + 1;
    final lineEnd = text.indexOf('\n', pos);
    final currentLine =
        text.substring(lineStart, lineEnd == -1 ? text.length : lineEnd);

    // اگه پرفیکس قبلاً هست، حذفش کن (toggle)
    if (currentLine.startsWith(prefix)) {
      final newText = text.replaceRange(
          lineStart, lineStart + prefix.length, '');
      ctrl.value = ctrl.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
            offset: pos - prefix.length < lineStart
                ? lineStart
                : pos - prefix.length),
      );
    } else {
      final newText = text.replaceRange(lineStart, lineStart, prefix);
      ctrl.value = ctrl.value.copyWith(
        text: newText,
        selection:
            TextSelection.collapsed(offset: pos + prefix.length),
      );
    }
    _onChanged();
  }

  void _insertBlock(String before, String after) {
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    final pos = sel.isValid ? sel.start : text.length;
    final insert = '$before$after';
    final newText = text.replaceRange(pos, pos, insert);
    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection:
          TextSelection.collapsed(offset: pos + before.length),
    );
    _onChanged();
  }

  // ── Actions ─────────────────────────────────────────────

  void _showNoteActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          if (!_isDeleted) ...[
            _actionTile(
                icon: _note.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                label: _note.isPinned ? 'Unpin' : 'Pin',
                color: kGold,
                onTap: () async {
                  Navigator.pop(context);
                  await StorageService.pinNote(
                      _note.id, !_note.isPinned);
                  setState(() =>
                      _note = _note.copyWith(isPinned: !_note.isPinned));
                }),
            _actionTile(
                icon: Icons.info_outline_rounded,
                label: 'Note Info',
                color: Colors.white70,
                onTap: () {
                  Navigator.pop(context);
                  _showNoteInfo();
                }),
            _actionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Move to Trash',
                color: const Color(0xFFE74C3C),
                onTap: () async {
                  Navigator.pop(context);
                  await StorageService.moveToTrash(_note.id);
                  if (mounted) Navigator.pop(context);
                }),
          ] else ...[
            _actionTile(
                icon: Icons.restore_rounded,
                label: 'Restore',
                color: kGold,
                onTap: () async {
                  Navigator.pop(context);
                  await StorageService.restoreNote(_note.id);
                  if (mounted) Navigator.pop(context);
                }),
            _actionTile(
                icon: Icons.delete_forever_rounded,
                label: 'Delete Permanently',
                color: const Color(0xFFE74C3C),
                onTap: () async {
                  Navigator.pop(context);
                  await StorageService.deletePermanently(_note.id);
                  if (mounted) Navigator.pop(context);
                }),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _actionTile(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(
              color: color, fontSize: 16, fontFamily: 'Sodark')),
      onTap: onTap,
    );
  }

  void _showNoteInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Note Info',
            style: TextStyle(color: Colors.white, fontFamily: 'Sodark')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _infoRow('Created', _fmt(_note.createdAt)),
          _infoRow('Modified', _fmt(_note.updatedAt)),
          _infoRow('Words', '$_wordCount'),
          _infoRow(
              'Characters', '${_contentCtrl.text.length}'),
          _infoRow(
              'Lines',
              '${_contentCtrl.text.split('\n').length}'),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(
                      color: kGold, fontFamily: 'Sodark')))
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                      fontFamily: 'Sodark')),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Sodark')),
            ]),
      );

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // خوندن تنظیمات در هر build — چون ممکنه تغییر کرده باشن
    final fontSize = SettingsService.baseFontSize;
    final lineH = SettingsService.lineHeight;
    final isDark = SettingsService.isDarkMode;
    final accent = SettingsService.accentColor;

    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor =
        isDark ? const Color(0xFFDDDDDD) : const Color(0xFF333333);
    final hintColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFCCCCCC);
    final toolbarBg =
        isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F0F0);
    final toolbarBtnBg =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0);
    final wordBarBg =
        isDark ? const Color(0xFF080808) : const Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: accent, size: 20),
          onPressed: () {
            _autoSaveTimer?.cancel();
            _save().then((_) {
              // ignore: use_build_context_synchronously
              if (mounted) Navigator.pop(context);
            });
          },
        ),
        actions: [
          if (!_isSaved)
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 18, horizontal: 8),
              child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      color: accent, strokeWidth: 1.5)),
            ),
          if (_note.isPinned)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.push_pin_rounded,
                  color: accent, size: 18),
            ),
          IconButton(
              icon: Icon(Icons.more_horiz_rounded,
                  color: accent, size: 24),
              onPressed: _showNoteActions),
        ],
      ),
      body: Column(children: [
        // ── Editor area ──────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmt(_note.updatedAt),
                      style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 12,
                          fontFamily: 'Sodark')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    focusNode: _titleFocus,
                    readOnly: _isDeleted,
                    style: TextStyle(
                        color: textColor,
                        fontSize: fontSize + 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sodark'),
                    cursorColor: accent,
                    maxLines: null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _contentFocus.requestFocus(),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Title',
                        hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: fontSize + 10,
                            fontFamily: 'Sodark')),
                  ),
                  TextField(
                    controller: _contentCtrl,
                    focusNode: _contentFocus,
                    readOnly: _isDeleted,
                    style: TextStyle(
                        color: subColor,
                        fontSize: fontSize,
                        height: lineH,
                        fontFamily: 'Sodark'),
                    cursorColor: accent,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start writing...',
                        hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: fontSize,
                            fontFamily: 'Sodark')),
                    onTap: () {
                      if (!_showToolbar) {
                        setState(() => _showToolbar = true);
                      }
                    },
                  ),
                  const SizedBox(height: 80),
                ]),
          ),
        ),

        // ── Word count bar ────────────────────────────────
        if (SettingsService.showWordCount)
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 20),
            color: wordBarBg,
            child: Row(children: [
              Text('$_wordCount words',
                  style: const TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 11,
                      fontFamily: 'Sodark')),
              const SizedBox(width: 12),
              Text('${_contentCtrl.text.length} chars',
                  style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 11,
                      fontFamily: 'Sodark')),
              const Spacer(),
              Text(
                  '${_contentCtrl.text.split('\n').length} lines',
                  style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 11,
                      fontFamily: 'Sodark')),
            ]),
          ),

        // ── Formatting toolbar ────────────────────────────
        if (_showToolbar && !_isDeleted)
          Container(
            color: toolbarBg,
            padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(children: [
                // Bold
                _toolBtn('B',
                    bold: true,
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _wrapSelection('**', '**')),
                // Italic
                _toolBtn('I',
                    italic: true,
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _wrapSelection('*', '*')),
                // Underline
                _toolBtn('U',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _wrapSelection('__', '__')),
                // Strikethrough
                _toolBtn('S̶',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _wrapSelection('~~', '~~')),
                _divider(),
                // Headings
                _toolBtn('H1',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('# ')),
                _toolBtn('H2',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('## ')),
                _toolBtn('H3',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('### ')),
                _divider(),
                // Quote & Code
                _toolBtn('❝',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('> ')),
                _toolBtn('{ }',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertBlock('\n```\n', '\n```\n')),
                _divider(),
                // Lists
                _toolBtn('•',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('• ')),
                _toolBtn('1.',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('1. ')),
                _toolBtn('☐',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('[ ] ')),
                _toolBtn('☑',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertAtLineStart('[x] ')),
                _divider(),
                // Divider line & new line
                _toolBtn('—',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertBlock('\n---\n', '')),
                _toolBtn('↵',
                    bgColor: toolbarBtnBg,
                    accent: accent,
                    onTap: () => _insertBlock('\n\n', '')),
                const SizedBox(width: 8),
                // Hide toolbar
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _contentFocus.unfocus();
                    setState(() => _showToolbar = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: toolbarBtnBg,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.keyboard_hide_rounded,
                        color: accent.withOpacity(0.6), size: 18),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _toolBtn(
    String label, {
    bool bold = false,
    bool italic = false,
    required Color bgColor,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(7)),
        child: Text(label,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight:
                  bold ? FontWeight.w900 : FontWeight.w600,
              fontStyle:
                  italic ? FontStyle.italic : FontStyle.normal,
              fontFamily: 'Sodark',
            )),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
            width: 1,
            height: 20,
            child: ColoredBox(color: Color(0xFF2A2A2A))),
      );
}