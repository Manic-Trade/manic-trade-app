import 'package:collection/collection.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/features/assets/transfer/components/saved_address_item_widget.dart';
import 'package:finality/features/assets/transfer/components/wallet_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:finality/data/drift/user_preferences_database.dart';
import 'package:finality/features/assets/transfer/components/recent_address_item_widget.dart';

class TransferAddressRecent extends StatefulWidget {
  final List<RecentSentAddress> recentSentAddresses;
  final List<SavedAddress> savedAddresses;
  final List<UnifiedWalletAccounts> otherUnifiedWalletAccounts;
  final FocusNode focusNode;
  final ValueNotifier<NetworkAddressPair?> selectedNetworkAddress;
  final ScrollController? scrollController;
  final Function(RecentSentAddress)? onDeleteRecentAddress;
  const TransferAddressRecent(
      {super.key,
      required this.recentSentAddresses,
      required this.focusNode,
      required this.selectedNetworkAddress,
      this.scrollController,
      required this.otherUnifiedWalletAccounts,
      required this.savedAddresses,
      this.onDeleteRecentAddress});

  @override
  State<TransferAddressRecent> createState() => _TransferAddressRecentState();
}

class _TransferAddressRecentState extends State<TransferAddressRecent>
    with AutomaticKeepAliveClientMixin {
  final ValueKey _listViewKey = ValueKey('transfer_address_recent_list_view');

  final Map<NetworkAddressPair, UnifiedWalletAccounts> walletAccountsMap = {};
  final Map<NetworkAddressPair, SavedAddress> savedAddressMap = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      widget.selectedNetworkAddress.addListener(_scrollToSelectedItem);
    }
    for (var element in widget.otherUnifiedWalletAccounts) {
      for (var account in element.accounts) {
        walletAccountsMap[
            NetworkAddressPair(account.networkCode, account.address)] = element;
      }
    }
    for (var element in widget.savedAddresses) {
      savedAddressMap[
          NetworkAddressPair(element.networkCode, element.address)] = element;
    }
  }

  @override
  void didUpdateWidget(covariant TransferAddressRecent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.otherUnifiedWalletAccounts != oldWidget.otherUnifiedWalletAccounts) {
      walletAccountsMap.clear();
      for (var element in widget.otherUnifiedWalletAccounts) {
        for (var account in element.accounts) {
          walletAccountsMap[
                  NetworkAddressPair(account.networkCode, account.address)] =
              element;
        }
      }
    }
    if (widget.savedAddresses != oldWidget.savedAddresses) {
      savedAddressMap.clear();
      for (var element in widget.savedAddresses) {
        savedAddressMap[
            NetworkAddressPair(element.networkCode, element.address)] = element;
      }
    }
  }

  void _scrollToSelectedItem() {
    var networkAddressPair = widget.selectedNetworkAddress.value;
    if (networkAddressPair != null) {
      var index = widget.recentSentAddresses.indexWhere(
          (element) => element.address == networkAddressPair.address);
      if (index != -1) {
        Future.delayed(const Duration(milliseconds: 210), () {
          scrollToIndex(widget.scrollController!, index);
        });
      }
    }
  }

  void scrollToIndex(ScrollController scrollController, int index) {
    if (index >= 0 &&
        index < widget.recentSentAddresses.length &&
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
      itemCount: widget.recentSentAddresses.length,
      itemBuilder: (context, index) {
        return _buildItem(context, widget.recentSentAddresses[index]);
      },
    );
  }

  Widget _buildItem(BuildContext context, RecentSentAddress recentSentAddress) {
    return ValueListenableBuilder(
        valueListenable: widget.selectedNetworkAddress,
        builder: (context, value, child) {
          var networkAddressPair = NetworkAddressPair(
              recentSentAddress.networkCode, recentSentAddress.address);
          var isSelected = value == networkAddressPair;
          onTap() {
            widget.focusNode.unfocus();
            if (widget.selectedNetworkAddress.value == networkAddressPair) {
              widget.selectedNetworkAddress.value = null;
            } else {
              widget.selectedNetworkAddress.value = networkAddressPair;
            }
          }

          var walletAccounts = walletAccountsMap[networkAddressPair];
          if (walletAccounts != null) {
            return WalletItemWidget(
              walletAccount: walletAccounts,
              isSelected: isSelected,
              onTap: onTap,
              lastUsedAt: recentSentAddress.lastUsedAt,
              onDelete: widget.onDeleteRecentAddress != null
                  ? () {
                      if (widget.selectedNetworkAddress.value ==
                          networkAddressPair) {
                        widget.selectedNetworkAddress.value = null;
                      }
                      widget.onDeleteRecentAddress!(recentSentAddress);
                    }
                  : null,
            );
          }
          var savedAddress = savedAddressMap[networkAddressPair];
          if (savedAddress != null) {
            return SavedAddressItemWidget(
              savedAddress: savedAddress,
              isSelected: isSelected,
              onTap: onTap,
              lastUsedAt: recentSentAddress.lastUsedAt,
              onDelete: widget.onDeleteRecentAddress != null
                  ? () {
                      if (widget.selectedNetworkAddress.value ==
                          networkAddressPair) {
                        widget.selectedNetworkAddress.value = null;
                      }
                      widget.onDeleteRecentAddress!(recentSentAddress);
                    }
                  : null,
            );
          }

          return RecentAddressItemWidget(
            recentSentAddress: recentSentAddress,
            isSelected: isSelected,
            onTap: onTap,
            onDelete: widget.onDeleteRecentAddress != null
                ? () {
                    if (widget.selectedNetworkAddress.value ==
                        networkAddressPair) {
                      widget.selectedNetworkAddress.value = null;
                    }
                    widget.onDeleteRecentAddress!(recentSentAddress);
                  }
                : null,
          );
        });
  }
}
