import 'package:finality/common/widgets/triangle_widget.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';

showAddressItemDeletePopup(
  BuildContext context, {
  bool isDeleteContact = false,
  required void Function() onDelete,
}) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  var offsetY = renderBox.size.height * 0.15;
  return showPopupWindow(
    context,
    targetRenderBox: renderBox,
    gravity: KumiPopupGravity.centerTop,
    offsetY: offsetY,
    clickOutDismiss: true,
    clickBackDismiss: true,
    customAnimation: false,
    duration: const Duration(milliseconds: 150),
    customPop: false,
    customPage: false,
    bgColor: Colors.transparent,
    childFun: (popup) => _AddressItemDeletePopup(
      key: GlobalKey(),
      popup: popup,
      onDelete: onDelete,
      isDeleteContact: isDeleteContact,
    ),
  );
}

class _AddressItemDeletePopup extends StatelessWidget {
  final KumiPopupWindow popup;
  final void Function() onDelete;
  final bool isDeleteContact;

  const _AddressItemDeletePopup({
    super.key,
    required this.popup,
    required this.onDelete,
    required this.isDeleteContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: context.textColorTheme.textColorPrimary,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  popup.dismiss(context);
                  onDelete();
                },
                icon: Icon(isDeleteContact
                    ? Icons.person_remove_alt_1_rounded
                    : Icons.delete_outline_rounded,
                    color: context.textColorTheme.textColorPrimaryInverse),
              ),
            ],
          ),
        ),
        TriangleWidget(
          color: context.textColorTheme.textColorPrimary,
          width: 12,
          height: 6,
          pointingUp: false,
        ),
      ],
    );
  }
}
