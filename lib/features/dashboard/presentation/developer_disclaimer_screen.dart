import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import 'components/developer_profile_card.dart';
import 'components/disclaimer_header.dart';
import 'components/feature_list_item.dart';
import 'components/staggered_fade_slide.dart';
import 'dashboard_screen.dart';

class DeveloperDisclaimerScreen extends StatefulWidget {
  const DeveloperDisclaimerScreen({super.key});

  @override
  State<DeveloperDisclaimerScreen> createState() => _DeveloperDisclaimerScreenState();
}

class _DeveloperDisclaimerScreenState extends State<DeveloperDisclaimerScreen> {
  int _animatedCount = 0;
  Timer? _animationTimer;

  static const List<({IconData icon, String title, String description})> _features = [
    (
      icon: Icons.video_call_rounded,
      title: 'Amazon Chime SDK Integration',
      description: 'Native audio/video call engine utilizing official backend session endpoints.',
    ),
    (
      icon: Icons.videocam_rounded,
      title: 'Hardware Camera Controls',
      description: 'Start/stop local camera capture seamlessly via floating call controls.',
    ),
    (
      icon: Icons.mic_rounded,
      title: 'Mute / Unmute Microphone',
      description: 'Toggle microphone stream natively on/off with color-coded button feedback.',
    ),
    (
      icon: Icons.flip_camera_ios_rounded,
      title: 'Dual-Camera Switching',
      description: 'Toggle between front and rear cameras instantly during active meetings.',
    ),
    (
      icon: Icons.volume_up_rounded,
      title: 'Audio Output Routing',
      description: 'Modal bottom sheet selector for Speaker, Earpiece/Handset, and Bluetooth output devices.',
    ),
    (
      icon: Icons.people_rounded,
      title: 'Participants List',
      description: 'Top-bar badge showing joined participants categorized by Client vs Agent.',
    ),
    (
      icon: Icons.share_rounded,
      title: 'Share invitations',
      description: 'Popup menu to copy Meeting ID or share invitation card via native OS share sheets.',
    ),
    (
      icon: Icons.playlist_add_check_rounded,
      title: 'Events Logs',
      description: 'Sliding panel logging real-time call lifecycle state transitions.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    int counter = 0;
    final totalItems = 4 + _features.length;
    _animationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _animatedCount = counter + 1;
      });
      counter++;
      if (counter >= totalItems) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                const SizedBox(height: 10),
                const DisclaimerHeader(),
                const SizedBox(height: 24),
                DeveloperProfileCard(
                  animatedCount: _animatedCount,
                  onPhoneTap: () => _makePhoneCall('+918509218271'),
                  onGithubTap: () => _launchUrl(AppUrls.github),
                  onLinkedInTap: () => _launchUrl(AppUrls.linkedIn),
                  onPortfolioTap: () => _launchUrl(AppUrls.portfolio),
                ),
                const SizedBox(height: 24),

                const Text(
                  AppStrings.implementedFeaturesTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                  ),
                  child: Column(
                    children: List.generate(_features.length, (index) {
                      final feature = _features[index];
                      return StaggeredFadeSlide(
                        isVisible: _animatedCount > (index + 4),
                        child: FeatureListItem(
                          icon: feature.icon,
                          title: feature.title,
                          description: feature.description,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.surfaceLight, width: 1.5),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              triggerButtonHaptic();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.proceedToDashboard,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
