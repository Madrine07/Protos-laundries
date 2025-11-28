import 'package:flutter/material.dart';

/// Home SHomeScreen (Stateless) for the laundry app.
/// Uses ARGB hex colors instead of `withOpacity()` to satisfy the analyzer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Primary purple (opaque)
    const Color purple = Color(0xFF673AB7); // FF = 100% opacity

    // Lighter purple backgrounds using ARGB hex:
    // 0x1A = 10% alpha, 0x0D = ~5% alpha
    const Color purple10 = Color(0x1A673AB7); // ~10% opacity
    const Color purple05 = Color(0x0D673AB7); // ~5% opacity

    return Scaffold(
      backgroundColor: Colors.white,

      // Bottom navigation bar with quick links
      bottomNavigationBar: BottomNavigationBar(
        // Selected item color uses primary purple
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),

      // Main body
      body: SafeArea(
        // Allow content to scroll if screen is small
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- APP TITLE ---
              // Simple app title text
              const Text(
                "QuickWash",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // --- PROMO / HEADER CARD ---
              // A rounded card showing a promotion and an image
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: purple10, // light purple background using ARGB hex
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Promo text column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Flat 50% off on First Order", // main promo text
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          // "View all offers" link-like text
                          TextButton(
                            onPressed: () {
                             
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text(
                              "View all offers ➜",
                              style: TextStyle(fontSize: 14, color: Color(0xFF1976D2)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Promo image (replace with your asset)
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset(
                        "images/final-no-background.png", 
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- SERVICES SECTION TITLE ---
              const Text(
                "Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // --- SERVICES CARDS (row of 3) ---
              // Each card is an Expanded so they share available horizontal space
              Row(
                children: [
                  _serviceCard(
                    icon: Icons.local_laundry_service,
                    title: "Wash & Fold",
                    subtitle: "Min 12 Hours",
                    color: purple,
                    bgColor: purple10, // light purple background (hex ARGB)
                  ),
                  const SizedBox(width: 8),
                  _serviceCard(
                    icon: Icons.iron,
                    title: "Wash & Iron",
                    subtitle: "Min 6 Hours",
                    color: purple,
                    bgColor: purple10,
                  ),
                  const SizedBox(width: 8),
                  _serviceCard(
                    icon: Icons.dry_cleaning,
                    title: "Dry Clean",
                    subtitle: "Min 24 Hours",
                    color: purple,
                    bgColor: purple10,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- ACTIVE ORDERS TITLE ---
              const Text(
                "Your Active Orders (2)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // --- ORDER CARD ---
              // Shows order number, status, price and date
              _orderCard(
                orderNo: "22145052",
                status: "Order Confirmed",
                price: "\$256",
                date: "25 June, 2018",
                color: purple,
                bgColor: purple05, // very light purple background
              ),

              // You can add more order cards here...
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------
  // Reusable service card
  // -----------------------
  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor, // light background using ARGB hex
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Service icon
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            // Title text
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            // Subtitle / ETA
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // -----------------------
  // Reusable order card
  // -----------------------
  Widget _orderCard({
    required String orderNo,
    required String status,
    required String price,
    required String date,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor, // subtle background for the order card
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        // Main row: left = order details, right = price & date
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left column with order number and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order No: $orderNo", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              // Status - green to indicate confirmed
              Text(status, style: TextStyle(color: Colors.green[700])),
            ],
          ),

          // Right column with price and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }
}
