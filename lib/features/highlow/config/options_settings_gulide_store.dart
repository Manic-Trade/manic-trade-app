import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guide points in the options trading module.
///
/// Each point represents a feature that shows a red dot badge
/// until the user has interacted with it.
enum OptionsGuidePoint {
  doubleClickOrder('options_guide_double_click_order'),
  livePositionsBar('options_guide_live_positions_bar');

  const OptionsGuidePoint(this.key);

  final String key;
}

/// Manages first-time guide dot (red badge) visibility for the options module.
///
/// Each [OptionsGuidePoint] tracks whether the user has seen/used that feature.
/// Provides a [ValueNotifier<bool>] per point so the UI can reactively
/// show or hide the red dot badge.
///
/// The notifier value is `true` when the badge should be shown
/// (user has NOT yet seen the feature).
class OptionsSettingsGuideStore {
  final SharedPreferencesWithCache _prefs;

  OptionsSettingsGuideStore(this._prefs);

  final Map<OptionsGuidePoint, ValueNotifier<bool>> _notifiers = {};

  late final ValueListenable<bool> showSettingsGuidBadgeNotifier =
      ComputedNotifier2(
    source1: showBadgeNotifier(OptionsGuidePoint.doubleClickOrder),
    source2: showBadgeNotifier(OptionsGuidePoint.livePositionsBar),
    compute: (value1, value2) => value1 || value2,
  );

  /// Get a [ValueNotifier] for whether the badge should be shown.
  ///
  /// Returns `true` = show red dot (user hasn't seen it yet).
  /// Returns `false` = hide red dot (user has already interacted).
  ValueNotifier<bool> showBadgeNotifier(OptionsGuidePoint point) {
    return _notifiers.putIfAbsent(
      point,
      () => ValueNotifier(!(_prefs.getBool(point.key) ?? false)),
    );
  }

  /// Whether the user has already seen this guide point.
  bool hasSeen(OptionsGuidePoint point) {
    return _prefs.getBool(point.key) ?? false;
  }

  /// Mark a guide point as seen. The red dot badge will disappear.
  Future<void> markSeen(OptionsGuidePoint point) async {
    await _prefs.setBool(point.key, true);
    _notifiers[point]?.value = false;
  }

  /// Reset all guide points (for testing / debug).
  Future<void> resetAll() async {
    for (final point in OptionsGuidePoint.values) {
      await _prefs.remove(point.key);
      _notifiers[point]?.value = true;
    }
  }
}
