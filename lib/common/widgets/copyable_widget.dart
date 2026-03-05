import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class CopyController extends ChangeNotifier {
  void copy() {
    notifyListeners();
  }
}

class CopyableWidget extends StatefulWidget {
  final Widget child;
  final String content;
  final Widget Function(BuildContext context)? copiedBuilder;
  final Duration showDuration;
  final CopyController? controller;
  final bool clickable;
  final void Function()? onCopyTap;
  final bool maintain;

  const CopyableWidget(
      {super.key,
      required this.child,
      required this.content,
      this.copiedBuilder,
      this.controller,
      this.showDuration = const Duration(seconds: 1),
      this.clickable = true,
      this.onCopyTap,
      this.maintain = false});

  @override
  State<CopyableWidget> createState() => _CopyableWidgetState();
}

class _CopyableWidgetState extends State<CopyableWidget> {
  bool _showCopied = false;
  Timer? _copiedTimer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleCopy);
  }

  @override
  void didUpdateWidget(CopyableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleCopy);
      widget.controller?.addListener(_handleCopy);
    }
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    widget.controller?.removeListener(_handleCopy);
    super.dispose();
  }

  void _handleCopy() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _copiedTimer?.cancel();

    try {
      await Clipboard.setData(ClipboardData(text: widget.content));
      if (!mounted) return;

      setState(() {
        _showCopied = true;
      });

      _copiedTimer = Timer(widget.showDuration, () {
        if (!mounted) return;
        setState(() {
          _showCopied = false;
        });
        _copiedTimer = null;
      });
    } catch (e) {
      // 处理剪贴板错误
      //debugPrint('复制到剪贴板失败: $e');
      setState(() {
        _showCopied = false;
      });
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.maintain) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              visible: _showCopied,
              child: widget.copiedBuilder?.call(context) ??
                  _defaultCopiedBuilder(context)),
          Visibility(
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              visible: !_showCopied,
              child: widget.child)
        ],
      );
    } else {
      child = _showCopied
          ? widget.copiedBuilder?.call(context) ??
              _defaultCopiedBuilder(context)
          : widget.child;
    }
    if (!widget.clickable) {
      return child;
    }
    return Touchable.plain(
      onTap: widget.controller == null
          ? () {
              _handleCopy();
              widget.onCopyTap?.call();
            }
          : () {
              widget.controller!.copy();
              widget.onCopyTap?.call();
            },
      child: child,
    );
  }

  Widget _defaultCopiedBuilder(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 16,
        ),
        Dimens.hGap4,
        Text(
          context.strings.copied,
          style: TextStyle(color: Colors.green),
        ),
      ],
    );
  }
}
