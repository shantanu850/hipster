import 'dart:async';
import 'package:flutter_amazon_chime/flutter_amazon_chime.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/meeting_api_service.dart';
import '../../../core/chime/chime_controller.dart';
import '../../../core/chime/chime_real_impl.dart';
import '../../../core/constants/urls.dart';
import '../../../core/utils/haptics.dart';
import '../domain/meeting_event_log.dart';
import '../domain/meeting_state.dart';

class MeetingState {
  final MeetingStatus status;
  final bool isMuted;
  final bool isVideoOn;
  final List<Attendee> attendees;
  final List<VideoTileInfo> activeVideoTiles;
  final List<MeetingEventLog> logs;
  final String? activeMeetingId;
  final String? activeAttendeeId;
  final String? errorMessage;
  final String apiBaseUrl;
  final String apiKey;
  final String? activeCamera;
  final List<String> availableAudioDevices;
  final String? activeAudioDevice;
  final bool isAgent;

  MeetingState({
    this.status = MeetingStatus.idle,
    this.isMuted = false,
    this.isVideoOn = false,
    this.attendees = const [],
    this.activeVideoTiles = const [],
    this.logs = const [],
    this.activeMeetingId,
    this.activeAttendeeId,
    this.errorMessage,
    this.apiBaseUrl = AppUrls.apiBaseUrl,
    this.apiKey = const String.fromEnvironment('api_key'),
    this.activeCamera,
    this.availableAudioDevices = const [],
    this.activeAudioDevice,
    this.isAgent = false,
  });

  MeetingState copyWith({
    MeetingStatus? status,
    bool? isMuted,
    bool? isVideoOn,
    List<Attendee>? attendees,
    List<VideoTileInfo>? activeVideoTiles,
    List<MeetingEventLog>? logs,
    String? activeMeetingId,
    String? activeAttendeeId,
    String? errorMessage,
    String? apiBaseUrl,
    String? apiKey,
    String? activeCamera,
    List<String>? availableAudioDevices,
    String? activeAudioDevice,
    bool? isAgent,
  }) {
    return MeetingState(
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      attendees: attendees ?? this.attendees,
      activeVideoTiles: activeVideoTiles ?? this.activeVideoTiles,
      logs: logs ?? this.logs,
      activeMeetingId: activeMeetingId ?? this.activeMeetingId,
      activeAttendeeId: activeAttendeeId ?? this.activeAttendeeId,
      errorMessage: errorMessage,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiKey: apiKey ?? this.apiKey,
      activeCamera: activeCamera ?? this.activeCamera,
      availableAudioDevices: availableAudioDevices ?? this.availableAudioDevices,
      activeAudioDevice: activeAudioDevice ?? this.activeAudioDevice,
      isAgent: isAgent ?? this.isAgent,
    );
  }
}

class MeetingStateNotifier extends StateNotifier<MeetingState> {
  MeetingStateNotifier() : super(MeetingState()) {
    _addLog('System initialized. Ready to connect.');
  }

  ChimeController? _chimeController;
  final List<StreamSubscription> _subscriptions = [];
  bool _isDisposed = false;

  void setApiBaseUrl(String url) {
    state = state.copyWith(apiBaseUrl: url);
  }

  void setApiKey(String key) {
    state = state.copyWith(apiKey: key);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> hostMeeting() async {
    state = state.copyWith(status: MeetingStatus.joining, errorMessage: null, isAgent: true);
    _addLog('Hosting new meeting...');
    
    try {
      final apiService = MeetingApiService(ApiClient(
        baseUrl: state.apiBaseUrl,
        apiKey: state.apiKey,
      ));
      final joinInfo = await apiService.createMeeting();
      _chimeController = ChimeRealImpl();

      await _startChimeSession(joinInfo);
    } catch (e, stack) {
      debugPrint('Error hosting meeting: $e');
      debugPrintStack(stackTrace: stack);
      state = state.copyWith(
        status: MeetingStatus.idle,
        errorMessage: 'Failed to host meeting: ${e.toString()}',
      );
      _addLog('Error hosting meeting: $e');
    }
  }

  Future<void> joinMeeting(String meetingId, {required bool isAgent}) async {
    if (meetingId.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter a valid Meeting ID');
      return;
    }

    state = state.copyWith(status: MeetingStatus.joining, errorMessage: null, isAgent: isAgent);
    _addLog('Joining meeting: $meetingId...');
    
    try {
      final apiService = MeetingApiService(ApiClient(
        baseUrl: state.apiBaseUrl,
        apiKey: state.apiKey,
      ));
      final joinInfo = await apiService.joinMeeting(meetingId, isAgent: isAgent);
      _chimeController = ChimeRealImpl();

      await _startChimeSession(joinInfo);
    } catch (e, stack) {
      debugPrint('Error joining meeting: $e');
      debugPrintStack(stackTrace: stack);
      state = state.copyWith(
        status: MeetingStatus.idle,
        errorMessage: 'Failed to join meeting: ${e.toString()}',
      );
      _addLog('Error joining meeting: $e');
    }
  }

  Future<void> leaveMeeting({bool updateState = true}) async {
    if (_isDisposed) {
      await cleanupForDispose();
      return;
    }

    if (updateState) {
      _addLog('Leaving meeting...');
    }

    try {
      if (_chimeController != null) {
        await _chimeController!.leave();
      }
    } catch (e) {
      if (updateState) {
        _addLog('Error leaving session: $e');
      }
    } finally {
      _cleanupSession();
      if (!updateState) {
        return;
      }

      state = state.copyWith(
        status: MeetingStatus.disconnected,
        activeMeetingId: null,
        activeAttendeeId: null,
        attendees: [],
        activeVideoTiles: [],
        activeCamera: null,
        availableAudioDevices: const [],
        activeAudioDevice: null,
        isMuted: false,
        isVideoOn: false,
        isAgent: false,
      );
      _addLog('Meeting ended.');

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!_isDisposed) {
          state = state.copyWith(status: MeetingStatus.idle);
        }
      });
    }
  }

  Future<void> toggleMute() async {
    if (_chimeController == null) return;
    
    try {
      final newMute = !_chimeController!.isMuted;
      await _chimeController!.toggleMute(newMute);
      state = state.copyWith(isMuted: newMute);
      _addLog(newMute ? 'Microphone muted (disabled)' : 'Microphone unmuted (enabled)');
    } catch (e) {
      _addLog('Failed to toggle microphone: $e');
    }
  }

  Future<void> toggleVideo() async {
    if (_chimeController == null) return;
    
    try {
      final newVideo = !_chimeController!.isVideoOn;
      await _chimeController!.toggleVideo(newVideo);
      state = state.copyWith(isVideoOn: newVideo);
      _addLog(newVideo ? 'Camera enabled' : 'Camera disabled');
    } catch (e) {
      _addLog('Failed to toggle camera: $e');
    }
  }

  Future<void> switchCamera() async {
    if (_chimeController == null) return;
    try {
      await _chimeController!.switchCamera();
      final newCamera = await _chimeController!.getActiveCamera();
      state = state.copyWith(activeCamera: newCamera);
      _addLog('Switched camera. Active: $newCamera');
    } catch (e) {
      _addLog('Failed to switch camera: $e');
    }
  }

  Future<void> refreshAudioDevices() async {
    if (_chimeController == null) return;
    try {
      final devices = await _chimeController!.listAudioDevices();
      state = state.copyWith(availableAudioDevices: devices);
      _addLog('Available audio outputs: ${devices.join(", ")}');
    } catch (e) {
      _addLog('Failed to list audio devices: $e');
    }
  }

  Future<void> updateAudioDevice(String device) async {
    if (_chimeController == null) return;
    try {
      await _chimeController!.updateAudioDevice(device);
      state = state.copyWith(activeAudioDevice: device);
      _addLog('Audio output changed to: $device');
    } catch (e) {
      _addLog('Failed to change audio output: $e');
    }
  }

  Future<void> _startChimeSession(JoinInfo joinInfo) async {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    state = state.copyWith(
      activeMeetingId: joinInfo.meetingId,
      activeAttendeeId: joinInfo.attendeeId,
      isMuted: false,
      isVideoOn: false,
      attendees: [],
      activeVideoTiles: [],
    );

    _subscriptions.add(_chimeController!.onAttendeeJoined.listen((attendee) {
      final exists = state.attendees.any((a) => a.attendeeId == attendee.attendeeId);
      List<Attendee> updatedList;
      if (exists) {
        updatedList = state.attendees.map((a) => a.attendeeId == attendee.attendeeId ? attendee : a).toList();
      } else {
        updatedList = [...state.attendees, attendee];
      }
      state = state.copyWith(attendees: updatedList);

      final isSelf = attendee.attendeeId == state.activeAttendeeId;
      if (!isSelf) {
        triggerJoinHaptic();
      }
      _addLog('${isSelf ? "Local participant" : "Participant"} joined: ${attendee.formattedExternalId}');
    }));

    _subscriptions.add(_chimeController!.onAttendeeLeft.listen((attendee) {
      final updatedList = state.attendees.where((a) => a.attendeeId != attendee.attendeeId).toList();
      state = state.copyWith(attendees: updatedList);

      final isSelf = attendee.attendeeId == state.activeAttendeeId;
      _addLog('${isSelf ? "Local participant" : "Participant"} left: ${attendee.formattedExternalId}');
    }));

    _subscriptions.add(_chimeController!.onVideoTileAdded.listen((tile) {
      final exists = state.activeVideoTiles.any((t) => t.tileId == tile.tileId);
      List<VideoTileInfo> updatedTiles;
      if (exists) {
        updatedTiles = state.activeVideoTiles.map((t) => t.tileId == tile.tileId ? tile : t).toList();
      } else {
        updatedTiles = [...state.activeVideoTiles, tile];
      }
      state = state.copyWith(activeVideoTiles: updatedTiles);
      
      _addLog('${tile.isLocalTile ? "Local" : "Remote"} video stream tile active (ID: ${tile.tileId})');
    }));

    _subscriptions.add(_chimeController!.onVideoTileRemoved.listen((tile) {
      final updatedTiles = state.activeVideoTiles.where((t) => t.tileId != tile.tileId).toList();
      state = state.copyWith(activeVideoTiles: updatedTiles);
      
      _addLog('Video stream tile removed (ID: ${tile.tileId})');
    }));

    await _chimeController!.join(joinInfo);

    state = state.copyWith(
      status: MeetingStatus.connected,
      isMuted: _chimeController!.isMuted,
      isVideoOn: _chimeController!.isVideoOn,
    );
    _addLog('Connected to Amazon Chime Meeting Session.');
    
    await refreshAudioDevices();
    try {
      final activeCam = await _chimeController!.getActiveCamera();
      state = state.copyWith(activeCamera: activeCam);
    } catch (_) {}
  }

  Future<void> cleanupForDispose() async {
    _isDisposed = true;
    try {
      if (_chimeController != null) {
        await _chimeController!.leave();
      }
    } catch (e) {
      debugPrint('Error during meeting cleanup: $e');
    } finally {
      _cleanupSession();
    }
  }

  void _cleanupSession() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _chimeController = null;
  }

  void _addLog(String msg) {
    final newLog = MeetingEventLog(
      timestamp: DateTime.now(),
      message: msg,
    );
    state = state.copyWith(logs: [newLog, ...state.logs]);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cleanupSession();
    super.dispose();
  }
}

final meetingProvider = StateNotifierProvider<MeetingStateNotifier, MeetingState>((ref) {
  return MeetingStateNotifier();
});
