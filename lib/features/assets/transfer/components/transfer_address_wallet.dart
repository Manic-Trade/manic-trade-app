import 'package:collection/collection.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:flutter/material.dart';
import 'package:finality/features/assets/transfer/components/wallet_item_widget.dart';

class TransferAddressWallet extends StatefulWidget {
  final List<UnifiedWalletAccounts> walletAccounts;
  final FocusNode focusNode;
  final ValueNotifier<NetworkAddressPair?> selectedNetworkAddress;
  final ScrollController? scrollController;
  const TransferAddressWallet(
      {super.key,
      required this.walletAccounts,
      required this.focusNode,
      required this.selectedNetworkAddress,
      this.scrollController});

  @override
  State<TransferAddressWallet> createState() => _TransferAddressWalletState();
}

class _TransferAddressWalletState extends State<TransferAddressWallet>
    with AutomaticKeepAliveClientMixin {
  final ValueKey _listViewKey = ValueKey('transfer_address_wallet_list_view');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      widget.selectedNetworkAddress.addListener(_scrollToSelectedItem);
    }
  }

  void _scrollToSelectedItem() {
    var networkAddressPair = widget.selectedNetworkAddress.value;
    if (networkAddressPair != null) {
      var index = widget.walletAccounts.indexWhere((element) =>
          element.accounts.first.address == networkAddressPair.address);
      if (index != -1) {
        Future.delayed(const Duration(milliseconds: 210), () {
          scrollToIndex(widget.scrollController!, index);
        });
      }
    }
  }

  void scrollToIndex(ScrollController scrollController, int index) {
    if (index >= 0 &&
        index < widget.walletAccounts.length &&
        scrollController.hasClients) {
      final itemHeight = 68.0;
      final targetOffset = index * itemHeight;

      var position = scrollController.positions.firstWhereOrNull((position) {
        final storageContext = position.context.storageContext;
        var listView = storageContext.findAncestorWidgetOfExactType<ListView>();
        return listView?.key == _listViewKey;
      });
      if (position == null) {
        return;
      }

      // 获取当前滚动位置和可视区域信息
      final currentOffset = position.pixels;
      final viewportHeight = position.viewportDimension;

      // 计算目标 item 的可见范围
      final itemStart = targetOffset;
      final itemEnd = targetOffset + itemHeight;

      // 计算当前可视区域的可见范围
      final visibleStart = currentOffset;
      final visibleEnd = currentOffset + viewportHeight;

      // 只有当目标 item 完全可见时才不滚动
      // 如果 item 只是部分可见（itemStart < visibleStart 或 itemEnd > visibleEnd），也需要滚动
      if (itemStart < visibleStart || itemEnd > visibleEnd) {
        final maxScrollExtent = position.maxScrollExtent;
        // 计算需要滚动的最小距离
        double newOffset;
        if (itemEnd <= visibleStart) {
          // item 在可视区域上方，滚动到 item 刚好可见
          newOffset = itemStart;
        } else {
          // item 在可视区域下方，滚动到 item 刚好可见
          newOffset = itemEnd - viewportHeight;
        }

        final clampedOffset = newOffset.clamp(0.0, maxScrollExtent);

        position.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      }
    }
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    widget.selectedNetworkAddress.removeListener(_scrollToSelectedItem);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      key: _listViewKey,
      controller: widget.scrollController,
      itemExtent: 68,
      itemCount: widget.walletAccounts.length,
      itemBuilder: (context, index) {
        return _buildWalletItem(context, widget.walletAccounts[index]);
      },
    );
  }

  Widget _buildWalletItem(BuildContext context, UnifiedWalletAccounts walletAccount) {
    return ValueListenableBuilder(
        valueListenable: widget.selectedNetworkAddress,
        builder: (context, value, child) {
          var networkAddressPair = NetworkAddressPair(
              walletAccount.accounts.first.networkCode,
              walletAccount.accounts.first.address);
          var isSelected = value == networkAddressPair;

          return WalletItemWidget(
            walletAccount: walletAccount,
            isSelected: isSelected,
            onTap: () {
              widget.focusNode.unfocus();
              if (widget.selectedNetworkAddress.value == networkAddressPair) {
                widget.selectedNetworkAddress.value = null;
              } else {
                widget.selectedNetworkAddress.value = networkAddressPair;
              }
            },
          );
        });
  }
}
