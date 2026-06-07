import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/folder_item.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_rounded, color: kGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Developer',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sodark')),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // ── Avatar ──────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF111111),
                border:
                    Border.all(color: kGold.withValues(alpha: 0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'B.',
                  style: TextStyle(
                    fontFamily: 'Sodark',
                    fontSize: 46,
                    color: kGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Name ─────────────────────────────────────────
            const Text(
              'BehnamTi',
              style: TextStyle(
                fontFamily: 'Sodark',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mobile & Flutter Developer · GR',
              style: TextStyle(
                fontFamily: 'Sodark',
                fontSize: 14,
                color: Color(0xFF888888),
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 32),

            // ── Bio card ─────────────────────────────────────
            _card(
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.person_outline_rounded,
                          color: kGold, size: 18),
                      SizedBox(width: 8),
                      Text('About',
                          style: TextStyle(
                              color: kGold,
                              fontSize: 13,
                              letterSpacing: 1.0,
                              fontFamily: 'Sodark')),
                    ]),
                    SizedBox(height: 12),
                    Text(
                      'Passionate about building clean, minimal, and '
                      'offline-first mobile apps. blackPad is designed '
                      'to keep your thoughts private — no cloud, no '
                      'tracking, just writing.',
                      style: TextStyle(
                        fontFamily: 'Sodark',
                        fontSize: 14,
                        color: Color(0xFFBBBBBB),
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Links ─────────────────────────────────────────
            _card(
              child: Column(children: [
                _linkTile(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  value: 'github.com/BehnamTi2010',
                  onTap: () => _copyToClipboard(context, 'github.com/BehnamTi'),
                ),
                const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Color(0x12FFFFFF),
                    indent: 52,
                    endIndent: 16),
                _linkTile(
                  icon: Icons.telegram_rounded,
                  label: 'Telegram',
                  value: '@BehnamTi_01',
                  onTap: () => _copyToClipboard(context, '@BehnamTi'),
                ),
                const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Color(0x12FFFFFF),
                    indent: 52,
                    endIndent: 16),
                _linkTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'behnamti2010@gmail.com',
                  onTap: () =>
                      _copyToClipboard(context, 'behnamti.dev@gmail.com'),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ── App info ──────────────────────────────────────
            _card(
              child: Column(children: [
                _infoRow('App', 'blackPad'),
                const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Color(0x12FFFFFF),
                    indent: 16,
                    endIndent: 16),
                _infoRow('Version', '2.0.0'),
                const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Color(0x12FFFFFF),
                    indent: 16,
                    endIndent: 16),
                const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Color(0x12FFFFFF),
                    indent: 16,
                    endIndent: 16),
                _infoRow('License', 'MIT'),
              ]),
            ),

            const SizedBox(height: 40),

            // ── Footer ────────────────────────────────────────
            const Text(
              'Made with ♥ by BehnamTi · GR',
              style: TextStyle(
                fontFamily: 'Sodark',
                fontSize: 12,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'blackPad © 2026',
              style: TextStyle(
                fontFamily: 'Sodark',
                fontSize: 11,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text',
            style: const TextStyle(fontFamily: 'Sodark', fontSize: 13)),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
        ),
        child: child,
      );

  Widget _linkTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, color: kGold, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontFamily: 'Sodark')),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontFamily: 'Sodark')),
            ]),
          ),
          const Icon(Icons.copy_rounded, color: Color(0xFF333333), size: 16),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Sodark')),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  fontFamily: 'Sodark')),
        ]),
      );
}
