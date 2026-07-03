import 'package:flutter/services.dart';

void triggerButtonHaptic() {
  HapticFeedback.selectionClick();
}

void triggerJoinHaptic() {
  HapticFeedback.lightImpact();
}
