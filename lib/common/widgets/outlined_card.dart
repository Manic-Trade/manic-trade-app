import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OutlinedCard extends StatelessWidget {
  const OutlinedCard(
      {super.key,
      this.color,
      this.clipBehavior = Clip.antiAlias,
      this.margin,
      this.child,
      this.radius = 12,
      this.outlineColor});

  /// The card's background color.
  ///
  /// Defines the card's [Material.color].
  ///
  /// If this property is null then [CardTheme.color] of [ThemeData.cardTheme]
  /// is used. If that's null then [ThemeData.cardColor] is used.
  final Color? color;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// If this property is null then [CardTheme.clipBehavior] of
  /// [ThemeData.cardTheme] is used. If that's null then the behavior will be [Clip.none].
  final Clip? clipBehavior;

  /// The empty space that surrounds the card.
  ///
  /// Defines the card's outer [Container.margin].
  ///
  /// If this property is null then [CardTheme.margin] of
  /// [ThemeData.cardTheme] is used. If that's null, the default margin is 4.0
  /// logical pixels on all sides: `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry? margin;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  final double radius;

  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: context.theme.dividerTheme.thickness ?? 1,
            color:
                outlineColor ?? Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      clipBehavior: clipBehavior,
      margin: margin,
      child: child,
    );
  }

  static Color defaultOutlineColor(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;
}
