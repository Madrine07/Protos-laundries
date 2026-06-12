// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/how_protos_works.dart';
import 'notification_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Brand colours ──────────────────────────────────────────────
  static const Color purple      = Color(0xFF6A1B9A);
  static const Color purpleLight = Color(0xFF8E24AA);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const Color gold        = Color(0xFFFFB300);
  static const Color goldLight   = Color(0xFFFFF8E1);
  static const Color goldDark    = Color(0xFFF57F17);

  bool _loading = true;

  // ── Dynamic greeting ───────────────────────────────────────────
  static const _morningLines = [
    ("Rise and shine! ☀️", "Your laundry won't wash itself today 😄"),
    ("Good morning! 👋", "Fresh clothes, fresh day — let's go!"),
    ("Morning! 🌤️", "Start the week clean — schedule a pickup"),
    ("Early bird! 🐦", "Beat the rush — book your pickup now"),
  ];
  static const _afternoonLines = [
    ("Good afternoon! 👋", "Midday check-in — any laundry piling up?"),
    ("Hey there! ☀️", "Still time to schedule a pickup today"),
    ("Afternoon! 🌿", "Clothes don't fold themselves, but we wash them!"),
    ("Hello! 👋", "A clean wardrobe is just one tap away"),
  ];
  static const _eveningLines = [
    ("Good evening! 🌙", "End the day fresh — schedule for tomorrow"),
    ("Evening! ✨", "Tomorrow's outfit starts with clean laundry today"),
    ("Winding down? 🌆", "Let us handle laundry while you rest"),
    ("Hey! 🌙", "Drop us your laundry — pick up fresh tomorrow"),
  ];

  (String, String) _getGreeting() {
    final hour = DateTime.now().hour;
    List<(String, String)> pool;
    if (hour < 12) {
      pool = _morningLines;
    } else if (hour < 17) {
      pool = _afternoonLines;
    } else {
      pool = _eveningLines;
    }
    final index = DateTime.now().dayOfYear % pool.length;
    return pool[index];
  }

  @override
  void initState() {
    super.initState();
    NotificationBadge.refresh();
    // Brief shimmer on load
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  // ── Shimmer ────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            // Top bar shimmer
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(width: 140, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              Container(width: 90, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            ]),
            const SizedBox(height: 18),
            // Greeting shimmer
            Container(width: 200, height: 22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 6),
            Container(width: 260, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
            const SizedBox(height: 18),
            // Subscription banner shimmer
            Container(width: double.infinity, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22))),
            const SizedBox(height: 20),
            // Hero banner shimmer
            Container(width: double.infinity, height: 148, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 16),
            // CTA buttons shimmer
            Row(children: [
              Expanded(flex: 3, child: Container(height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: Container(height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
            ]),
            const SizedBox(height: 20),
            // Quick actions shimmer
            Container(width: 110, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
            const SizedBox(height: 10),
            Row(children: List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(width: 80, height: 86, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            ))),
            const SizedBox(height: 22),
            // Services shimmer
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(width: 100, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
              Container(width: 120, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Container(height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)))),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav with badge ──────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationBadge.count,
      builder: (context, unreadCount, _) {
        return BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: purple,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 12,
          onTap: (index) {
            if (index == 1) Navigator.pushNamed(context, '/orders');
            if (index == 2) Navigator.pushNamed(context, '/schedule');
            if (index == 3) Navigator.pushNamed(context, '/notifications');
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
            BottomNavigationBarItem(
              label: 'Notifications',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded),
                  if (unreadCount > 0)
                    Positioned(
                      right: -6, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1A0A2E)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: _loading
            ? _buildShimmer()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP BAR ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('images/noback.png', height: 28),
                              const SizedBox(width: 8),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(text: 'Protos ',
                                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: purple, letterSpacing: -0.3)),
                                    TextSpan(text: 'Laundries',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: purple, letterSpacing: -0.2)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/account'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(color: lightPurple, borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                children: [
                                  Icon(Icons.person_rounded, color: purple, size: 16),
                                  SizedBox(width: 5),
                                  Text('My Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: purple)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── GREETING ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Builder(builder: (context) {
                        final (headline, sub) = _getGreeting();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(headline, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.4)),
                            const SizedBox(height: 2),
                            Text(sub, style: const TextStyle(fontSize: 13.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400)),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 18),

                    // ── SUBSCRIPTION BANNER ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: const Color.fromRGBO(106, 27, 154, 0.30), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Stack(
                          children: [
                            Positioned(right: -20, top: -20,
                                child: Container(width: 100, height: 100,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, 0.06)))),
                            Positioned(right: 40, bottom: -30,
                                child: Container(width: 80, height: 80,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, 0.04)))),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(255, 179, 0, 0.20),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color.fromRGBO(255, 179, 0, 0.40), width: 1),
                                          ),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: const [
                                            Icon(Icons.workspace_premium_rounded, color: gold, size: 11),
                                            SizedBox(width: 4),
                                            Text('PREMIUM MEMBERSHIP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: gold, letterSpacing: 0.8)),
                                          ]),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text('Monthly Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                                        const SizedBox(height: 3),
                                        const Text('Includes 2–4 washes per month', style: TextStyle(fontSize: 12, color: Colors.white60)),
                                        const SizedBox(height: 14),
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, '/subscription'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: gold, borderRadius: BorderRadius.circular(10),
                                              boxShadow: [BoxShadow(color: const Color.fromRGBO(255, 179, 0, 0.45), blurRadius: 10, offset: const Offset(0, 4))],
                                            ),
                                            child: const Text('Subscribe Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: const [
                                      Text('UGX', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500)),
                                      Text('80,000', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: gold, letterSpacing: -1)),
                                      Text('/ month', style: TextStyle(fontSize: 11, color: Colors.white54)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── HERO BANNER ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        height: 148,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: const Color.fromRGBO(106, 27, 154, 0.28), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Stack(
                          children: [
                            Positioned(right: 130, top: -18, child: Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, 0.06)))),
                            Positioned(right: 110, bottom: -20, child: Container(width: 100, height: 100, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(255, 255, 255, 0.05)))),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Laundry made easy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -0.3)),
                                        const Text('in Kampala', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white70, height: 1.2)),
                                        const SizedBox(height: 8),
                                        const Text('We pick up, clean, and deliver\nyour laundry to your door', style: TextStyle(fontSize: 11.5, color: Colors.white60, height: 1.4)),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: const Color.fromRGBO(255, 255, 255, 0.15), borderRadius: BorderRadius.circular(20)),
                                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                            Icon(Icons.location_on_rounded, size: 11, color: Colors.white70),
                                            SizedBox(width: 3),
                                            Text('Kulambiro - Mulago areas', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500)),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                                  child: SizedBox(height: double.infinity, width: 126, child: Image.asset('images/banner.png', fit: BoxFit.cover)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── CTA BUTTONS ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/schedule'),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: const Color.fromRGBO(106, 27, 154, 0.30), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.local_laundry_service_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 7),
                                  Text('Schedule Pickup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                ]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/track'),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: goldLight, borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color.fromRGBO(255, 179, 0, 0.30), width: 1.5),
                                ),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.local_shipping_rounded, color: goldDark, size: 17),
                                  SizedBox(width: 6),
                                  Text('Track Order', style: TextStyle(color: goldDark, fontWeight: FontWeight.w700, fontSize: 13)),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── QUICK ACTIONS ──
                    Padding(padding: const EdgeInsets.only(left: 18, bottom: 10), child: _sectionLabel('Quick Actions')),
                    _quickActionsRow(context),

                    const SizedBox(height: 22),

                    // ── OUR SERVICES ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel('Our Services'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: goldLight, borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color.fromRGBO(255, 179, 0, 0.35), width: 1),
                            ),
                            child: const Text('from UGX 3,000 / kg', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: goldDark)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                              decoration: BoxDecoration(
                                color: goldLight, borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color.fromRGBO(255, 179, 0, 0.40), width: 1.2),
                              ),
                              child: Row(children: const [
                                Icon(Icons.bolt_rounded, color: goldDark, size: 18),
                                SizedBox(width: 7),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Express', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                                  Text('Same-day delivery', style: TextStyle(fontSize: 10.5, color: goldDark, fontWeight: FontWeight.w500)),
                                ])),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                              decoration: BoxDecoration(
                                color: lightPurple, borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color.fromRGBO(106, 27, 154, 0.20), width: 1.2),
                              ),
                              child: Row(children: const [
                                Icon(Icons.schedule_rounded, color: purple, size: 18),
                                SizedBox(width: 7),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Standard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                                  Text('24–48 hrs delivery', style: TextStyle(fontSize: 10.5, color: purple, fontWeight: FontWeight.w500)),
                                ])),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── HOW IT WORKS ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        _sectionLabel('How Protos Works'),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    const HowItWorksCarousel(),

                    const SizedBox(height: 22),

                    // ── PRICING CARD ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEDE9F6), width: 1.5),
                          boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 12, offset: const Offset(0, 3))],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: goldLight, borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color.fromRGBO(255, 179, 0, 0.30), width: 1),
                                    ),
                                    child: const Text('Transparent Pricing', style: TextStyle(fontSize: 10, color: goldDark, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Starting from', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                  RichText(
                                    text: const TextSpan(children: [
                                      TextSpan(text: 'UGX 3,000 ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: purple, letterSpacing: -0.5)),
                                      TextSpan(text: '/ kg', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                                    ]),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/schedule'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [goldDark, gold]),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [BoxShadow(color: const Color.fromRGBO(255, 179, 0, 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                                      ),
                                      child: const Text('Book pickup →', style: TextStyle(fontSize: 11, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(height: 90, width: 90, child: Image.asset('images/folded.png', fit: BoxFit.cover)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── FOOTER ──
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.local_laundry_service_rounded, size: 13, color: Colors.grey.shade400),
                          const SizedBox(width: 5),
                          Text('Laundry at your convenience', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)));
  }

  Widget _quickActionsRow(BuildContext context) {
    final items = [
      _QuickItem(Icons.calendar_month_rounded, 'Schedule\nPickup', () => Navigator.pushNamed(context, '/schedule')),
      _QuickItem(Icons.local_shipping_rounded, 'Track\nOrder', () => Navigator.pushNamed(context, '/track')),
      _QuickItem(Icons.support_agent_rounded, 'Help &\nContact', () => Navigator.pushNamed(context, '/support')),
      _QuickItem(Icons.store_rounded, 'View\nBranches', () => Navigator.pushNamed(context, '/branches')),
    ];

    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item    = items[i];
          final useGold = i % 2 == 0;
          return GestureDetector(
            onTap: item.tap,
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: useGold ? const Color.fromRGBO(255, 179, 0, 0.25) : const Color(0xFFEDE9F6), width: 1.2),
                boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: useGold ? goldLight : lightPurple, borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.icon, color: useGold ? goldDark : purple, size: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(item.label, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151), height: 1.2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback tap;
  const _QuickItem(this.icon, this.label, this.tap);
}

extension DateTimeExtension on DateTime {
  int get dayOfYear => difference(DateTime(year, 1, 1)).inDays;
}