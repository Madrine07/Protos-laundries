// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// Data model passed into this screen
// ─────────────────────────────────────────────
class OrderInvoice {
  final String orderId;
  final String pickupDate;
  final String clientName;
  final String clientAddress;

  // Weighed clothing (set by staff after pickup)
  final double clothingKg;
  final int pricePerKg; // UGX 3,000

  // Special items
  final int suits2Piece;
  final int suits3Piece;
  final int duvets;
  final int curtains;

  const OrderInvoice({
    required this.orderId,
    required this.pickupDate,
    required this.clientName,
    required this.clientAddress,
    required this.clothingKg,
    this.pricePerKg = 3000,
    this.suits2Piece = 0,
    this.suits3Piece = 0,
    this.duvets = 0,
    this.curtains = 0,
  });

  int get clothingTotal => (clothingKg * pricePerKg).round();
  int get suits2Total   => suits2Piece * 15000;
  int get suits3Total   => suits3Piece * 20000;
  int get duvetsTotal   => duvets * 22500;
  int get curtainsTotal => curtains * 10000;

  int get grandTotal =>
      clothingTotal + suits2Total + suits3Total + duvetsTotal + curtainsTotal;
}

// ─────────────────────────────────────────────
// Payment method enum
// ─────────────────────────────────────────────
enum PaymentMethod { mtn, airtel, cash }

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class OrderInvoiceScreen extends StatefulWidget {
  final OrderInvoice invoice;

  const OrderInvoiceScreen({super.key, required this.invoice});

  @override
  State<OrderInvoiceScreen> createState() => _OrderInvoiceScreenState();
}

class _OrderInvoiceScreenState extends State<OrderInvoiceScreen> {
  static const Color purple      = Color(0xFF6B21A8);
  static const Color purpleDark  = Color(0xFF4A148C);
  static const Color lightPurple = Color(0xFFF3E8FF);

  PaymentMethod selectedMethod = PaymentMethod.mtn;
  bool _confirmed = false;

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  void _confirmPayment() {
    setState(() => _confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        selectedMethod == PaymentMethod.cash
            ? "✅ Cash on Delivery confirmed! Your laundry is on its way."
            : "✅ Payment noted! Please send UGX ${_fmt(widget.invoice.grandTotal)} to the number above.",
      ),
      backgroundColor: purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6EE7B7), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
          SizedBox(width: 5),
          Text(
            "Weighed & Ready",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3, height: 16,
            decoration: BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineItem(String label, String qty, int amount, {bool isHighlighted = false}) {
    if (amount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: isHighlighted ? purple : const Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isHighlighted
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF4B5563),
                fontWeight: isHighlighted
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
          Text(
            qty,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "UGX ${_fmt(amount)}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? purple : const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        color: const Color(0xFFF3F4F6),
        margin: const EdgeInsets.symmetric(vertical: 4),
      );

  // ── Payment option card ──
  Widget _paymentCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required Widget logo,
    String? merchantNumber,
    String? altNumber,
  }) {
    final isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? purple : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                logo,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isSelected
                                ? purple
                                : const Color(0xFF1A1A2E),
                          )),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? purple : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    color: isSelected ? purple : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
            // Merchant number shown when selected
            if (isSelected && merchantNumber != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Send payment to:",
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 14, color: Color(0xFF6B21A8)),
                        const SizedBox(width: 6),
                        Text(
                          merchantNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: merchantNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Number copied!"),
                                backgroundColor: purple,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: lightPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Copy",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: purple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (altNumber != null) ...[
                      const SizedBox(height: 6),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 6),
                      const Text(
                        "Account name:",
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                      Text(
                        altNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFDE68A), width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 13, color: Color(0xFFD97706)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Include your Order ID as the reference when sending.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Cash note
            if (isSelected && method == PaymentMethod.cash) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.handshake_rounded,
                        size: 13, color: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Pay cash directly to our delivery rider when your laundry arrives.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Logo widgets ──
  Widget _mtnLogo() => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text("MTN",
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.black)),
        ),
      );

  Widget _airtelLogo() => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE30613),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text("AIRTEL",
              style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
      );

  Widget _cashLogo() => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF6EE7B7), width: 1),
        ),
        child: const Icon(Icons.payments_rounded,
            size: 18, color: Color(0xFF059669)),
      );

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, "/home");
          if (index == 1) Navigator.pushNamed(context, "/payment");
          if (index == 2) Navigator.pushNamed(context, "/schedule");
          if (index == 3) Navigator.pushNamed(context, "/pricing");
          if (index == 4) Navigator.pushNamed(context, "/account");
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: "Payment"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: "Schedule"),
          BottomNavigationBarItem(
              icon: Icon(Icons.price_check_rounded), label: "Pricing"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Account"),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [

            // ── APP BAR ────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Order Invoice",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _statusChip(),
                ],
              ),
            ),

            // ── SCROLLABLE BODY ────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── ORDER HEADER CARD ──────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                      255, 255, 255, 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order #${inv.orderId}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Text(
                                      inv.pickupDate,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(
                                            255, 255, 255, 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Total Due",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color.fromRGBO(
                                          255, 255, 255, 0.65),
                                    ),
                                  ),
                                  Text(
                                    "UGX ${_fmt(inv.grandTotal)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 1,
                            color: const Color.fromRGBO(255, 255, 255, 0.15),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  size: 13,
                                  color: Color.fromRGBO(255, 255, 255, 0.65)),
                              const SizedBox(width: 5),
                              Text(
                                inv.clientName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        Color.fromRGBO(255, 255, 255, 0.8),
                                    fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              const Icon(Icons.location_on_outlined,
                                  size: 13,
                                  color: Color.fromRGBO(255, 255, 255, 0.65)),
                              const SizedBox(width: 4),
                              Text(
                                inv.clientAddress,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        Color.fromRGBO(255, 255, 255, 0.8),
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── WEIGHT HIGHLIGHT ───────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: const Color(0xFFDDD6FE)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.scale_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Actual weight measured",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF7C3AED),
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "${inv.clothingKg} kg of clothing",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("at UGX 3,000/kg",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF7C3AED))),
                              Text(
                                "= UGX ${_fmt(inv.clothingTotal)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── INVOICE BREAKDOWN ──────
                    _sectionLabel("Invoice Breakdown"),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFEDE9F6), width: 1),
                      ),
                      child: Column(
                        children: [
                          // Clothing line
                          if (inv.clothingTotal > 0)
                            _lineItem(
                              "Clothing (${inv.clothingKg} kg × UGX 3,000)",
                              "${inv.clothingKg} kg",
                              inv.clothingTotal,
                              isHighlighted: true,
                            ),

                          if (inv.clothingTotal > 0 &&
                              (inv.suits2Total > 0 ||
                                  inv.suits3Total > 0 ||
                                  inv.duvetsTotal > 0 ||
                                  inv.curtainsTotal > 0))
                            _divider(),

                          _lineItem(
                            "Suit (2-Piece) × ${inv.suits2Piece}",
                            "${inv.suits2Piece} pcs",
                            inv.suits2Total,
                          ),
                          _lineItem(
                            "Suit (3-Piece) × ${inv.suits3Piece}",
                            "${inv.suits3Piece} pcs",
                            inv.suits3Total,
                          ),
                          _lineItem(
                            "Duvet × ${inv.duvets}",
                            "${inv.duvets} pcs",
                            inv.duvetsTotal,
                          ),
                          _lineItem(
                            "Curtains × ${inv.curtains}",
                            "${inv.curtains} pcs",
                            inv.curtainsTotal,
                          ),

                          const SizedBox(height: 6),

                          // Grand total row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F7FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "TOTAL DUE",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "UGX ${_fmt(inv.grandTotal)}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF6B21A8),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── PAYMENT METHOD ─────────
                    _sectionLabel("Choose Payment Method"),

                    _paymentCard(
                      method: PaymentMethod.mtn,
                      title: "MTN Mobile Money",
                      subtitle: "Send via MTN MoMo",
                      logo: _mtnLogo(),
                      merchantNumber: "0771 234 567",
                      altNumber: "Protos Laundries Ltd",
                    ),

                    _paymentCard(
                      method: PaymentMethod.airtel,
                      title: "Airtel Money",
                      subtitle: "Send via Airtel Money",
                      logo: _airtelLogo(),
                      merchantNumber: "0701 234 567",
                      altNumber: "Protos Laundries Ltd",
                    ),

                    _paymentCard(
                      method: PaymentMethod.cash,
                      title: "Cash on Delivery",
                      subtitle: "Pay when your laundry arrives",
                      logo: _cashLogo(),
                    ),

                    const SizedBox(height: 24),

                    // ── CONFIRM BUTTON ─────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _confirmed ? null : _confirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _confirmed ? const Color(0xFF059669) : purple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF059669),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _confirmed
                                  ? Icons.check_circle_rounded
                                  : selectedMethod == PaymentMethod.cash
                                      ? Icons.handshake_rounded
                                      : Icons.send_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _confirmed
                                  ? "Payment Confirmed ✓"
                                  : selectedMethod == PaymentMethod.cash
                                      ? "Confirm Cash on Delivery"
                                      : "I Have Sent the Payment",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Small note
                    Center(
                      child: Text(
                        selectedMethod == PaymentMethod.cash
                            ? "Your laundry will be delivered after cleaning"
                            : "Our team will verify your payment before delivery",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}