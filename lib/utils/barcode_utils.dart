import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeUtils {
  static String getBarcodeFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR_CODE';
      case BarcodeFormat.aztec:
        return 'AZTEC';
      case BarcodeFormat.code128:
        return 'CODE_128';
      case BarcodeFormat.code39:
        return 'CODE_39';
      case BarcodeFormat.code93:
        return 'CODE_93';
      case BarcodeFormat.dataMatrix:
        return 'DATA_MATRIX';
      case BarcodeFormat.ean13:
        return 'EAN_13';
      case BarcodeFormat.ean8:
        return 'EAN_8';
      case BarcodeFormat.itf:
        return 'ITF';
      case BarcodeFormat.pdf417:
        return 'PDF_417';
      case BarcodeFormat.upcA:
        return 'UPC_A';
      case BarcodeFormat.upcE:
        return 'UPC_E';
      default:
        return 'UNKNOWN';
    }
  }

  static Map<String, String> extractCardInfo(String rawValue, String format) {
    final Map<String, String> result = {};
    
    // Try to extract card number
    result['cardNumber'] = rawValue;
    
    // Try to identify the card type based on the barcode format and value
    if (format == 'EAN_13' && rawValue.startsWith('977')) {
      result['name'] = 'Magazine Subscription';
    } else if (format == 'EAN_13' && rawValue.startsWith('978')) {
      result['name'] = 'Book Club';
    } else if (format == 'QR_CODE' && rawValue.contains('http')) {
      result['name'] = 'Web Loyalty Program';
    } else {
      result['name'] = 'Loyalty Card';
    }
    
    return result;
  }

  static bool isValidBarcode(String value, String format) {
    if (value.isEmpty) return false;
    
    switch (format) {
      case 'EAN_13':
        return value.length == 13 && _isNumeric(value);
      case 'EAN_8':
        return value.length == 8 && _isNumeric(value);
      case 'UPC_A':
        return value.length == 12 && _isNumeric(value);
      case 'UPC_E':
        return value.length == 8 && _isNumeric(value);
      case 'CODE_39':
        return RegExp(r'^[0-9A-Z\-\.\$\/\+\%\s]+$').hasMatch(value);
      case 'CODE_128':
        return value.isNotEmpty;
      case 'QR_CODE':
        return value.isNotEmpty;
      default:
        return value.isNotEmpty;
    }
  }

  static bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }
}
