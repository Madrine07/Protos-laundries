// import 'package:flutter/material.dart';
// import '../widgets/how_protos_works.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   static const Color purple = Color(0xFF6A1B9A);
//   static const Color lightPurple = Color(0xFFF3E8FF);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: _bottomNav(context),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [

//               // ===================== TOP BAR =====================
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [

//                     Row(
//                       children: [
//                         Image.asset("images/noback.png", height: 26),
//                         const SizedBox(width: 6),
//                         RichText(
//                           text: const TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: "Protos ",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: purple,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: "Laundries",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: purple,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     GestureDetector(
//                       onTap: () => Navigator.pushNamed(context, "/account"),
//                       child: const Row(
//                         children: [
//                           Icon(Icons.person_outline),
//                           SizedBox(width: 6),
//                           Text("My Account")
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ===================== HERO =====================
//               Container(
//                 height: 120,
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: lightPurple,
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: Row(
//                   children: [

//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Text(
//                               "Laundry made easy",
//                               style: TextStyle(
//                                 fontSize: 16.5,
//                                 fontWeight: FontWeight.w700,
//                                 color: purple,
//                                 height: 1.1,
//                               ),
//                             ),
//                             Text(
//                               "in Kampala",
//                               style: TextStyle(height: 1.1),
//                             ),
//                             SizedBox(height: 6),
//                             Text(
//                               "We pick up, clean, and deliver your laundry to your door",
//                               style: TextStyle(fontSize: 12.5, height: 1.2),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // IMAGE fills container properly
//                     ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topRight: Radius.circular(18),
//                         bottomRight: Radius.circular(18),
//                       ),
//                       child: SizedBox(
//                         height: double.infinity,
//                         width: 130,
//                         child: Image.asset(
//                           "images/banner.png",
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 14),

//               // ===================== BUTTONS =====================
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [

//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: purple,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 13),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         onPressed: () => Navigator.pushNamed(context, "/schedule"),
//                         child: const Text("Schedule pickup"),
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: TextButton(
//                           onPressed: () => Navigator.pushNamed(context, "/track"),
//                           child: const Text(
//                             "Track Order",
//                             style: TextStyle(color: purple),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // ===================== QUICK ACTION STRIP =====================
//               _quickActionsRow(context),

//               const SizedBox(height: 18),

//               // ===================== CAROUSEL =====================
//               const HowItWorksCarousel(),

//               const SizedBox(height: 18),

//               // ===================== PRICE CARD =====================
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: RichText(
//                         text: const TextSpan(
//                           style: TextStyle(color: Colors.black),
//                           children: [
//                             TextSpan(text: "Starting from as low as:\n"),
//                             TextSpan(
//                               text: "UGX 3,000 ",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                                 color: purple,
//                               ),
//                             ),
//                             TextSpan(text: "per kg"),
//                           ],
//                         ),
//                       ),
//                     ),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: SizedBox(
//                         height: 70,
//                         width: 80,
//                         child: Image.asset(
//                           "images/folded.png",
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 26),

//               const Text(
//                 "Laundry at your convenience",
//                 style: TextStyle(fontSize: 12),
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ===================== QUICK ACTIONS =====================
//   Widget _quickActionsRow(BuildContext context) {
//     return SizedBox(
//       height: 78,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         children: [
//           _quickItem(Icons.calendar_month, "Schedule Pickup",
//               () => Navigator.pushNamed(context, "/schedule")),
//           _quickItem(Icons.price_check, "View Prices",
//               () => Navigator.pushNamed(context, "/pricing")),
//           _quickItem(Icons.local_shipping, "Track Order",
//               () => Navigator.pushNamed(context, "/track")),
//           _quickItem(Icons.support_agent, "Contact Us",
//               () => Navigator.pushNamed(context, "/support")),
//         ],
//       ),
//     );
//   }

//   Widget _quickItem(IconData icon, String label, VoidCallback tap) {
//     return GestureDetector(
//       onTap: tap,
//       child: Container(
//         width: 110,
//         margin: const EdgeInsets.only(right: 10),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: lightPurple,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: purple, size: 22),
//             const SizedBox(height: 6),
//             Text(label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 11)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== BOTTOM NAV =====================
//   Widget _bottomNav(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: 0,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: purple,
//       onTap: (index) {
//         if (index == 1) Navigator.pushNamed(context, "/orders");
//         if (index == 2) Navigator.pushNamed(context, "/schedule");
//         if (index == 3) Navigator.pushNamed(context, "/pricing");
//       },
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//         BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Orders"),
//         BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Schedule"),
//         BottomNavigationBarItem(icon: Icon(Icons.price_check), label: "Pricing"),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../widgets/how_protos_works.dart';
import '/screens/payment_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color purple = Color(0xFF6A1B9A);
  static const Color purpleDark = Color(0xFF4A148C);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const Color accentGold = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══════════════════════════════════
              //  TOP BAR
              // ══════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("images/noback.png", height: 28),
                        const SizedBox(width: 8),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Protos ",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: purple,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              TextSpan(
                                text: "Laundries",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: purple,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/account"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: lightPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person_rounded, color: purple, size: 16),
                            SizedBox(width: 5),
                            Text(
                              "My Account",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════
              //  HERO BANNER
              // ══════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(106, 27, 154, 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subtle pattern dots
                      Positioned(
                        right: 130,
                        top: -18,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromRGBO(255, 255, 255, 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 110,
                        bottom: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromRGBO(255, 255, 255, 0.05),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          // Text side
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Laundry made easy",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.1,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const Text(
                                    "in Kampala",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "We pick up, clean, and deliver\nyour laundry to your door",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.white60,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Location chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 11,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          "Kulambiro · Mulaago",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Image side
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: SizedBox(
                              height: double.infinity,
                              width: 126,
                              child: Image.asset(
                                "images/banner.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ══════════════════════════════════
              //  CTA BUTTONS
              // ══════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/schedule"),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(106, 27, 154, 0.30),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_laundry_service_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 7),
                              Text(
                                "Schedule Pickup",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/track"),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: lightPurple,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_rounded,
                                color: purple,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Track Order",
                                style: TextStyle(
                                  color: purple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ══════════════════════════════════
              //  QUICK ACTIONS
              // ══════════════════════════════════
              Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 10),
                child: const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              _quickActionsRow(context),

              const SizedBox(height: 22),

              // ══════════════════════════════════
              //  HOW IT WORKS SECTION LABEL
              // ══════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "How Protos Works",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Carousel (unchanged) ──
              const HowItWorksCarousel(),

              const SizedBox(height: 22),

              // ══════════════════════════════════
              //  PRICING CARD
              // ══════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFEDE9F6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: lightPurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Transparent Pricing",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: purple,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Starting from",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "UGX 3,000 ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                      color: purple,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "/ kg",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, "/pricing"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: purple,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "View All Prices →",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 90,
                          width: 90,
                          child: Image.asset(
                            "images/folded.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ══════════════════════════════════
              //  FOOTER TAG
              // ══════════════════════════════════
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_laundry_service_rounded,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Laundry at your convenience",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════
  //  QUICK ACTIONS ROW
  // ══════════════════════════════════
  Widget _quickActionsRow(BuildContext context) {
    final items = [
      _QuickItem(
        Icons.calendar_month_rounded,
        "Schedule\nPickup",
        () => Navigator.pushNamed(context, "/schedule"),
      ),
      _QuickItem(
        Icons.price_check_rounded,
        "View\nPrices",
        () => Navigator.pushNamed(context, "/pricing"),
      ),
      _QuickItem(
        Icons.local_shipping_rounded,
        "Track\nOrder",
        () => Navigator.pushNamed(context, "/track"),
      ),
      _QuickItem(
        Icons.support_agent_rounded,
        "Help &\nContact",
        () => Navigator.pushNamed(context, "/support"),
      ),
      _QuickItem(
        Icons.store_rounded,
        "View\nBranches",
        () => Navigator.pushNamed(context, "/branches"),
      ),
    ];

    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: item.tap,
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE9F6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: purple, size: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════
  //  BOTTOM NAV
  // ══════════════════════════════════
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: purple,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      elevation: 12,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(
            context,
            '/payment',
            arguments: OrderInvoice(
              orderId: "12345",
              pickupDate: "18 Feb 2026",
              clientName: "Madrine",
              clientAddress: "Ntinda",
              clothingKg: 10,
            ),
          );
        }

        if (index == 2) Navigator.pushNamed(context, "/schedule");
        if (index == 3) Navigator.pushNamed(context, "/pricing");
        // if (index == 4) Navigator.pushNamed(context, "/account");
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: "Payment",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: "Schedule",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.price_check_rounded),
          label: "Pricing",
        ),
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.person_rounded), label: "Account"),
      ],
    );
  }
}

// ── Helper model ──────────────────────────────────────
class _QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback tap;
  const _QuickItem(this.icon, this.label, this.tap);
}
