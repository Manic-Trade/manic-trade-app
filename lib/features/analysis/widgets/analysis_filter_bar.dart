import 'package:cached_network_image/cached_network_image.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/sheet/analysis_assets_filter_sheet.dart';
import 'package:finality/features/analysis/sheet/analysis_models_filter_sheet.dart';
import 'package:finality/features/analysis/sheet/analysis_time_range_filter_sheet.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';



/// Analysis 页面筛选栏
class AnalysisFilterBar extends StatelessWidget {
  final OptionsTradingPair? selectedPair;
  final ModeFilter selectedMode;
  final TimeRange selectedTimeRange;
  final ValueChanged<OptionsTradingPair?> onPairChanged;
  final ValueChanged<ModeFilter> onModeChanged;
  final ValueChanged<TimeRange> onTimeRangeChanged;

  const AnalysisFilterBar({
    super.key,
    required this.selectedPair,
    required this.selectedMode,
    required this.selectedTimeRange,
    required this.onPairChanged,
    required this.onModeChanged,
    required this.onTimeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Dimens.edgeInsetsScreenH,
      child: Row(
        children: [
          Expanded(child: _buildAssetDropdown(context)),
          Dimens.hGap8,
          Expanded(child: _buildModeDropdown(context)),
          Dimens.hGap8,
          Expanded(child: _buildTimeRangeDropdown(context)),
        ],
      ),
    );
  }

  Widget _buildAssetDropdown(BuildContext context) {
    return Touchable.plain(
      onTap: () async {
        final result = await showAnalysisAssetsFilterSheet(
          context,
          selectedAsset: selectedPair?.baseAsset,
        );
        if (result != null) {
          onPairChanged(result.tradingPair);
        }
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.only(left: 12, right: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            if (selectedPair != null) ...[
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: selectedPair!.iconUrl,
                  width: 16,
                  height: 16,
                  errorWidget: (_, __, ___) =>
                      const SizedBox(width: 16, height: 16),
                ),
              ),
              Dimens.hGap4,
            ],
            Expanded(
              child: Text(
                selectedPair?.baseAssetName ?? 'All Assets',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDropdown(BuildContext context) {
    return _buildFilterButton(
      context,
      label: selectedMode.label,
      onTap: () async {
        final result = await showAnalysisModelsFilterSheet(
          context,
          selectedMode: selectedMode,
        );
        if (result != null) {
          onModeChanged(result);
        }
      },
    );
  }

  Widget _buildTimeRangeDropdown(BuildContext context) {
    return _buildFilterButton(
      context,
      label: selectedTimeRange.label,
      onTap: () async {
        final result = await showAnalysisTimeRangeFilterSheet(
          context,
          selectedTimeRange: selectedTimeRange,
        );
        if (result != null) {
          onTimeRangeChanged(result);
        }
      },
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Touchable.plain(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.only(left: 12, right: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }
}

