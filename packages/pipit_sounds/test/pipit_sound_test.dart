import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:pipit/pipit.dart';
import 'package:pipit_sounds/pipit_sounds.dart';

// The bird's wing beat is 22 rad/s and its walk 7 rad/s (pipit_pose.dart); the
// flying and walking loops must be whole cycles of them to stay in step.
const _flap = 2 * 3.141592653589793 / 22;
const _stride = 2 * 3.141592653589793 / 7;

/// Sample rate, channels and length in seconds of a 16-bit PCM WAV file.
(int rate, int channels, double seconds) _wav(PipitSound sound) {
  final bytes = File('assets/sounds/${sound.name}.wav').readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF', reason: sound.name);
  expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE', reason: sound.name);
  final channels = data.getUint16(22, Endian.little);
  final rate = data.getUint32(24, Endian.little);
  final bits = data.getUint16(34, Endian.little);
  final frames = data.getUint32(40, Endian.little) ~/ (channels * bits ~/ 8);
  return (rate, channels, frames / rate);
}

void main() {
  test('every pose and reaction has a sound', () {
    expect({
      for (final p in PipitPose.values) PipitSound.ofPose(p),
    }, hasLength(PipitPose.values.length));
    expect({
      for (final r in PipitReaction.values) PipitSound.ofReaction(r),
    }, hasLength(PipitReaction.values.length));
    expect(PipitSound.ofPose(PipitPose.flying), PipitSound.flying);
    expect(PipitSound.ofReaction(PipitReaction.hop), PipitSound.hop);
  });

  test('every sound is a short mono 22 kHz wav in the bundle', () {
    for (final sound in PipitSound.values) {
      expect(sound.assetKey, endsWith('assets/sounds/${sound.name}.wav'));
      final (rate, channels, seconds) = _wav(sound);
      expect(rate, 22050, reason: sound.name);
      expect(channels, 1, reason: sound.name);
      expect(seconds, inExclusiveRange(0.05, 3), reason: sound.name);
    }
  });

  test('loops are whole cycles of the bird\'s motion', () {
    expect(_wav(PipitSound.flying).$3, moreOrLessEquals(4 * _flap, epsilon: 0.001));
    expect(_wav(PipitSound.walking).$3, moreOrLessEquals(_stride, epsilon: 0.001));
    for (final sound in PipitSound.values) {
      expect(
        sound.loops,
        [
          PipitSound.walking,
          PipitSound.flying,
          PipitSound.sleeping,
          PipitSound.working,
        ].contains(sound),
      );
    }
  });

  test('loops start and end in silence, so the seam is quiet', () {
    for (final sound in PipitSound.values.where((s) => s.loops)) {
      final bytes = File('assets/sounds/${sound.name}.wav').readAsBytesSync();
      final data = ByteData.sublistView(bytes);
      final first = data.getInt16(44, Endian.little).abs();
      final last = data.getInt16(bytes.length - 2, Endian.little).abs();
      expect(first, lessThan(300), reason: sound.name);
      expect(last, lessThan(300), reason: sound.name);
    }
  });
}
