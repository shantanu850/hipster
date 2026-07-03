import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../meeting_state_provider.dart';

class MeetingControlButton extends StatelessWidget {
  const MeetingControlButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.tooltip,
    this.size = 52,
    this.iconSize = 20,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final double iconSize;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          triggerButtonHaptic();
          onPressed();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: color == AppColors.surface
                ? Border.all(color: AppColors.surfaceLight, width: 1.5)
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class MeetingControlsBar extends ConsumerWidget {
  const MeetingControlsBar({super.key});

  void _showAudioDeviceSelector(BuildContext context, MeetingState state, MeetingStateNotifier notifier) {
    notifier.refreshAudioDevices(); // Trigger a refresh when opening
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Audio Output',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.availableAudioDevices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No audio output devices found',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...state.availableAudioDevices.map((device) {
                    final isSelected = state.activeAudioDevice == device;
                    IconData icon = Icons.volume_down_rounded;
                    if (device.toLowerCase().contains('speaker')) {
                      icon = Icons.volume_up_rounded;
                    } else if (device.toLowerCase().contains('ear') || device.toLowerCase().contains('receiver') || device.toLowerCase().contains('handset')) {
                      icon = Icons.phone_android_rounded;
                    } else if (device.toLowerCase().contains('bluetooth') || device.toLowerCase().contains('headset')) {
                      icon = Icons.bluetooth_audio_rounded;
                    }
                    
                    return ListTile(
                      leading: Icon(icon, color: isSelected ? AppColors.secondary : AppColors.textSecondary),
                      title: Text(
                        device,
                        style: TextStyle(
                          color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary) : null,
                      onTap: () {
                        notifier.updateAudioDevice(device);
                        Navigator.pop(context);
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('MeetingControlsBar: build() called');
    final isMuted = ref.watch(meetingProvider.select((s) => s.isMuted));
    final isVideoOn = ref.watch(meetingProvider.select((s) => s.isVideoOn));
    final activeAudioDevice = ref.watch(meetingProvider.select((s) => s.activeAudioDevice));
    final availableAudioDevices = ref.watch(meetingProvider.select((s) => s.availableAudioDevices));
    
    final state = MeetingState(
      isMuted: isMuted,
      isVideoOn: isVideoOn,
      activeAudioDevice: activeAudioDevice,
      availableAudioDevices: availableAudioDevices,
    );
    
    final notifier = ref.read(meetingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MeetingControlButton(
            onPressed: () => _showAudioDeviceSelector(context, state, notifier),
            icon: Icons.volume_up_rounded,
            color: AppColors.surface,
            iconColor: AppColors.textPrimary,
            tooltip: 'Audio Routing',
          ),

          MeetingControlButton(
            onPressed: () => notifier.toggleMute(),
            icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            color: isMuted ? AppColors.error : AppColors.surface,
            iconColor: isMuted ? Colors.white : AppColors.textPrimary,
            tooltip: isMuted ? 'Unmute microphone' : 'Mute microphone',
          ),

          MeetingControlButton(
            onPressed: () => notifier.leaveMeeting(),
            icon: Icons.call_end_rounded,
            color: AppColors.error,
            iconColor: Colors.white,
            size: 64,
            iconSize: 28,
            tooltip: 'End Call',
          ),

          MeetingControlButton(
            onPressed: () => notifier.toggleVideo(),
            icon: isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
            color: !isVideoOn ? AppColors.error : AppColors.surface,
            iconColor: !isVideoOn ? Colors.white : AppColors.textPrimary,
            tooltip: isVideoOn ? 'Turn off camera' : 'Turn on camera',
          ),

          MeetingControlButton(
            onPressed: () => notifier.switchCamera(),
            icon: Icons.flip_camera_ios_rounded,
            color: AppColors.surface,
            iconColor: AppColors.textPrimary,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
    );
  }
}
