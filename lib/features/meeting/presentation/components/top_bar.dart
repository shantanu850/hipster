import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/urls.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/meeting_state.dart';
import '../meeting_state_provider.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  static const Map<MeetingStatus, Color> _statusColors = {
    MeetingStatus.idle: AppColors.textMuted,
    MeetingStatus.joining: AppColors.warning,
    MeetingStatus.connected: AppColors.success,
    MeetingStatus.disconnected: AppColors.error,
  };

  static const Map<MeetingStatus, String> _statusTexts = {
    MeetingStatus.idle: 'Idle',
    MeetingStatus.joining: 'Joining...',
    MeetingStatus.connected: 'Connected',
    MeetingStatus.disconnected: 'Disconnected',
  };

  void _showParticipantsSelector(BuildContext context, MeetingState state) {
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
                  'Meeting Participants',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.attendees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No participants in this call',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...state.attendees.map((attendee) {
                    final isSelf =
                        attendee.attendeeId == state.activeAttendeeId;
                    final isAgent = attendee.externalUserId
                        .toLowerCase()
                        .contains('agent');

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAgent
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.secondary.withValues(alpha: 0.25),
                        child: Icon(
                          Icons.person_rounded,
                          color: isAgent
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                      ),
                      title: Text(
                        isSelf
                            ? 'You (${isAgent ? "Agent" : "Client"})'
                            : attendee.formattedExternalId,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        attendee.attendeeId,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAgent
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAgent ? 'Agent' : 'Client',
                          style: TextStyle(
                            color: isAgent
                                ? AppColors.primary
                                : AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
    final status = ref.watch(meetingProvider.select((s) => s.status));
    final meetingId =
        ref.watch(meetingProvider.select((s) => s.activeMeetingId)) ??
        'Unknown';
    final attendees = ref.watch(meetingProvider.select((s) => s.attendees));

    final statusColor = _statusColors[status] ?? AppColors.textMuted;
    final statusText = _statusTexts[status] ?? 'Unknown';

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.people_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                final state = ref.read(meetingProvider);
                _showParticipantsSelector(context, state);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (attendees.isNotEmpty)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '${attendees.length}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),

        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          color: AppColors.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.surfaceLight, width: 1),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onSelected: (value) async {
            if (value == 'copy') {
              Clipboard.setData(ClipboardData(text: meetingId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Meeting ID copied to clipboard! ($meetingId)'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (value == 'share') {
              final text =
                  '${AppStrings.invitationPrefix}$meetingId\nAPI Server: ${AppUrls.apiBaseUrl}';
              await SharePlus.instance.share(
                ShareParams(
                  text: text,
                  subject: 'Hipster Video Meeting Invitation',
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'copy',
              child: Row(
                children: [
                  Icon(
                    Icons.copy_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Copy Code',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  Icon(
                    Icons.share_rounded,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Share Invitation',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
