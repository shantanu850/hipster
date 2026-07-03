import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_amazon_chime/flutter_amazon_chime.dart';
import 'api_client.dart';

class MeetingApiService {
  final ApiClient apiClient;

  MeetingApiService(this.apiClient);

  Future<JoinInfo> createMeeting() async {
    final response = await apiClient.post(
      '/meetings',
      queryParams: {'type': 'agent'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return _parseJoinInfo(body['data']);
      }
      throw Exception(body['message'] ?? 'Failed to create meeting');
    } else {
      throw Exception(
        'Server responded with status code ${response.statusCode}',
      );
    }
  }

  Future<JoinInfo> joinMeeting(
    String meetingId, {
    required bool isAgent,
  }) async {
    final response = await apiClient.post(
      '/meetings',
      queryParams: {
        'type': isAgent ? 'agent' : 'client',
        'meeting_id': meetingId.trim(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return _parseJoinInfo(body['data']);
      }
      throw Exception(body['message'] ?? 'Failed to join meeting');
    } else {
      throw Exception(
        'Server responded with status code ${response.statusCode}',
      );
    }
  }

  JoinInfo _parseJoinInfo(Map<String, dynamic> data) {
    final meeting = (data['meeting'] as Map<String, dynamic>?) ?? {};
    final mediaPlacement =
        ((meeting['MediaPlacement'] ?? meeting['mediaPlacement'])
            as Map<String, dynamic>?) ??
        {};
    final attendee = (data['attendee'] as Map<String, dynamic>?) ?? {};
    final audioFallBackUrl =
        mediaPlacement['AudioFallbackUrl'] ??
        mediaPlacement['audioFallbackUrl'];
    final difFallBack =
        'wss://wss.k.m1.as1.app.chime.aws:443/calls/${meeting['MeetingId']}';
    final signalingUrl =
        'wss://signal.m1.as1.app.chime.aws/control/${meeting['MeetingId']}';

    final flatJson = {
      'MeetingId': meeting['MeetingId'] ?? '',
      'ExternalMeetingId': meeting['ExternalMeetingId'] ?? '',
      'MediaRegion': meeting['MediaRegion'] ?? 'ap-southeast-1',
      'AudioHostUrl':
          mediaPlacement['AudioHostUrl'] ??
          mediaPlacement['audioHostUrl'] ??
          'c98cdd79639fadfb70890016890e1a22.k.m1.as1.app.chime.aws:3478',
      'AudioFallbackUrl': audioFallBackUrl ?? difFallBack,
      'SignalingUrl':
          mediaPlacement['SignalingUrl'] ??
          mediaPlacement['signalingUrl'] ??
          signalingUrl,
      'TurnControlUrl':
          mediaPlacement['TurnControlUrl'] ??
          mediaPlacement['turnControlUrl'] ??
          'https://2954.cell.ap-southeast-1.meetings.chime.aws/v2/turn_sessions',
      'ExternalUserId': attendee['ExternalUserId'] ?? '',
      'AttendeeId': attendee['AttendeeId'] ?? '',
      'JoinToken': attendee['JoinToken'] ?? '',
    };
    final joinInfo = JoinInfo.fromJson(flatJson);
    // if (joinInfo.audioHostUrl.isEmpty || joinInfo.audioFallbackUrl.isEmpty) {
    //   throw StateError(
    //     'Meeting response did not include Chime media placement URLs. Verify the backend response shape for /meetings.',
    //   );
    // }

    return joinInfo;
  }
}
