import 'package:flutter/material.dart';

const Color kGold = Color(0xFFD3AC00);
const Color kSurface = Color(0xFF1E1E1E);
const Color kDivider = Color(0x12FFFFFF);

class FolderItemTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int noteCount;
  final bool isLocked;
  final bool showRedBadge;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FolderItemTile({super.key, required this.title, required this.icon, required this.noteCount, required this.onTap, this.isLocked = false, this.showRedBadge = false, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        child: Row(children: [
          Icon(icon, color: kGold, size: 23),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Sodark'))),
          if (isLocked)
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(border: Border.all(color: kGold, width: 0.8), borderRadius: BorderRadius.circular(20), color: const Color(0x1AD3AC00)), child: const Text('Locked', style: TextStyle(color: kGold, fontSize: 11, fontFamily: 'Sodark')))
          else if (noteCount > 0)
            Text('$noteCount', style: TextStyle(color: showRedBadge ? const Color(0xFFE74C3C) : const Color(0xFF666666), fontSize: 14, fontFamily: 'Sodark')),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF3A3A3A)),
        ]),
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) => const Divider(height: 0, thickness: 0.5, color: kDivider, indent: 51, endIndent: 14);
}

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
    child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF555555), letterSpacing: 1.0, fontWeight: FontWeight.w500, fontFamily: 'Sodark')),
  );
}

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const GoldButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(foregroundColor: kGold, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Sodark')),
    child: Text(label),
  );
}