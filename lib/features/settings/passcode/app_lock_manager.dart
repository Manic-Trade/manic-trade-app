import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/features/settings/passcode/pin_lock_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockManager {
  AppLockManager(this._preferences)
      : pinLockManager = PinLockManager(_preferences);

  final SharedPreferences _preferences;
  final PinLockManager pinLockManager;

  late ValueListenable<bool> isTransactionLockNotifier =
      ValueNotifier(isTransactionLock);

  bool get isTransactionLock =>
      _preferences.getBool("isTransactionLock") ?? true;

  set isTransactionLock(bool value) {
    _preferences.setBool("isTransactionLock", value);
    (isTransactionLockNotifier as ValueNotifier).value = value;
  }

  late ValueListenable<bool> isEnableBiometricNotifier =
      ValueNotifier(isEnableBiometric);

  bool get isEnableBiometric =>
      _preferences.getBool("isEnableBiometric") ?? true;

  set isEnableBiometric(bool value) {
    _preferences.setBool("isEnableBiometric", value);
    (isEnableBiometricNotifier as ValueNotifier).value = value;
  }

  bool get isEnable => pinLockManager.isSetPin;

  ValueListenable<bool> get isEnableNotifier => pinLockManager.isSetPinNotifier;

  void resetLock() {
    pinLockManager.resetLock();
    isTransactionLock = false;
    isEnableBiometric = true;
  }

  Future<VerificationResult<T>> verification<T>(BuildContext context,
      {FutureOr<T?> Function()? onSuccess, Function()? onFailure}) async {
    if (!isEnable) {
      var result = await onSuccess?.call();
      return VerificationResult(true, result);
    }
    Completer<VerificationResult<T>> completer = Completer();
    onSuccessWarp() async {
      try {
        var result = await onSuccess?.call();
        completer.complete(VerificationResult(true, result));
      } catch (error) {
        completer.completeError(error);
      }
    }

    onFailureWarp() async {
      try {
        await onFailure?.call();
        completer.complete(VerificationResult(false, null));
      } catch (error) {
        completer.completeError(error);
      }
    }

    if (isEnable) {
      if (isEnableBiometric) {
        screenLock(
          context: context,
          correctString: 'x' * 6,
          onValidate: (value) async {
            return await pinLockManager.verification(value);
          },
          onUnlocked: () async {
            Navigator.pop(context);
            await onSuccessWarp.call();
          },
          customizedButtonChild: const Icon(
            Icons.fingerprint,
          ),
          onCancelled: onFailure != null
              ? () async {
                  Navigator.pop(context);
                  await onFailureWarp.call();
                }
              : null,
          customizedButtonTap: () async =>
              await _biometricAuth(context, onSuccessWarp),
          onOpened: () async => await _biometricAuth(context, onSuccessWarp),
        );
      } else {
        screenLock(
            context: context,
            correctString: 'x' * 6,
            onValidate: (value) async {
              return await pinLockManager.verification(value);
            },
            onCancelled: onFailure != null
                ? () async {
                    Navigator.pop(context);
                    await onFailureWarp.call();
                  }
                : null,
            onUnlocked: () async {
              Navigator.pop(context);
              await onSuccessWarp.call();
            });
      }
    } else {
      await onSuccessWarp.call();
    }
    return completer.future;
  }

  Future<VerificationResult<T>> verificationTransaction<T>(BuildContext context,
      {FutureOr<T> Function()? onSuccess, Function()? onFailure}) async {
    if (isTransactionLock) {
      return verification(context, onSuccess: onSuccess, onFailure: onFailure);
    } else {
      var result = await onSuccess?.call();
      return VerificationResult(true, result);
    }
  }

  Future<bool> _biometricAuth(
      BuildContext context, Function()? onSuccess) async {
    try {
      final localAuth = LocalAuthentication();
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        if (context.mounted) {
          Navigator.pop(context);
        }
        await onSuccess?.call();
      }
      return didAuthenticate;
    } catch (error) {
      logger.e(error);
    }
    return false;
  }
}

class VerificationResult<T> {
  final bool verified;
  final T? result;

  VerificationResult(this.verified, this.result);
}
