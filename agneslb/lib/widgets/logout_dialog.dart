import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback? onConfirmLogout;

  const LogoutDialog({super.key, this.onConfirmLogout});

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onConfirmLogout,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LogoutDialog(onConfirmLogout: onConfirmLogout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? 'admin@agneslb.vn';
    final initialLetter = userEmail.isNotEmpty
        ? userEmail[0].toUpperCase()
        : 'A';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 358,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Decorative / Action Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Heading & Subtitle
            const Text(
              'Đăng xuất tài khoản',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Liberation Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn có chắc chắn muốn đăng xuất khỏi AgnesLB?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Liberation Sans',
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Active User Profile Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryNavy,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: Center(
                      child: Text(
                        initialLetter,
                        style: const TextStyle(
                          fontFamily: 'Liberation Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tài khoản đăng nhập',
                          style: TextStyle(
                            fontFamily: 'Liberation Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Liberation Sans',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onConfirmLogout?.call();
                  }
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel / Dismiss Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.softBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Security Confirmation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                SizedBox(width: 6),
                Text(
                  'Phiên làm việc sẽ được đóng an toàn',
                  style: TextStyle(
                    fontFamily: 'Liberation Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
