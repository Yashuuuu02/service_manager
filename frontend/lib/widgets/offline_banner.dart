import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfflineStatusBanner extends StatelessWidget {
  final bool isOffline;
  final VoidCallback onSync;

  const OfflineStatusBanner({
    super.key,
    required this.isOffline,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.statusCritical, // Red background as per wireframe
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'OFFLINE — Data saved locally',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: onSync,
              icon: const Icon(Icons.sync, color: Colors.white, size: 16),
              label: Text(
                'SYNC NOW',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
