import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;

  Future<void> printReceipt(Map sale) async {
    String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    await printer.printCustom("ShopSmart Tuckshop", 3, 1);
    await printer.printCustom("123 Mbare Road, Harare", 1, 1);
    await printer.printCustom("0772 123 456", 1, 1);
    await printer.printCustom("Receipt: ${sale['receipt_number']}", 1, 0);
    await printer.printCustom("Date: $date", 1, 0);
    await printer.printCustom("Cashier: ${sale['cashier']}", 1, 0);
    await printer.printNewLine();
    await printer.printCustom("ITEM           QTY   PRICE", 1, 0);
    // loop items here
    await printer.printCustom("-----------------------------", 1, 0);
    await printer.printCustom("SUBTOTAL:      \$${sale['subtotal']}", 1, 2);
    await printer.printCustom("VAT 15.5%:     \$${sale['vat']}", 1, 2);
    await printer.printCustom("TOTAL:         \$${sale['total']}", 2, 2);
    await printer.printCustom("PAYMENT: ${sale['payment_method']}", 1, 0);
    await printer.printCustom("QR: For fiscal use only", 1, 1);
    await printer.printCustom("NOT A ZIMRA FISCAL INVOICE", 1, 1);
    await printer.printCustom("Thank you!", 1, 1);
    await printer.printNewLine();
    await printer.paperCut();
  }
}
