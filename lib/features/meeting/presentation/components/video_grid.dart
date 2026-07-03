import 'package:flutter/material.dart';
import 'package:flutter_amazon_chime/flutter_amazon_chime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../meeting_state_provider.dart';

class VideoGrid extends ConsumerWidget {
  const VideoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('VideoGrid: build() called');
    final activeVideoTiles = ref.watch(meetingProvider.select((s) => s.activeVideoTiles));
    final isVideoOn = ref.watch(meetingProvider.select((s) => s.isVideoOn));
    final attendees = ref.watch(meetingProvider.select((s) => s.attendees));
    final activeAttendeeId = ref.watch(meetingProvider.select((s) => s.activeAttendeeId));

    final hasRemoteParticipant = attendees.any((a) => a.attendeeId != activeAttendeeId);

    final localTile = activeVideoTiles.firstWhere(
      (t) => t.isLocalTile,
      orElse: () => const VideoTileInfo(
        tileId: -1,
        attendeeId: '',
        videoStreamContentWidth: 0,
        videoStreamContentHeight: 0,
        isLocalTile: true,
        isContentShare: false,
      ),
    );

    final remoteTile = activeVideoTiles.firstWhere(
      (t) => !t.isLocalTile,
      orElse: () => const VideoTileInfo(
        tileId: -1,
        attendeeId: '',
        videoStreamContentWidth: 0,
        videoStreamContentHeight: 0,
        isLocalTile: false,
        isContentShare: false,
      ),
    );

    if (!hasRemoteParticipant) {
      return Column(
        children: [
          Expanded(
            child: _buildVideoTile(
              context,
              tile: localTile,
              label: 'You (Host)',
              isVideoOn: isVideoOn,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Waiting for remote participant to join...',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildVideoTile(
            context,
            tile: remoteTile,
            label: 'Remote Participant',
            isVideoOn: true,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildVideoTile(
            context,
            tile: localTile,
            label: 'You',
            isVideoOn: isVideoOn,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTile(
    BuildContext context, {
    required VideoTileInfo tile,
    required String label,
    required bool isVideoOn,
  }) {
    final bool hasVideo = isVideoOn && tile.tileId != -1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasVideo)
            _buildNativeChimeView(tile.tileId)
          else
            _buildCameraOffPlaceholder(label),

          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    hasVideo ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    color: hasVideo ? AppColors.accent : AppColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeChimeView(int tileId) {
    try {
      return VideoTile(
        tileId: tileId,
      );
    } catch (e) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image_rounded, color: AppColors.warning, size: 40),
              const SizedBox(height: 8),
              Text(
                'Native Video Frame ID: $tileId',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Platform view is not supported on this device/emulator backend.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCameraOffPlaceholder(String label) {
    final initials = label.split(' ').map((e) => e[0]).take(2).join('').toUpperCase();
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.5), AppColors.secondary.withValues(alpha: 0.5)],
                ),
                border: Border.all(color: AppColors.surfaceLight, width: 4),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Camera Off',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
