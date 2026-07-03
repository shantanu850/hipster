import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../meeting/domain/meeting_state.dart';
import '../../meeting/presentation/meeting_screen.dart';
import '../../meeting/presentation/meeting_state_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _meetingIdController = TextEditingController();

  @override
  void dispose() {
    _meetingIdController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndProceed(Future<void> Function() action) async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!mounted) return;

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await action();
      return;
    }

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.permissionsTitle),
          content: const Text(AppStrings.permissionsMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.okLabel),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.permissionsDeniedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = ref.watch(meetingProvider.select((s) => s.errorMessage));
    final notifier = ref.read(meetingProvider.notifier);

    ref.listen<MeetingStatus>(
      meetingProvider.select((s) => s.status),
      (previous, current) {
        if (current == MeetingStatus.joining && 
            (previous == MeetingStatus.idle || previous == null || previous == MeetingStatus.disconnected)) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MeetingScreen()),
          );
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.rocket_launch_rounded,
                            color: AppColors.secondary,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.appTagline,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: AppColors.error, fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error, size: 16),
                          onPressed: () => notifier.clearError(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          triggerButtonHaptic();
                          _requestPermissionsAndProceed(() async => notifier.hostMeeting());
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_to_home_screen_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.createInstantMeeting,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.surfaceLight, thickness: 1.5)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              AppStrings.orJoin,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.surfaceLight, thickness: 1.5)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: _meetingIdController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: AppStrings.enterMeetingIdHint,
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          prefixIcon: const Icon(Icons.vpn_key_rounded, color: AppColors.textSecondary, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () {
                          triggerButtonHaptic();
                          _requestPermissionsAndProceed(() async => notifier.joinMeeting(_meetingIdController.text, isAgent: false));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.joinMeeting,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
