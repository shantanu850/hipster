import 'package:flutter_amazon_chime/flutter_amazon_chime.dart';

abstract class ChimeController {
  Future<void> join(JoinInfo joinInfo);
  Future<void> leave();
  Future<void> toggleMute(bool isMuted);
  Future<void> toggleVideo(bool isVideoOn);
  Future<void> switchCamera();
  Future<List<String>> listAudioDevices();
  Future<void> updateAudioDevice(String device);
  Future<String?> getActiveCamera();
  
  Stream<Attendee> get onAttendeeJoined;
  Stream<Attendee> get onAttendeeLeft;
  Stream<VideoTileInfo> get onVideoTileAdded;
  Stream<VideoTileInfo> get onVideoTileRemoved;
  
  bool get isMuted;
  bool get isVideoOn;
}
