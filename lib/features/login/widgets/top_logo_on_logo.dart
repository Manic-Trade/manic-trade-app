import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class TopLogoOnLogo extends StatelessWidget {
  final Widget child;
  const TopLogoOnLogo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF211400),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary,
            offset: const Offset(0, 0),
            blurRadius: 8.17,
            spreadRadius: 0,
            inset: true,
          ),
        ],
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
