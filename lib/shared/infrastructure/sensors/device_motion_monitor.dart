import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// Decides whether the phone is held steady from a stream of motion rates.
///
/// The rate is smoothed, and the phone only counts as steady after staying
/// calm for [settleTime], so a brief pause while moving does not count.
/// Two limits (hysteresis) keep the state from flickering near the edge.
class SteadinessDetector {
  /// Smoothed motion below which the phone starts counting as calm.
  static const steadyBelow = 0.12;

  /// Smoothed motion above which the phone counts as moving again.
  static const movingAbove = 0.3;

  static const settleTime = Duration(milliseconds: 400);
  static const _smoothing = 0.25;

  double _smoothed = 0;
  DateTime? _calmSince;
  bool _isSteady = false;

  bool get isSteady => _isSteady;

  /// Adds a motion sample taken at [time] and returns the current state.
  bool add(double rate, DateTime time) {
    _smoothed += (rate - _smoothed) * _smoothing;
    if (_smoothed > movingAbove) {
      _calmSince = null;
      _isSteady = false;
    } else if (_smoothed < steadyBelow) {
      _calmSince ??= time;
      if (time.difference(_calmSince!) >= settleTime) _isSteady = true;
    } else {
      _calmSince = null;
    }
    return _isSteady;
  }
}

/// Reports whether the phone is held steady, to help avoid blurry photos.
class DeviceMotionMonitor {
  /// Emits true when the phone is steady and false while it moves.
  ///
  /// Uses the gyroscope (rotation in rad/s), which best captures hand shake.
  /// Phones without one fall back to the change of acceleration between
  /// samples. Without any sensor it reports steady, so nothing is blocked.
  Stream<bool> watch() async* {
    final detector = SteadinessDetector();
    bool? last;
    await for (final rate in _motionRates()) {
      final steady = rate == null || detector.add(rate, DateTime.now());
      if (steady != last) yield last = steady;
    }
  }

  /// Motion samples, or a single null when the phone has no motion sensor.
  Stream<double?> _motionRates() async* {
    try {
      await for (final event in gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      )) {
        yield _length(event.x, event.y, event.z);
      }
    } catch (_) {
      try {
        AccelerometerEvent? previous;
        await for (final event in accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        )) {
          if (previous != null) {
            yield _length(
              event.x - previous.x,
              event.y - previous.y,
              event.z - previous.z,
            );
          }
          previous = event;
        }
      } catch (_) {
        yield null;
      }
    }
  }

  static double _length(double x, double y, double z) =>
      math.sqrt(x * x + y * y + z * z);
}
