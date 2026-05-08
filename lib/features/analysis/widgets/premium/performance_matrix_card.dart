import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/performance_matrix_fl_chart.dart';
import 'package:finality/features/analysis/widgets/premium/performance_matrix_painter_chart.dart';
// import 'package:finality/features/analysis/widgets/premium/performance_matrix_fl_chart.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// Performance Matrix 卡片
///
/// 图表实现有两个版本可切换：
/// - [PerformanceMatrixPainterChart] — CustomPainter 手绘，完整 CRT 特效
/// - [PerformanceMatrixFlChart] — fl_chart 实现，代码更简洁
class PerformanceMatrixCard extends StatelessWidget {
  final List<PerformancePointVO> points;
  final TimeRange timeRange;

  const PerformanceMatrixCard({
    super.key,
    required this.points,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Dimens.vGap12,
        // === 切换图表实现：注释/取消注释即可 ===
        //PerformanceMatrixPainterChart(points: points),
         PerformanceMatrixFlChart(points: points, timeRange: timeRange),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE MATRIX',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.15),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        Dimens.vGap2,
        Text(
          'Correlating trade volume against realized net P&L',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: kPremiumOrange.withValues(alpha: 0.3),
          ),
        ),
        Dimens.vGap8,
        // 图例胶囊
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(1000),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'VOLUME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.3),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 6,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9E1A),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9E1A).withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'NET P&L',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.3),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
