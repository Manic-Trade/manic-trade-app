import 'dart:io';
import 'dart:math';

import 'package:finality/features/utilities/scan/scan_qr_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/theme/styles.dart';
import 'package:zxing2/qrcode.dart';

class ScanQrScreen extends StatefulWidget {
  final bool onlyResult;

  const ScanQrScreen({super.key, this.onlyResult = false});

  @override
  State<StatefulWidget> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: context.colorScheme.surface,
        ),
        actionsIconTheme: IconThemeData(
          color: context.colorScheme.surface,
        ),
        systemOverlayStyle:
            AppStyles.immersiveSystemUiOverlayStyle(context, isDark: true),
        actions: [
          IconButton(
              icon: const Icon(Icons.image),
              tooltip: 'Scanner QR',
              onPressed: () async {
                _scanImage();
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  bool onPermissionSetCall = false;

  Widget _buildQrView(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = min(width, height) * 0.6;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) {
        if (!onPermissionSetCall) {
          _onPermissionSet(context, ctrl, p);
          onPermissionSetCall = true;
        }
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.resumeCamera();
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        result = scanData;
      });
      var code = scanData.code;

      if (_handlerResult(code)) {
      } else {
        if (context.mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              controller.resumeCamera();
            }
          });
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p && this.context.mounted) {
      logger.d("_onPermissionSet");
      var snackBar =
          SnackBar(content: Text(context.strings.message_scan_permission_set));
      ScaffoldMessenger.of(this.context).showSnackBar(snackBar);
    }
  }

  bool _handlerResult(String? result) {
    if (result != null) {
      if (widget.onlyResult) {
        Navigator.pop(context, result);
        return true;
      }

      Get.to(() => ScanQrResultScreen(result: result));
    } else {
      Fluttertoast.showToast(msg: context.strings.message_not_recognized);
    }
    return false;
  }

  _scanImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      var image =
          img.decodeNamedImage(file.path, File(file.path).readAsBytesSync())!;

      LuminanceSource source = RGBLuminanceSource(
          image.width,
          image.height,
          image
              .convert(numChannels: 4)
              .getBytes(order: img.ChannelOrder.abgr)
              .buffer
              .asInt32List());
      var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

      var reader = QRCodeReader();
      try {
        var result = reader.decode(bitmap);
        _handlerResult(result.text);
      } catch (e) {
        if (context.mounted) {
          Fluttertoast.showToast(msg: context.strings.message_not_recognized);
        }
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    //  ScaffoldMessenger.of(context).clearSnackBars();
    //ScaffoldMessenger.of(context).hideCurrentSnackBar();
    super.dispose();
  }
}
