import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loyalty_card_wallet/utils/barcode_utils.dart';

class BarcodeScannerService {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  MobileScannerController get controller => _controller;

  Future<Map<String, String>?> processBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty) return null;
    
    final Barcode barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;
    
    if (rawValue == null) return null;
    
    // Try to identify the barcode format
    final String format = BarcodeUtils.getBarcodeFormat(barcode.format);
    
    // Try to extract card information from the barcode
    final Map<String, String> cardInfo = BarcodeUtils.extractCardInfo(rawValue, format);
    
    // Add the barcode value and type to the result
    cardInfo['barcodeValue'] = rawValue;
    cardInfo['barcodeType'] = format;
    
    return cardInfo;
  }

  void toggleTorch() {
    _controller.toggleTorch();
  }

  void dispose() {
    _controller.dispose();
  }
}
