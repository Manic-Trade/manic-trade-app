import 'package:flutter/material.dart';

class EditCleanButton extends StatefulWidget {
  final TextEditingController controller;
  final Function? onClear;
  final Widget? icon;
  final double? buttonSize;

  const EditCleanButton({
    super.key,
    required this.controller,
    this.onClear,
    this.icon,
    this.buttonSize,
  });

  @override
  State<EditCleanButton> createState() => _EditCleanButtonState();
}

class _EditCleanButtonState extends State<EditCleanButton> {
  late final VoidCallback _listener = _onChange;
  bool _isEmpty = true;

  @override
  void initState() {
    _isEmpty = widget.controller.text.isEmpty;
    widget.controller.addListener(_listener);
    super.initState();
  }

  void _onChange() {
    var isEmpty = widget.controller.text.isEmpty;
    if (isEmpty != _isEmpty) {
      setState(() {
        _isEmpty = isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: !_isEmpty,
        child: IconButton(
            style: widget.buttonSize != null
                ? IconButton.styleFrom(
                    minimumSize: Size(widget.buttonSize!, widget.buttonSize!))
                : null,
            onPressed: () {
              widget.controller.clear();
              widget.onClear?.call();
            },
            icon: widget.icon ?? const Icon(Icons.close)));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }
}
