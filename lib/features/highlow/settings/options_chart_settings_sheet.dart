import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/highlow/config/options_chart_config.dart';
import 'package:finality/features/highlow/config/options_chart_config_store.dart';
import 'package:finality/features/highlow/config/options_settings_gulide_store.dart';
import 'package:finality/features/highlow/config/setting_manual_sheet.dart';
import 'package:finality/features/highlow/settings/setting_check_box_tile.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// Options chart settings page.
///
/// Configures chart display options for the options trading page.
/// Displayed as a BottomSheet with grouped two-column CheckBox layout.
class OptionsChartSettingsSheet extends StatefulWidget {
  const OptionsChartSettingsSheet({super.key});

  @override
  State<OptionsChartSettingsSheet> createState() =>
      _OptionsChartSettingsSheetState();
}

class _OptionsChartSettingsSheetState extends State<OptionsChartSettingsSheet> {
  final OptionsChartConfigStore _configStore =
      injector<OptionsChartConfigStore>();
  final OptionsSettingsGuideStore _guideStore =
      injector<OptionsSettingsGuideStore>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            Flexible(
              child: SingleChildScrollView(
                child: ValueListenableBuilder<OptionsChartConfig>(
                  valueListenable: _configStore.configNotifier,
                  builder: (context, config, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Dimens.vGap8,
                        _buildChartDisplaySection(context, config),
                        //  _buildLatestPriceSection(context, config),
                        _buildContractDisplaySection(context, config),
                        // _buildSettlementSection(context, config),
                        _buildChartBehaviorSection(context, config),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chart display settings
  Widget _buildChartDisplaySection(
      BuildContext context, OptionsChartConfig config) {
    return _buildSection(
      context,
      title: 'Chart Display',
      children: [
        _buildRow([
          _buildCheckBox(
            title: 'Grid Lines',
            value: config.showGrid,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(showGrid: v)),
          ),
          _buildCheckBox(
            title: 'Countdown',
            value: config.showCountdown,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(showCountdown: v)),
          ),
        ]),
        _buildRow([
          _buildCheckBox(
            title: 'Time Line',
            value: config.showCurrentEpochLine,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(showCurrentEpochLine: v)),
          ),
          _buildCheckBox(
            title: 'Settle Line',
            value: config.showSettlementLine,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(showSettlementLine: v)),
          ),
        ]),
      ],
    );
  }

  /// Latest price settings
  // Widget _buildLatestPriceSection(
  //     BuildContext context, OptionsChartConfig config) {
  //   return _buildSection(
  //     context,
  //     title: 'Latest Price',
  //     children: [
  //       _buildRow([
  //         _buildCheckBox(
  //           title: 'Full Price Line',
  //           value: config.latestPriceLineFullScreen,
  //           onChanged: (v) => _configStore
  //               .update((c) => c.copyWith(latestPriceLineFullScreen: v)),
  //         ),
  //         _buildCheckBox(
  //           title: 'Candle BG',
  //           value: config.useCandleColorAsLatestBg,
  //           onChanged: (v) => _configStore
  //               .update((c) => c.copyWith(useCandleColorAsLatestBg: v)),
  //         ),
  //       ]),
  //     ],
  //   );
  // }

  /// Order display settings
  Widget _buildContractDisplaySection(
      BuildContext context, OptionsChartConfig config) {
    return _buildSection(
      context,
      title: 'Order Settings',
      children: [
        _buildRow([
          _buildCheckBox(
            title: 'Long Entry',
            value: config.showLongEntryPrice,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(showLongEntryPrice: v)),
          ),
          _buildCheckBox(
            title: 'Short Entry',
            value: config.showShortEntryPrice,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(showShortEntryPrice: v)),
          ),
        ]),
        _buildRow([
          _buildGuideCheckBox(
            guidePoint: OptionsGuidePoint.doubleClickOrder,
            title: 'Double Tap to Order',
            value: config.showDoubleClickQuickOrder,
            onLabelTap: () {
              showSettingManualSheet(
                context,
                title: "Double Tap to Order",
                description:
                    "Double tap above the current price line to place a Higher order, or below it to place a Lower order.",
                image: Image.asset(Assets.optionsChartDoubleTapCreateOrderDark),
              );
            },
            onChanged: (v) => _configStore
                .update((c) => c.copyWith(showDoubleClickQuickOrder: v)),
          ),
        ]),
      ],
    );
  }

  /// Settlement settings
  // Widget _buildSettlementSection(
  //     BuildContext context, OptionsChartConfig config) {
  //   return _buildSection(
  //     context,
  //     title: 'Settlement',
  //     children: [
  //       _buildRow([
  //         _buildCheckBox(
  //           title: 'Time Line',
  //           value: config.showCurrentEpochLine,
  //           onChanged: (v) =>
  //               _configStore.update((c) => c.copyWith(showCurrentEpochLine: v)),
  //         ),
  //         _buildCheckBox(
  //           title: 'Settle Line',
  //           value: config.showSettlementLine,
  //           onChanged: (v) =>
  //               _configStore.update((c) => c.copyWith(showSettlementLine: v)),
  //         ),
  //       ]),
  //     ],
  //   );
  // }

  /// Chart behavior settings
  Widget _buildChartBehaviorSection(
      BuildContext context, OptionsChartConfig config) {
    return _buildSection(
      context,
      title: 'Chart Behavior',
      children: [
        _buildRow([
          _buildCheckBox(
            title: 'Auto-fit X',
            value: config.settlementXAxisAdaptive,
            onChanged: (v) => _configStore
                .update((c) => c.copyWith(settlementXAxisAdaptive: v)),
          ),
          _buildCheckBox(
            title: 'Auto-fit Y',
            value: config.entryPriceYAxisAdaptive,
            onChanged: (v) => _configStore
                .update((c) => c.copyWith(entryPriceYAxisAdaptive: v)),
          ),
        ]),
        _buildRow([
          _buildCheckBox(
            enabled: false,
            title: 'Line on Zoom',
            value: config.autoSwitchToLine,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(autoSwitchToLine: v)),
          ),
          _buildCheckBox(
            title: 'Drag Zoom Y',
            enabled: false,
            value: config.dragZoomYAxis,
            onChanged: (v) =>
                _configStore.update((c) => c.copyWith(dragZoomYAxis: v)),
          ),
        ]),
      ],
    );
  }

  /// Build a section group
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Dimens.vGap4,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textColorTheme.textColorSecondary,
              ),
            ),
          ),
          Dimens.vGap14,
          ...children,
          Dimens.vGap16,
        ],
      ),
    );
  }

  /// Build a row (two columns)
  Widget _buildRow(List<Widget> children) {
    // Pad with empty Expanded if only one element
    if (children.length == 1) {
      children.add(const Expanded(child: SizedBox()));
    }
    return Row(children: children);
  }

  /// Build a CheckBox tile
  Widget _buildCheckBox({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    VoidCallback? onLabelTap,
  }) {
    return Expanded(
      child: SettingCheckBoxTile(
        value: value,
        title: title,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
        enabled: enabled,
        onLabelTap: onLabelTap,
      ),
    );
  }

  /// Build a CheckBox tile with guide red dot badge.
  ///
  /// The red dot disappears once the user toggles the checkbox.
  Widget _buildGuideCheckBox({
    required OptionsGuidePoint guidePoint,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    VoidCallback? onLabelTap,
  }) {
    return Expanded(
      child: ValueListenableBuilder<bool>(
        valueListenable: _guideStore.showBadgeNotifier(guidePoint),
        builder: (context, showBadge, _) {
          return SettingCheckBoxTile(
            value: value,
            title: title,
            showBadge: showBadge,
            onChanged: enabled
                ? (v) {
                    // _guideStore.markSeen(guidePoint);
                    onChanged(v ?? false);
                  }
                : null,
            enabled: enabled,
            onLabelTap: onLabelTap == null
                ? null
                : () {
                    _guideStore.markSeen(guidePoint);
                    onLabelTap();
                  },
          );
        },
      ),
    );
  }
}

/// Show Options chart settings BottomSheet
Future<void> showOptionsChartSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    builder: (_) => const OptionsChartSettingsSheet(),
  );
}
