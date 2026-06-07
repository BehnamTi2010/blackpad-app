import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/storage_service.dart';
import '../services/settings_service.dart';
import 'about_developer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SettingsService.listenable(),
      builder: (context, Box box, _) {
        final isDark = SettingsService.isDarkMode;
        final fontSize = SettingsService.baseFontSize;
        final lineH = SettingsService.lineHeight;
        final autoSave = SettingsService.autoSaveInterval;
        final showWC = SettingsService.showWordCount;
        final accent = SettingsService.accentColor;

        final bg = isDark ? Colors.black : const Color(0xFFF2F2F7);
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final subColor = isDark
            ? const Color(0xFF888888)
            : const Color(0xFF999999);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: accent, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Settings',
                style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sodark')),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8),
            children: [
              // ── Appearance ──────────────────────────────────
              _label('Appearance', subColor),
              _card(cardBg, [
                // Dark / Light toggle
                _row(
                  child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark Mode',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontFamily: 'Sodark')),
                        Switch.adaptive(
                          value: isDark,
                          // ignore: deprecated_member_use
                          activeColor: accent,
                          onChanged: (v) async {
                            await SettingsService.setDarkMode(v);
                            // Rebuild MaterialApp via restart (برای theme تغییر کنه)
                            // در بیلد بعدی main.dart تم رو از SettingsService میخونه
                          },
                        ),
                      ]),
                ),
                _divider(cardBg),

                // Font size — تغییر واقعی، نه دکوری
                _row(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Font Size',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontFamily: 'Sodark')),
                            Text('${fontSize.toInt()}px',
                                style: TextStyle(
                                    color: subColor,
                                    fontFamily: 'Sodark')),
                          ]),
                      // پیش‌نمایش زنده فونت
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Text('The quick brown fox...',
                            style: TextStyle(
                                color: subColor.withValues(alpha: 0.7),
                                fontSize: fontSize,
                                fontFamily: 'Sodark')),
                      ),
                      Slider(
                        value: fontSize,
                        min: 12,
                        max: 24,
                        divisions: 6,
                        activeColor: accent,
                        inactiveColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFDDDDDD),
                        onChanged: (v) async {
                          await SettingsService.setBaseFontSize(v);
                        },
                      ),
                    ])),
                _divider(cardBg),

                // Line height — با پیش‌نمایش زنده
                _row(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Line Height',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontFamily: 'Sodark')),
                            Text(lineH.toStringAsFixed(1),
                                style: TextStyle(
                                    color: subColor,
                                    fontFamily: 'Sodark')),
                          ]),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Text('Line one\nLine two\nLine three',
                            style: TextStyle(
                                color: subColor.withValues(alpha: 0.7),
                                fontSize: 12,
                                height: lineH,
                                fontFamily: 'Sodark')),
                      ),
                      Slider(
                        value: lineH,
                        min: 1.0,
                        max: 2.2,
                        divisions: 6,
                        activeColor: accent,
                        inactiveColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFDDDDDD),
                        onChanged: (v) async {
                          await SettingsService.setLineHeight(v);
                        },
                      ),
                    ])),
                _divider(cardBg),

                // Accent color
                _row(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      Text('Accent Color',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontFamily: 'Sodark')),
                      const SizedBox(height: 10),
                      Wrap(spacing: 10, runSpacing: 8, children: [
                        _colorDot(
                            const Color(0xFFD3AC00), accent),
                        _colorDot(
                            const Color(0xFFFF3B30), accent),
                        _colorDot(
                            const Color(0xFF00C7BE), accent),
                        _colorDot(
                            const Color(0xFF007AFF), accent),
                        _colorDot(
                            const Color(0xFF34C759), accent),
                        _colorDot(
                            const Color(0xFFFF9500), accent),
                        _colorDot(
                            const Color(0xFFAF52DE), accent),
                        _colorDot(
                            const Color(0xFFFF2D55), accent),
                      ]),
                      const SizedBox(height: 6),
                      // پیش‌نمایش رنگ انتخابی
                      Row(children: [
                        Icon(Icons.push_pin_rounded,
                            color: accent, size: 16),
                        const SizedBox(width: 6),
                        Text('Preview accent color',
                            style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontFamily: 'Sodark')),
                      ]),
                    ])),
              ]),
              const SizedBox(height: 16),

              // ── Editor ──────────────────────────────────────
              _label('Editor', subColor),
              _card(cardBg, [
                _row(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                      Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Auto-save Delay',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontFamily: 'Sodark')),
                            Text(
                                '${(autoSave / 1000).toStringAsFixed(1)}s',
                                style: TextStyle(
                                    color: subColor,
                                    fontFamily: 'Sodark')),
                          ]),
                      Slider(
                        value: autoSave.toDouble(),
                        min: 300,
                        max: 3000,
                        divisions: 9,
                        activeColor: accent,
                        inactiveColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFDDDDDD),
                        onChanged: (v) async {
                          await SettingsService.setAutoSaveInterval(
                              v.toInt());
                        },
                      ),
                    ])),
                _divider(cardBg),
                _row(
                    child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                      Text('Word Count Bar',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontFamily: 'Sodark')),
                      Switch.adaptive(
                        value: showWC,
                        // ignore: deprecated_member_use
                        activeColor: accent,
                        onChanged: (v) async {
                          await SettingsService.setShowWordCount(v);
                        },
                      ),
                    ])),
              ]),
              const SizedBox(height: 16),

              // ── Data ────────────────────────────────────────
              _label('Data', subColor),
              _card(cardBg, [
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              backgroundColor:
                                  const Color(0xFF1E1E1E),
                              title: const Text('Empty Trash',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Sodark')),
                              content: const Text(
                                  'Delete all notes permanently?',
                                  style: TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontFamily: 'Sodark')),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: Color(0xFF888888),
                                            fontFamily: 'Sodark'))),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Empty',
                                        style: TextStyle(
                                            color: Color(0xFFE74C3C),
                                            fontFamily: 'Sodark'))),
                              ],
                            ));
                    if (ok == true) {
                      await StorageService.emptyTrash();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Trash emptied')));
                      }
                    }
                  },
                  child: _row(
                      child: const Row(children: [
                    Icon(Icons.delete_sweep_outlined,
                        color: Color(0xFFE74C3C), size: 20),
                    SizedBox(width: 10),
                    Text('Empty Trash',
                        style: TextStyle(
                            color: Color(0xFFE74C3C),
                            fontSize: 15,
                            fontFamily: 'Sodark')),
                  ])),
                ),
              ]),
              const SizedBox(height: 16),

              // ── About ────────────────────────────────────────
              _label('About', subColor),
              _card(cardBg, [
                _infoRow('App', 'blackPad', textColor, subColor),
                _divider(cardBg),
                _infoRow(
                    'Version', '1.0.0', textColor, subColor),
                _divider(cardBg),
                _infoRow(
                    'Font', 'Sodark', textColor, subColor),
                _divider(cardBg),
                _infoRow('Storage', 'Offline · Hive',
                    textColor, subColor),
                _divider(cardBg),
                // ── Developer link ───────────────────────────
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AboutDeveloperScreen()),
                  ),
                  child: _row(
                    child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.person_outline_rounded,
                                color: accent, size: 18),
                            const SizedBox(width: 8),
                            Text('Developer',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontFamily: 'Sodark')),
                          ]),
                          Row(children: [
                            Text('BehnamTi · GR',
                                style: TextStyle(
                                    color: subColor,
                                    fontSize: 14,
                                    fontFamily: 'Sodark')),
                            const SizedBox(width: 6),
                            const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: Color(0xFF3A3A3A)),
                          ]),
                        ]),
                  ),
                ),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // ── Widget helpers ─────────────────────────────────────

  Widget _label(String t, Color c) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                color: c,
                letterSpacing: 1.0,
                fontFamily: 'Sodark')),
      );

  Widget _card(Color bg, List<Widget> children) => Container(
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      );

  Widget _row({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        child: child,
      );

  Widget _divider(Color bg) => Divider(
        height: 0,
        thickness: 0.5,
        color: bg == Colors.white
            ? const Color(0xFFEEEEEE)
            : const Color(0x12FFFFFF),
        indent: 14,
        endIndent: 14,
      );

  Widget _infoRow(
          String label, String value, Color textColor, Color subColor) =>
      _row(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontFamily: 'Sodark')),
              Text(value,
                  style: TextStyle(
                      color: subColor,
                      fontSize: 14,
                      fontFamily: 'Sodark')),
            ]),
      );

  Widget _colorDot(Color color, Color current) {
    final selected = current.toARGB32() == color.toARGB32();
    return GestureDetector(
      onTap: () => SettingsService.setAccentColor(color.toARGB32()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selected ? 36 : 30,
        height: selected ? 36 : 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8)
                ]
              : null,
        ),
      ),
    );
  }
}