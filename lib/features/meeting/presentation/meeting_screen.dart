import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/meeting_state.dart';
import 'meeting_state_provider.dart';
import 'components/top_bar.dart';
import 'components/video_grid.dart';
import 'components/event_log_panel.dart';
import 'components/meeting_controls_bar.dart';

class MeetingScreen extends ConsumerStatefulWidget {
  const MeetingScreen({super.key});

  @override
  ConsumerState<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends ConsumerState<MeetingScreen> {
  bool _isExiting = false;
  MeetingStateNotifier? _meetingNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _meetingNotifier ??= ref.read(meetingProvider.notifier);
  }

  @override
  void dispose() {
    if (!_isExiting) {
      _isExiting = true;
      final notifier = _meetingNotifier;
      if (notifier != null) {
        unawaited(notifier.leaveMeeting(updateState: false));
      }
    }
    super.dispose();
  }

  Future<void> _endCurrentMeeting() async {
    final notifier = _meetingNotifier;
    if (notifier == null) {
      return;
    }

    if (!mounted) {
      await notifier.leaveMeeting();
      return;
    }

    final currentStatus = ref.read(meetingProvider).status;
    if (currentStatus == MeetingStatus.idle ||
        currentStatus == MeetingStatus.disconnected) {
      return;
    }

    if (!_isExiting) {
      _isExiting = true;
    }

    await notifier.leaveMeeting();
  }

  Future<void> _showExitConfirmationSheet() async {
    final isAgent = ref.read(meetingProvider).isAgent;
    final title = isAgent
        ? AppStrings.endMeetingTitle
        : AppStrings.leaveMeetingTitle;
    final description = isAgent
        ? AppStrings.endMeetingDescription
        : AppStrings.leaveMeetingDescription;
    final confirmText = isAgent
        ? AppStrings.endMeetingConfirm
        : AppStrings.leaveMeetingConfirm;

    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.surfaceLight),
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(AppStrings.cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldExit == true && mounted) {
      _isExiting = true;
      await _endCurrentMeeting();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MeetingStatus>(meetingProvider.select((s) => s.status), (
      previous,
      current,
    ) {
      if (!_isExiting && current == MeetingStatus.idle && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
      }
    });

    ref.listen<String?>(meetingProvider.select((s) => s.errorMessage), (
      previous,
      next,
    ) {
      if (previous == next || next == null || !mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final currentStatus = ref.read(meetingProvider).status;
        if (currentStatus == MeetingStatus.idle ||
            currentStatus == MeetingStatus.disconnected) {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          return;
        }

        await _showExitConfirmationSheet();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TopBar(),
        ),
        body: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: VideoGrid(),
                  ),
                ),
                MeetingControlsBar(),
                SizedBox(height: 52),
              ],
            ),
            const EventLogPanel(),
          ],
        ),
      ),
    );
  }
}
