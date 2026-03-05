import 'package:flutter/material.dart';

class KlineLoadingView extends StatelessWidget {
  final Color progressBgColor;
  final Color valueColor;
  const KlineLoadingView({
    super.key,
    required this.progressBgColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(32),
      alignment: AlignmentDirectional.center,
      child: SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          backgroundColor: progressBgColor,
          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
        ),
      ),
    );
  }
}
