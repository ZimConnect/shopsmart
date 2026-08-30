import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;

  Future<void> printReceipt(Map sale) async {
    String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    await printer.printCustom("ShopSmart Tuckshop", 3, 1); // Bold, Center
    await printer.printCustom("123 Samora Machel Ave, Harare", 1, 1);
    await printer.printCustom("Tel: 0772 123 456", 1, 1);
    await printer.printCustom("TPIN: 10012345", 1, 1);
    await printer.printNewLine();

    await printer.printCustom("Receipt: ${sale['receipt_number']}", 1, 0);
    await printer.printCustom("Date: $date", 1, 0);
    await printer.printCustom("Cashier: ${sale['cashier']}", 1, 0);
    await printer.printCustom("-----------------------------", 1, 0);

    for (var item in sale['items']) {
      String line = "${item['name']}".padRight(15) +
                    "${item['qty']}".padLeft(3) +
                    "\$${(item['qty'] * item['selling_price']).toStringAsFixed(2)}".padLeft(8);
      await printer.printCustom(line, 1, 0);
    }

    await printer.printCustom("-----------------------------", 1, 0);
    await printer.printCustom("SUBTOTAL:".padRight(20) + "\$${sale['subtotal'].toStringAsFixed(2)}".padLeft(8), 1, 0);
    await printer.printCustom("VAT 15.5%:".padRight(20) + "\$${sale['vat'].toStringAsFixed(2)}".padLeft(8), 1, 0);
    await printer.printCustom("TOTAL:".padRight(20) + "\$${sale['total'].toStringAsFixed(2)}".padLeft(8), 2, 0);
    await printer.printCustom("TENDERED:".padRight(20) + "\$${sale['amount_tendered'].toStringAsFixed(2)}".padLeft(8), 1, 0);
    await printer.printCustom("CHANGE:".padRight(20) + "\$${sale['change'].toStringAsFixed(2)}".padLeft(8), 1, 0);
    await printer.printNewLine();
    await printer.printCustom("PAYMENT: ${sale['payment_method']}", 1, 1);
    await printer.printCustom("QR: Fiscal Device Required", 1, 1);
    await printer.printCustom("**NOT A ZIMRA FISCAL INVOICE**", 1, 1);
    await printer.printCustom("Thank you! Come Again", 1, 1);
    await printer.printNewLine();
    await printer.paperCut();
  }
}
