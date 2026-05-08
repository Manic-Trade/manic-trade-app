import 'package:finality/common/widgets/copyable_widget.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 充值地址展示区，含复制功能
class AddressSection extends StatefulWidget {
  final String address;
  final bool isLoading;

  const AddressSection(
      {super.key, required this.address, this.isLoading = false});

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  final _copyController = CopyController();

  @override
  void dispose() {
    _copyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton.unite(
          child: Row(
            children: [
              Text(
                'Your deposit address',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textColorTheme.textColorPrimary,
                    ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    'Send any accepted token to this address and it will auto swap to USDC on Solana in your account. Your first deposit may be credited in two transactions.',
                preferBelow: false,
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                textStyle: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                  color: context.textColorTheme.textColorTertiary,
                ).toClashDisplay(),
                child: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: context.textColorTheme.textColorSecondary,
                ),
              ),
            ],
          ),
        ),
        Dimens.vGap8,
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF262626)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0x33000000),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                ),
                child: !widget.isLoading
                    ? Text(
                        widget.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF666666),
                              height: 1.5,
                            ),
                      )
                    : Text(
                        'thisisplaceholdertextthisisplaceholdertextthisisplaceholdertext',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF666666),
                              height: 1.5,
                            ),
                      ),
              ),
              const Divider(height: 1, color: Color(0xFF262626)),
              CopyableWidget(
                controller: _copyController,
                content: widget.address,
                maintain: true,
                copiedBuilder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.svgsRemixCheckboxCircleLine,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Copied!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Skeleton.unite(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.svgsIcRemixCopy,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            context.textColorTheme.textColorPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Copy address',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: context.textColorTheme.textColorPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
