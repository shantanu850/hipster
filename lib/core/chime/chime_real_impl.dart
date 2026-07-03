import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_amazon_chime/flutter_amazon_chime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chime_controller.dart';

class ChimeRealImpl implements ChimeController {
  final AmazonChime _chime = AmazonChime.instance;
  
  bool _isMuted = false;
  bool _isVideoOn = false;

  @override
  bool get isMuted => _isMuted;

  @override
  bool get isVideoOn => _isVideoOn;

  @override
  Future<void> join(JoinInfo joinInfo) async {
    debugPrint('ChimeRealImpl: Starting join...');
    
    debugPrint('ChimeRealImpl: Requesting OS permissions...');
    try {
      await [
        Permission.microphone,
        Permission.camera,
      ].request();
      debugPrint('ChimeRealImpl: OS permissions request completed.');
    } catch (e) {
      debugPrint('ChimeRealImpl: Error requesting OS permissions: $e');
    }

    debugPrint('ChimeRealImpl: Requesting Chime audio permissions...');
    try {
      await _chime.requestAudioPermissions();
      debugPrint('ChimeRealImpl: Chime audio permissions request completed.');
    } catch (e) {
      debugPrint('ChimeRealImpl: Error requesting Chime audio permissions: $e');
    }

    debugPrint('ChimeRealImpl: Requesting Chime video permissions...');
    try {
      await _chime.requestVideoPermissions();
      debugPrint('ChimeRealImpl: Chime video permissions request completed.');
    } catch (e) {
      debugPrint('ChimeRealImpl: Error requesting Chime video permissions: $e');
    }
    
    debugPrint('ChimeRealImpl: Joining meeting natively...');
    try {
      await _chime.joinMeeting(joinInfo);
      debugPrint('ChimeRealImpl: Joined meeting natively.');
    } catch (e) {
      debugPrint('ChimeRealImpl: Error joining meeting: $e');
      rethrow;
    }
    
    _isMuted = false;
    _isVideoOn = false; // Start with video OFF to prevent hardware camera crashes
    
    debugPrint('ChimeRealImpl: Unmuting...');
    try {
      await _chime.unmute();
      debugPrint('ChimeRealImpl: Unmuted.');
    } catch (e) {
      debugPrint('ChimeRealImpl: Error unmuting: $e');
    }

    debugPrint('ChimeRealImpl: Local video disabled on startup (safer configuration).');
  }

  @override
  Future<void> leave() async {
    await _chime.stopMeeting();
    _isMuted = false;
    _isVideoOn = false;
  }

  @override
  Future<void> toggleMute(bool mute) async {
    if (mute) {
      await _chime.mute();
    } else {
      await _chime.unmute();
    }
    _isMuted = mute;
  }

  @override
  Future<void> toggleVideo(bool videoOn) async {
    if (videoOn) {
      await _chime.startLocalVideo();
    } else {
      await _chime.stopLocalVideo();
    }
    _isVideoOn = videoOn;
  }
  @override
  Future<void> switchCamera() async {
    await _chime.switchCamera();
  }

  @override
  Future<List<String>> listAudioDevices() async {
    return await _chime.listAudioDevices();
  }

  @override
  Future<void> updateAudioDevice(String device) async {
    await _chime.updateAudioDevice(device);
  }

  @override
  Future<String?> getActiveCamera() async {
    return await _chime.activeCamera();
  }

  @override
  Stream<Attendee> get onAttendeeJoined => _chime.onAttendeeJoined;

  @override
  Stream<Attendee> get onAttendeeLeft => _chime.onAttendeeLeft;

  @override
  Stream<VideoTileInfo> get onVideoTileAdded => _chime.onVideoTileAdded;

  @override
  Stream<VideoTileInfo> get onVideoTileRemoved => _chime.onVideoTileRemoved;
}
