import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'inventory_screen.dart'; // Import InventoryScreen
import 'list_screen.dart'; // Import ListScreen
import 'user_screen.dart'; // Import UserScreen
import 'scanner_screen.dart'; // Import ScannerScreen
import 'budget_screen.dart'; // Import BudgetScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double remainingBudget = 1000000.00;  // Initial remaining budget (set a non-zero value)
  double usedBudget = 200000.00;      // Initial used budget (set a non-zero value)
  int _currentIndex = 0;         // To keep track of the current tab index

  // Function to update the remaining budget and used budget
  void updateBudget(double newRemainingBudget, double newUsedBudget) {
    setState(() {
      remainingBudget = newRemainingBudget;
      usedBudget = newUsedBudget;
    });
  }

  // Format numbers as Rp 3.000
  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");  // Remove the decimal part
  }

  List<Product> _productList = [];  // This list will store the products

  // Function to add a new product
  void addProduct(String name, String expirationDate, String price, File? image, String currency, String addedOn) {
    setState(() {
      _productList.add(Product(
        name: name,
        expirationDate: expirationDate,
        price: price,
        image: image,
        currency: currency,
        checked: false,
        addedOn: addedOn,
      ));
    });
  }

  // Pages for bottom navigation
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Initialize pages after state is created
    _pages.addAll([
      HomePage(remainingBudget: remainingBudget, usedBudget: usedBudget, updateBudget: updateBudget),
      InventoryScreen(),    // Inventory screen
      ScannerScreen(onProductAdded: addProduct), // Pass the addProduct callback
      ListScreen(productList: _productList),    // Pass the productList to ListScreen
      UserScreen(),         // User profile screen
    ]);
  }

  

  // Function to handle bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;  // Update the current index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, Olivia'),
      ),
      body: _pages[_currentIndex], // Dynamically show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 40, color: Colors.green), // Scanner icon
            label: '',
            backgroundColor: Colors.green, // Green background for scanner button
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'User',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex, // Set to the active tab
        backgroundColor: Colors.white, // Footer background color
        selectedItemColor: Colors.green, // Set icon color for selected item
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,  // Call the function when an item is tapped
      ),
    );
  }
}

// HomePage for displaying budget info
class HomePage extends StatelessWidget {
  final double remainingBudget;
  final double usedBudget;
  final Function(double, double) updateBudget;

  HomePage({
    required this.remainingBudget,
    required this.usedBudget,
    required this.updateBudget,
  });

  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");  // Remove the decimal part
  }

@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining Budget',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetScreen(
                    remainingBudget: remainingBudget,
                    usedBudget: usedBudget,
                    onBudgetChanged: updateBudget, // Pass callback to update budgets
                  ),
                )
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatCurrency(remainingBudget), // Format remaining budget as currency
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}