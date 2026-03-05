import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/bottom_sheet_navigator.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/user_preferences_database.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/domain/crypto/solana_address_verify.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:finality/features/assets/transfer/components/create_contact_dialog.dart';
import 'package:finality/features/assets/transfer/components/saved_address_item_widget.dart';
import 'package:finality/features/assets/transfer/components/transfer_address_recent.dart';
import 'package:finality/features/assets/transfer/components/transfer_address_saved.dart';
import 'package:finality/features/assets/transfer/components/transfer_address_wallet.dart';
import 'package:finality/features/assets/transfer/components/valid_address_item_widget.dart';
import 'package:finality/features/assets/transfer/components/wallet_item_widget.dart';
import 'package:finality/features/assets/transfer/execute/withdraw_execute_logic.dart';
import 'package:finality/features/assets/transfer/execute_status.dart';
import 'package:finality/features/assets/transfer/transfer_address_vm.dart';
import 'package:finality/features/assets/transfer/widgets/action_slider_button.dart';
import 'package:finality/features/assets/transfer/widgets/transaction_status_text.dart';
import 'package:finality/features/utilities/scan/scan_qr_screen.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/routes/navigation_helper.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:store_scope/store_scope.dart';

class TransferAddressSheet extends StatefulWidget {
  final AccountNetwork accountNetwork;
  final Token token;
  final String amount;

  const TransferAddressSheet(
      {super.key,
      required this.accountNetwork,
      required this.token,
      required this.amount});

  @override
  State<TransferAddressSheet> createState() => _TransferAddressSheetState();
}

class _TransferAddressSheetState extends State<TransferAddressSheet>
    with ScopedStateMixin, TickerProviderStateMixin {
  static const Duration _debounceDuration = Duration(milliseconds: 200);
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const Duration _opacityDuration = Duration(milliseconds: 100);
  static const int _tabTypeRecent = 0;
  static const int _tabTypeOtherWallets = 1;
  static const int _tabTypeSaved = 2;

  late final WithdrawExecuteLogic logic = WithdrawExecuteLogic(
      accountNetwork: widget.accountNetwork,
      token: widget.token,
      amount: widget.amount);
  late final TransferAddressVM vm;
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool?> _verifiedAddressNotifier = ValueNotifier(null);
  final ValueNotifier<NetworkAddressPair?> _selectedNetworkAddress =
      ValueNotifier(null);

  /// 保存按钮的显示状态
  /// 返回值：
  /// - null: 显示二维码扫描（未输入地址、地址不合法、是我的钱包）
  /// - true: 显示保存按钮（未保存且不是我的钱包）
  /// - false: 显示修改按钮（已保存）
  late final ValueListenable<bool?> saveButtonState = ComputedNotifier4(
      source1: _verifiedAddressNotifier,
      source2: _selectedNetworkAddress,
      source3: vm.savedAddresses,
      source4: vm.otherWalletAccounts,
      compute: (isValid, selectedNetworkAddress, savedAddresses,
          otherWalletAccounts) {
        NetworkAddressPair? networkAddressPair = selectedNetworkAddress;
        if (networkAddressPair == null && isValid == true) {
          networkAddressPair = NetworkAddressPair(
              widget.accountNetwork.network.networkCode,
              _addressController.text.trim());
        }
        return networkAddressPair != null
            ? vm.getSaveButtonState(networkAddressPair)
            : null;
      });

  Timer? _debounceTimer;
  TabController? _tabController;
  int? _currentTabType;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_debouncedValidateAddress);
    vm = context.store
        .bindWithScoped(transferAddressVMProvider(widget.accountNetwork), this);
  }

  void _debouncedValidateAddress() {
    _debounceTimer?.cancel();
    _selectedNetworkAddress.value = null;
    var text = _addressController.text;
    if (text.isEmpty) {
      _verifiedAddressNotifier.value = null;
      return;
    }
    _debounceTimer = Timer(_debounceDuration, () async {
      _verifiedAddressNotifier.value = await SolanaAddressVerify.validate(text);
    });
  }

  @override
  void dispose() {
    _addressController.removeListener(_debouncedValidateAddress);
    _addressController.dispose();
    _focusNode.dispose();
    logic.dispose();
    _debounceTimer?.cancel();
    _verifiedAddressNotifier.dispose();
    _selectedNetworkAddress.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  Future<void> _scanQRCode() async {
    _focusNode.unfocus();
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const ScanQrScreen(onlyResult: true),
      ),
    );

    if (result != null) {
      if (result.startsWith("solana:")) {
        _addressController.text = result.substring(7);
      } else {
        _addressController.text = result;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "${context.strings.action_send} ${widget.amount} ${widget.token.symbol}",
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          ValueListenableBuilder(
              valueListenable: saveButtonState,
              builder: (context, state, child) {
                if (state != null) {
                  if (state) {
                    return Touchable.iconButton(
                      child: IconButton(
                        icon: Icon(
                            Icons
                                .person_add_alt_rounded, //manage_accounts_rounded
                            color: Colors.blueAccent,
                            size: 24),
                        onPressed: () {
                          toAddContact(context, isEdit: false);
                        },
                      ),
                    );
                  } else {
                    return Touchable.iconButton(
                      child: IconButton(
                        icon: SvgPicture.asset(
                          Assets.svgsMaterialSymbolPersonEdit,
                          width: 24,
                          height: 24,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          toAddContact(context, isEdit: true);
                        },
                      ),
                    );
                  }
                }

                return ValueListenableBuilder(
                    valueListenable: _selectedNetworkAddress,
                    builder: (context, value, child) {
                      return Visibility(
                        visible: value == null,
                        child: Touchable.iconButton(
                          child: IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner_rounded,
                            ),
                            onPressed: () {
                              _scanQRCode();
                            },
                          ),
                        ),
                      );
                    });
              })
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Dimens.vGap6,
                      ValueListenableBuilder<NetworkAddressPair?>(
                        valueListenable: _selectedNetworkAddress,
                        builder: (context, selectedAddress, child) {
                          return AnimatedContainer(
                            alignment: Alignment.topLeft,
                            duration: _animationDuration,
                            curve: selectedAddress == null
                                ? Curves.easeOutBack // 显示时使用 easeOutBack 产生弹出效果
                                : Curves.easeInOutCubicEmphasized,
                            height: selectedAddress == null ? 56 : 0,
                            child: ClipRect(
                              child: AnimatedOpacity(
                                duration: _opacityDuration,
                                opacity: selectedAddress == null ? 1.0 : 0.0,
                                child: _buildAddressInputField(context),
                              ),
                            ),
                          );
                        },
                      ),
                      Dimens.vGap16,
                      ValueListenableBuilder(
                          valueListenable: _addressController,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) {
                              return _buildRecommendedAddresses(context);
                            }
                            return _buildInputAddressVerify(context);
                          }),
                    ],
                  ),
                ),
                ValueListenableBuilder<NetworkAddressPair?>(
                  valueListenable: _selectedNetworkAddress,
                  builder: (context, selectedNetworkAddress, child) {
                    return AnimatedSize(
                      duration: _animationDuration,
                      curve: selectedNetworkAddress == null
                          ? Curves.easeInOutCubicEmphasized
                          : Curves.easeOutBack,
                      child: selectedNetworkAddress != null
                          ? _buildSendSliderButton(
                              selectedNetworkAddress.address)
                          : const SizedBox(width: double.infinity, height: 0),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toAddContact(BuildContext context, {required bool isEdit}) {
    NetworkAddressPair? networkAddressPair = _selectedNetworkAddress.value;
    if (networkAddressPair == null && _verifiedAddressNotifier.value == true) {
      networkAddressPair = NetworkAddressPair(
          widget.accountNetwork.network.networkCode,
          _addressController.text.trim());
    }
    if (networkAddressPair == null) {
      return;
    }
    String? name;
    DateTime createdAt = DateTime.now();
    var address = networkAddressPair.address;
    var networkCode = networkAddressPair.networkCode;
    if (isEdit) {
      var savedAddress = vm.savedAddresses.value.firstWhere((element) =>
          element.address == address && element.networkCode == networkCode);
      name = savedAddress.label;
      createdAt = savedAddress.createdAt;
    }
    showCreateContactDialog(
      context,
      name: name,
      networkAddressPair: networkAddressPair,
      onSave: (name) async {
        vm.saveAddress(SavedAddress(
            networkCode: networkCode,
            address: address,
            label: name,
            createdAt: createdAt,
            updatedAt: DateTime.now()));
      },
    ).then((value) {
      if (value == true && context.mounted) {
        Fluttertoast.showToast(msg: context.strings.message_save_success);
      }
    });
  }

  void _onTabChanged() {
    var tabController = _tabController;
    if (tabController != null) {
      var index = tabController.index;
      var hasOtherWallets = vm.hasOtherWallets.value;
      var hasSaved = vm.hasSaved.value;
      var hasRecent = vm.hasRecent.value;

      final availableTabs = [
        if (hasRecent) _tabTypeRecent,
        if (hasOtherWallets) _tabTypeOtherWallets,
        if (hasSaved) _tabTypeSaved,
      ];

      if (index < availableTabs.length) {
        _currentTabType = availableTabs[index];
      }
    }
  }

  int _getInitialTabIndex(bool hasRecent, bool hasOtherWallets, bool hasSaved) {
    if (_currentTabType == null) return 0;

    final availableTabs = [
      if (hasRecent) _tabTypeRecent,
      if (hasOtherWallets) _tabTypeOtherWallets,
      if (hasSaved) _tabTypeSaved,
    ];

    if (availableTabs.isEmpty) return 0;

    final targetIndex = availableTabs.indexOf(_currentTabType!);
    if (targetIndex != -1) {
      return targetIndex;
    }
    return 0;
  }

  Widget _buildRecommendedAddresses(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder3(
          first: vm.hasRecent,
          second: vm.hasSaved,
          third: vm.hasOtherWallets,
          builder: (context, hasRecent, hasSaved, hasOtherWallets, child) {
            var length = 0;
            if (hasOtherWallets) {
              length++;
            }
            if (hasSaved) {
              length++;
            }
            if (hasRecent) {
              length++;
            }
            if (length == 0) {
              return const SizedBox.shrink();
            }
            _tabController?.removeListener(_onTabChanged);
            _tabController?.dispose();
            _tabController = TabController(
                length: length,
                vsync: this,
                initialIndex:
                    _getInitialTabIndex(hasRecent, hasOtherWallets, hasSaved));
            _onTabChanged();
            _tabController!.addListener(_onTabChanged);
            var scrollController = ModalScrollController.of(context);
            return Column(
              children: [
                _buildTabBar(context, hasRecent, hasSaved, hasOtherWallets),
                Dimens.vGap8,
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      if (hasRecent)
                        ValueListenableBuilder(
                            valueListenable: vm.recentSentAddresses,
                            builder: (context, value, child) {
                              return TransferAddressRecent(
                                  scrollController: scrollController,
                                  focusNode: _focusNode,
                                  selectedNetworkAddress:
                                      _selectedNetworkAddress,
                                  recentSentAddresses: value,
                                  otherUnifiedWalletAccounts:
                                      vm.otherWalletAccounts.value,
                                  savedAddresses: vm.savedAddresses.value,
                                  onDeleteRecentAddress: (recentSentAddress) {
                                    deleteRecentAddress(recentSentAddress);
                                  });
                            }),
                      if (hasOtherWallets)
                        ValueListenableBuilder(
                            valueListenable: vm.otherWalletAccounts,
                            builder: (context, value, child) {
                              return TransferAddressWallet(
                                  scrollController: scrollController,
                                  focusNode: _focusNode,
                                  selectedNetworkAddress:
                                      _selectedNetworkAddress,
                                  walletAccounts: value);
                            }),
                      if (hasSaved)
                        ValueListenableBuilder(
                            valueListenable: vm.savedAddresses,
                            builder: (context, value, child) {
                              return TransferAddressSaved(
                                  scrollController: scrollController,
                                  focusNode: _focusNode,
                                  selectedNetworkAddress:
                                      _selectedNetworkAddress,
                                  savedAddresses: value,
                                  onDelete: (savedAddress) {
                                    deleteSavedAddress(savedAddress);
                                  });
                            }),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  void deleteRecentAddress(RecentSentAddress recentSentAddress) {
    vm.deleteRecentAddress(recentSentAddress).then((value) {
      if (mounted) {
        Fluttertoast.showToast(msg: context.strings.deleted);
      }
    });
  }

  void deleteSavedAddress(SavedAddress savedAddress) {
    vm.deleteAddress(savedAddress).then((value) {
      if (mounted) {
        Fluttertoast.showToast(msg: context.strings.deleted);
      }
    });
  }

  Widget _buildTabBar(BuildContext context, bool hasRecent, bool hasSaved,
      bool hasOtherWallets) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicator: const BoxDecoration(),
      indicatorWeight: 0,
      labelColor: context.textColorTheme.textColorPrimary,
      unselectedLabelColor: context.textColorTheme.textColorSecondary,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
      tabs: [
        if (hasRecent)
          Tab(
            text: context.strings.title_transfer_recent_addresses,
          ),
        if (hasOtherWallets)
          Tab(
            text: context.strings.title_transfer_my_wallet,
          ),
        if (hasSaved)
          Tab(
            text: context.strings.title_transfer_address_book,
          ),
      ],
    );
  }

  Widget _buildInputAddressVerify(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _verifiedAddressNotifier,
      builder: (context, isValid, child) {
        if (isValid == null) {
          return const SizedBox.shrink();
        }

        return isValid
            ? _buildValidAddressRow(
                context,
                NetworkAddressPair(widget.accountNetwork.network.networkCode,
                    _addressController.text.trim()))
            : _buildInvalidAddressRow();
      },
    );
  }

  Widget _buildStatusText() {
    return ValueListenableBuilder<ExecuteStatus?>(
        valueListenable: logic.statusNotifier,
        builder: (context, status, child) {
          return TransactionStatusText(
            status: status,
            onViewTransaction: logic.txId != null
                ? () {
                    var transactionHash = logic.txId;
                    if (transactionHash != null) {
                      var txUrl = widget.accountNetwork.network.links
                          ?.formatTXUrl(transactionHash);
                      if (txUrl != null) {
                        BlockExplorerUtils.viewTransaction(txUrl);
                      }
                    }
                  }
                : null,
          );
        });
  }

  Widget _buildAddressInputField(BuildContext context) {
    return Padding(
      padding: Dimens.edgeInsetsH16,
      // decoration: BoxDecoration(
      //   color: const Color(0xFFF2F2F7),
      //   borderRadius: BorderRadius.circular(20),
      // ),
      child: TextField(
        focusNode: _focusNode,
        autofocus: false,
        keyboardType: TextInputType.visiblePassword,
        autocorrect: false,
        enableSuggestions: false,
        controller: _addressController,
        decoration: InputDecoration(
          fillColor: context.colorScheme.surfaceContainerHigh,
          filled: true,
          constraints: BoxConstraints(minHeight: 56),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: context.colorScheme.outlineVariant,
              width: 0.5, 
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: context.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1.0,
              child: Text(
                '${context.strings.title_to} ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1,
                ),
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _addressController,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return Touchable(
                  onTap: () {
                    Clipboard.getData(Clipboard.kTextPlain).then((value) {
                      var text = value?.text;
                      if (text != null) {
                        _addressController.text = text;
                      }
                    });
                  },
                  shrinkScaleFactor: 0.86,
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      widthFactor: 1.0,
                      child: Text(
                        context.strings.paste,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: context.textColorTheme.textColorPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Touchable.iconButton(
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                    onPressed: () {
                      _addressController.clear();
                    },
                  ),
                ),
              );
            },
          ),
          hintText:
              '${widget.accountNetwork.network.name} ${context.strings.title_address}',
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1,
            color: context.textColorTheme.textColorHelper,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 100),
        ),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildValidAddressRow(
      BuildContext context, NetworkAddressPair networkAddress) {
    return ValueListenableBuilder<NetworkAddressPair?>(
        valueListenable: _selectedNetworkAddress,
        builder: (context, selectedNetworkAddress, child) {
          onTap() {
            _focusNode.unfocus();
            if (_selectedNetworkAddress.value == networkAddress) {
              _selectedNetworkAddress.value = null;
              _requestFocus();
            } else {
              _selectedNetworkAddress.value = networkAddress;
            }
          }

          var isSelected = selectedNetworkAddress == networkAddress;
          var walletAccounts = vm.findWalletAccountsByAddress(networkAddress);
          if (walletAccounts != null) {
            return WalletItemWidget(
                walletAccount: walletAccounts,
                isSelected: isSelected,
                onTap: onTap);
          }
          return ValueListenableBuilder(
              valueListenable: vm.savedAddresses,
              builder: (context, value, child) {
                var savedAddress = value.firstWhereOrNull((element) =>
                    element.address == networkAddress.address &&
                    element.networkCode == networkAddress.networkCode);
                if (savedAddress != null) {
                  return SavedAddressItemWidget(
                      savedAddress: savedAddress,
                      isSelected: isSelected,
                      onTap: onTap,
                      isDeleteContact: true,
                      onDelete: () {
                        deleteSavedAddress(savedAddress);
                      });
                }
                return ValidAddressItemWidget(
                  networkAddress: networkAddress,
                  isSelected: isSelected,
                  onTap: onTap,
                );
              });
        });
  }

  Widget _buildInvalidAddressRow() {
    return SizedBox(
      height: 56,
      child: Center(
        child: Text(
          context.strings.message_transfer_invalid_address,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textColorTheme.textColorSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSendSliderButton(String? address) {
    return Column(
      children: [
        Dimens.vGap24,
        Padding(
          padding: Dimens.edgeInsetsH20,
          child: ActionSliderButton(
            enabled: address != null,
            context: context,
            onSuccess: () {
              if (context.mounted) {
                NavigationHelper.exitTransactionProcess(context);
              }
            },
            action: () async {
              if (address != null) {
                await logic.executeTransfer(toAddress: address);
                return false;
              }
              return true;
            },
            child: Text(
              context.strings.action_swipe_to_send,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Dimens.vGap16,
        _buildStatusText(),
        Dimens.vGap16,
      ],
    );
  }
}

Future<void> showTransferAddressSheet(BuildContext context,
    {required AccountNetwork accountNetwork,
    required Token token,
    required String amount}) {
  return showCupertinoModalBottomSheet<void>(
    context: context,
    expand: true,
    settings: const RouteSettings(name: RouteNames.transferAddress),
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    closeProgressThreshold: 0.5,
    builder: (_) => BottomSheetNavigator(
      useNavigator: false,
      builder: (_) {
        return TransferAddressSheet(
          accountNetwork: accountNetwork,
          token: token,
          amount: amount,
        );
      },
    ),
  );
}
