import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/wallet_avatar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateContactDialog extends StatefulWidget {
  final String address;
  final String? initialName;
  final Future<void> Function(String name) onSave;

  const CreateContactDialog({
    super.key,
    required this.address,
    this.initialName,
    required this.onSave,
  });

  @override
  State<CreateContactDialog> createState() => _CreateContactDialogState();
}

class _CreateContactDialogState extends State<CreateContactDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    try {
      await widget.onSave(_nameController.text.trim());
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      logger.e("save contact failed", error: e, stackTrace: stackTrace);
      if (mounted) {
        Fluttertoast.showToast(msg: context.strings.message_save_failed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            WalletAvatar(
              avatar: widget.address,
              size: 64,
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: context.strings.label_contact_name,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textColorTheme.textColorTertiary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                maxLength: 20,
                buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.address
                    .truncateWithEllipsis(prefixLength: 8, suffixLength: 8),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textColorTheme.textColorPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 28),
            Divider(thickness: 0.7),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: Touchable(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          context.strings.cancel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textColorTheme.textColorSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(thickness: 0.7),
                  Expanded(
                    child: Touchable(
                      onTap: _handleSave,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          context.strings.action_save,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showCreateContactDialog(BuildContext context,
    {required NetworkAddressPair networkAddressPair,
    String? name,
    required Future<void> Function(String name) onSave}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => CreateContactDialog(
      address: networkAddressPair.address,
      initialName: name,
      onSave: onSave,
    ),
  );
}
