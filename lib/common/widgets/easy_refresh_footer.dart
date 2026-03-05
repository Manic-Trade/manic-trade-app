import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';

class ListRefreshFooter extends Footer {
  ListRefreshFooter({super.position = IndicatorPosition.locator})
      : super(triggerOffset: 56, clamping: false, maxOverOffset: 56);

  @override
  Widget build(BuildContext context, IndicatorState state) {
    if (state.result == IndicatorResult.noMore) {
      return _theEndWidget(context);
    } else if (state.result == IndicatorResult.fail) {
      return _failWidget();
    }
    //  else if (state.result == IndicatorResult.success) {
    //   return const SizedBox.shrink();
    // }
    if (state.mode == IndicatorMode.inactive) {
      return const SizedBox.shrink();
    }
    return _loadingWidget();
  }

  Widget _theEndWidget(BuildContext context) {
    return SizedBox(
      key: const ValueKey('indicator'),
      height: 56,
      child: Center(
        child: Text(
          context.strings.message_no_more,
          style: TextStyle(
              fontSize: 14, color: context.textColorTheme.textColorSecondary),
        ),
      ),
    );
  }

  Widget _failWidget() {
    return const SizedBox(
        key: ValueKey('indicator'),
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 24,
                width: 24,
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                )),
          ],
        ));
  }

  Widget _loadingWidget() {
    return const SizedBox(
        key: ValueKey('indicator'),
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ));
  }
}
