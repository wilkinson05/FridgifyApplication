import 'dart:io';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'global_product.dart';

class ScannerScreen extends StatefulWidget {
  final Function(String, String, String, File?, String, String) onProductAdded;

  ScannerScreen({required this.onProductAdded});
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String barcode = '';
  String productName = '';
  String expireDate = '';
  String purchaseDate = '';
  String price = '';
  String currency = 'Rp';

  Future<void> fetchProductInfo(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          productName = data['product'] != null && data['product']['product_name'] != null
              ? data['product']['product_name']
              : 'Unknown Product';
          expireDate = data['product'] != null && data['product']['expiration_date'] != null
              ? data['product']['expiration_date']
              : 'Unknown Expiry';
          purchaseDate = DateTime.now().toString().split(' ')[0]; 
          price = data['product'] != null && data['product']['price'] != null
              ? data['product']['price'].toString()
              : 'Unknown Price';

          GlobalProduct.productName = productName;
          GlobalProduct.expireDate = expireDate;
          GlobalProduct.purchaseDate = purchaseDate;
          GlobalProduct.price = price;
          GlobalProduct.currency = currency;
        });
      } else {
        setState(() {
          productName = 'Product not found';
        });
      }
    } catch (e) {
      setState(() {
        productName = 'Error fetching data';
      });
      print('Error: $e');
    }
  }

  Future<void> scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan(); 
      setState(() {
        barcode = result.rawContent;  
      });

      if (barcode != '-1') {
        fetchProductInfo(barcode);
      }
    } catch (e) {
      setState(() {
        barcode = 'Error: $e';  
      });
    }
  }

  void navigateToManualInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualInputScreen(
          productName: productName,
          expireDate: expireDate,
          purchaseDate: purchaseDate,
          price: price,
          currency: currency,
          onSave: (name, expiry, purchase, price, currency) {
            setState(() {
              productName = name;
              expireDate = expiry;
              purchaseDate = purchase;
              this.price = price;
              this.currency = currency;
            });
          },
        ),
      ),
    );
    GlobalProduct.productName = productName;
    GlobalProduct.expireDate = expireDate;
    GlobalProduct.purchaseDate = purchaseDate;
    GlobalProduct.price = price;
    GlobalProduct.currency = currency;
  }

  String formatPrice(String price) {
    double priceValue = double.tryParse(price) ?? 0.0;
    var formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: currency);

    if (currency == 'USD') {
      formatter = NumberFormat.simpleCurrency(locale: 'en_US', name: 'USD');
    }

    return formatter.format(priceValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Your Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (barcode.isNotEmpty) ...[
              Text(
                'Scanned Barcode: $barcode',  
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
            ],
            if (productName.isNotEmpty) ...[
              Text('Product Name: $productName'),
              Text('Expiration Date: $expireDate'),
              Text('Purchase Date: $purchaseDate'),
              Text('Price: ${formatPrice(price)}'),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanBarcode,  
              child: Text(
                'Scan Barcode',
                style: TextStyle(color: Colors.green),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToManualInput, 
              child: Text(
                'Enter Manually',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManualInputScreen extends StatefulWidget {
  final String productName;
  final String expireDate;
  final String purchaseDate;
  final String price;
  final String currency;
  final Function(String, String, String, String, String) onSave;

  ManualInputScreen({
    required this.productName,
    required this.expireDate,
    required this.purchaseDate,
    required this.price,
    required this.currency,
    required this.onSave,
  });

  @override
  _ManualInputScreenState createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  late TextEditingController _productNameController;
  late TextEditingController _expireDateController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _priceController;
  String selectedCurrency = 'Rp';

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(text: widget.productName);
    _expireDateController = TextEditingController(text: widget.expireDate);
    _purchaseDateController = TextEditingController(text: widget.purchaseDate);
    _priceController = TextEditingController(text: widget.price);
    selectedCurrency = widget.currency;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _expireDateController.dispose();
    _purchaseDateController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _selectCurrency() async {
    String? newCurrency = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Rp'),
                onTap: () => Navigator.pop(context, 'Rp'),
              ),
              ListTile(
                title: Text('USD'),
                onTap: () => Navigator.pop(context, 'USD'),
              ),
            ],
          ),
        );
      },
    );

    if (newCurrency != null) {
      setState(() {
        selectedCurrency = newCurrency;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _expireDateController,
              decoration: InputDecoration(labelText: 'Expiration Date'),
              keyboardType: TextInputType.datetime,
              onTap: () {
                _selectDate(context, _expireDateController);
              },
            ),
            TextField(
              controller: _purchaseDateController,
              decoration: InputDecoration(labelText: 'Purchase Date'),
              keyboardType: TextInputType.datetime,
              onTap: () {
                _selectDate(context, _purchaseDateController);
              },
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectCurrency,
              child: Text('Select Currency: $selectedCurrency',style: TextStyle(color: Colors.green)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  _productNameController.text,
                  _expireDateController.text,
                  _purchaseDateController.text,
                  _priceController.text,
                  selectedCurrency,
                );
                Navigator.pop(context);
              },
              child: Text('Save',style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}
