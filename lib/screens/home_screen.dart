import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inventory_screen.dart';
import 'list_screen.dart';
import 'user_screen.dart';
import 'scanner_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double remainingBudget = 1000000.00;
  double usedBudget = 200000.00;
  int _currentIndex = 0;

  void updateBudget(double newRemainingBudget, double newUsedBudget) {
    setState(() {
      remainingBudget = newRemainingBudget;
      usedBudget = newUsedBudget;
    });
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");
  }

  final List<Product> _productList = [];

  void addProduct(
    String name,
    String expirationDate,
    String price,
    File? image,
    String currency,
    String addedOn,
  ) {
    setState(() {
      _productList.add(
        Product(
          name: name,
          expirationDate: expirationDate,
          price: price,
          image: image,
          currency: currency,
          checked: false,
          addedOn: addedOn,
        ),
      );
    });
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePage(
        remainingBudget: remainingBudget,
        usedBudget: usedBudget,
        updateBudget: updateBudget,
      ),
      InventoryScreen(),
      ScannerScreen(onProductAdded: addProduct),
      ListScreen(productList: _productList),
      UserScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Dashboard')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 40, color: Colors.green),
            label: '',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'User',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final double remainingBudget;
  final double usedBudget;
  final Function(double, double) updateBudget;

  const HomePage({
    super.key,
    required this.remainingBudget,
    required this.usedBudget,
    required this.updateBudget,
  });

  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Olivia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
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
                  builder:
                      (context) => BudgetScreen(
                        remainingBudget: remainingBudget,
                        usedBudget: usedBudget,
                        onBudgetChanged: updateBudget,
                      ),
                ),
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
                formatCurrency(remainingBudget),
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.green),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.green),
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
