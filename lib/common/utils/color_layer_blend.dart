import 'dart:ui';

extension ColorLayerBlend on Color {
  /// Stack multiple semi-transparent [layers] on top of this color.
  ///
  /// Layers are applied bottom-to-top (first element is closest to the base).
  /// Each layer's own alpha is respected.
  ///
  /// ```dart
  /// final result = surfaceContainer.withLayers([
  ///   accent.withValues(alpha: 0.05),   // layer 1
  ///   highlight.withValues(alpha: 0.1), // layer 2 (on top of layer 1)
  /// ]);
  /// ```
  Color withLayers(List<Color> layers) {
    var result = this;
    for (final layer in layers) {
      result = Color.alphaBlend(layer, result);
    }
    return result;
  }
}
