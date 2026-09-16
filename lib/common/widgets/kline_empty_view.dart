import 'package:finality/common/widgets/empty_view.dart';
import 'package:flutter/material.dart';

class KlineEmptyView extends StatelessWidget {
  const KlineEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: EmptyView(),
    );
  }
}
