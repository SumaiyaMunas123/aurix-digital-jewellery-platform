import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quotation Details',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: QuotationPage(),
    );
  }
}

class QuotationPage extends StatefulWidget {
  @override
  _QuotationPageState createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("AI Design Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("Price Check Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("My Contact Page", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Quotation data
    final String shopName = "Veni Jewellers";
    final String productName = "Elegant Gold Bangle";
    final String sku = "VJ-BG-D123";
    final double goldRate = 5500; // per gram
    final double weight = 10.2;
    final double makingCharge = 8160;
    final double wastage = 2750;
    final double stoneCost = 0;
    final double gst = 487;
    final double totalPrice = 71885;
    final String validUntil = "28 Jul 2024, 11:59 PM";

    return Scaffold(
      appBar: AppBar(
        title: Text("Quotation Details"),
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quotation from $shopName",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          productName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text("SKU: $sku",
                            style: TextStyle(color: Colors.grey[700])),
                        Divider(height: 30, thickness: 1),
                        _buildRow("Gold Rate (per gram)",
                            "Rs ${goldRate.toStringAsFixed(2)}"),
                        _buildRow("Weight", "${weight.toStringAsFixed(2)} gm"),
                        _buildRow("Making Charge",
                            "Rs ${makingCharge.toStringAsFixed(2)}"),
                        _buildRow(
                            "Wastage", "Rs ${wastage.toStringAsFixed(2)}"),
                        _buildRow(
                            "Stone Cost", "Rs ${stoneCost.toStringAsFixed(2)}"),
                        _buildRow("Tax (GST)", "Rs ${gst.toStringAsFixed(2)}"),
                        Divider(height: 30, thickness: 1),
                        _buildRow(
                          "Total Price",
                          "Rs ${totalPrice.toStringAsFixed(2)}",
                          isBold: true,
                          color: Colors.green[800],
                        ),
                        SizedBox(height: 10),
                        Text("Valid Until $validUntil",
                            style: TextStyle(color: Colors.red[700])),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Proceed to Payment")),
                                );
                              },
                              child: Text("Accept Quote & Proceed"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700]),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Request Revision")),
                                );
                              },
                              child: Text("Ask for Revision"),
                            ),
                          ],
                        ),
                      ]),
                ),
              ),
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.design_services), label: 'AI Design'),
          BottomNavigationBarItem(
              icon: Icon(Icons.price_change), label: 'Price Check'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_page), label: 'My Contact'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildRow(String title, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black)),
        ],
      ),
    );
  }
}