// ignore_for_file: use_build_context_synchronously, unused_field, unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'notification_badge.dart';


// Data model

class OrderInvoice {
  final int orderId;
  final String pickupDate;
  final String clientName;
  final String clientAddress;
  final double clothingKg;
  final int pricePerKg;
  final int suits2Piece;
  final int suits3Piece;
  final int duvets;
  final int curtains;
  final int? finalAmount;

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
    this.finalAmount,
  });

  int get clothingTotal  => (clothingKg * pricePerKg).round();
  int get suits2Total    => suits2Piece * 15000;
  int get suits3Total    => suits3Piece * 20000;
  int get duvetsTotal    => duvets * 22500;
  int get curtainsTotal  => curtains * 10000;

  int get grandTotal =>
      finalAmount ??
      (clothingTotal + suits2Total + suits3Total + duvetsTotal + curtainsTotal);
}

enum PaymentMethod { mtn, airtel, cash }


// Screen

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
  static const Color gold        = Color(0xFFD4AF37);

  PaymentMethod selectedMethod = PaymentMethod.mtn;
  bool _confirmed   = false;
  bool _isLoading   = false;
  bool _isUploading = false;

  Map<String, dynamic>? _orderData;
  PlatformFile? _selectedFile;
  final TextEditingController _transactionIdController = TextEditingController();

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    NotificationBadge.refresh();
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getOrderDetails(widget.invoice.orderId);
      setState(() => _orderData = data);
    } catch (_) {
      // fallback to invoice data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int get _actualAmount {
    if (_orderData != null && _orderData!['final_amount'] != null) {
      return num.tryParse(_orderData!['final_amount'].toString())?.toInt() ?? widget.invoice.grandTotal;
    }
    return widget.invoice.grandTotal;
  }

  double get _actualKg {
    if (_orderData != null && _orderData!['actual_kg'] != null) {
      return num.tryParse(_orderData!['actual_kg'].toString())?.toDouble() ?? widget.invoice.clothingKg;
    }
    return widget.invoice.clothingKg;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _confirmPayment() async {
    if (selectedMethod != PaymentMethod.cash) {
      if (_selectedFile == null) { _showSnack('Please upload your payment screenshot', isError: true); return; }
      if (_transactionIdController.text.trim().isEmpty) { _showSnack('Please enter your transaction ID', isError: true); return; }
    }
    setState(() => _isUploading = true);
    try {
      if (selectedMethod == PaymentMethod.cash) {
        setState(() => _confirmed = true);
        _showSnack('✅ Cash on Delivery confirmed! Your laundry is on its way.');
      } else {
        await _api.uploadPayment(
          orderId: widget.invoice.orderId,
          paymentMethod: selectedMethod == PaymentMethod.mtn ? 'mtn' : 'airtel',
          screenshotBytes: _selectedFile!.bytes!,
          screenshotName: _selectedFile!.name,
          transactionId: _transactionIdController.text.trim(),
        );
        setState(() => _confirmed = true);
        _showSnack('✅ Payment submitted! Our team will verify and confirm.');
      }
    } catch (_) {
      _showSnack('Failed to submit payment. Please try again.', isError: true);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // ── Shimmer ────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        child: Column(children: [
          Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
          const SizedBox(height: 22),
          Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
          const SizedBox(height: 22),
          Container(height: 14, width: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
          const SizedBox(height: 10),
          Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 10),
          Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 24),
          Container(height: 54, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ]),
      ),
    );
  }

  // ── Bottom nav with badge ──────────────────────────────────────
  Widget _buildBottomNav() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationBadge.count,
      builder: (context, unreadCount, _) {
        return BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: purple,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, '/home');
            if (index == 2) Navigator.pushNamed(context, '/schedule');
            if (index == 3) Navigator.pushNamed(context, '/notifications');
            if (index == 4) Navigator.pushNamed(context, '/account');
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
            BottomNavigationBarItem(
              label: 'Notifications',
              icon: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.notifications_rounded),
                if (unreadCount > 0)
                  Positioned(right: -6, top: -4, child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
                    child: Text(unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1A0A2E)),
                        textAlign: TextAlign.center),
                  )),
              ]),
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
          ],
        );
      },
    );
  }

  // ── UI helpers (unchanged) ─────────────────────────────────────
  Widget _statusChip() {
    final status = _orderData?['status'] ?? 'pending';
    final label = {'pending': 'Pending', 'confirmed': 'Confirmed', 'washing': 'Washing', 'delivered': 'Delivered'}[status] ?? status;
    final color = {'pending': const Color(0xFFF59E0B), 'confirmed': const Color(0xFF059669), 'washing': const Color(0xFF3B82F6), 'delivered': const Color(0xFF8B5CF6)}[status] ?? const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
      ]),
    );
  }

  Widget _paymentProofSection() {
    if (selectedMethod == PaymentMethod.cash) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 22),
      _sectionLabel('Payment Proof'),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEDE9F6))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Transaction ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          TextFormField(
            controller: _transactionIdController,
            decoration: InputDecoration(
              hintText: 'e.g. MP2410012345',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true, fillColor: const Color(0xFFF9F8FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDE9F6))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDE9F6))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: purple, width: 2)),
              prefixIcon: const Icon(Icons.tag_rounded, color: purple, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Payment Screenshot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedFile != null ? const Color(0xFFF0FDF4) : const Color(0xFFF9F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedFile != null ? const Color(0xFF6EE7B7) : const Color(0xFFDDD6FE), width: 1.5),
              ),
              child: _selectedFile != null
                  ? Row(children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_selectedFile!.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF059669)), overflow: TextOverflow.ellipsis)),
                      GestureDetector(onTap: () => setState(() => _selectedFile = null), child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 18)),
                    ])
                  : const Column(children: [
                      Icon(Icons.cloud_upload_rounded, color: purple, size: 28),
                      SizedBox(height: 8),
                      Text('Tap to upload screenshot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: purple)),
                      SizedBox(height: 4),
                      Text('JPG, PNG supported', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _paymentCard({required PaymentMethod method, required String title, required String subtitle, required Widget logo, String? merchantNumber, String? altNumber}) {
    final isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? lightPurple : Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? purple : const Color(0xFFE5E7EB), width: isSelected ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            logo, const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? purple : const Color(0xFF1A1A2E))),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ])),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? purple : const Color(0xFFD1D5DB), width: 2), color: isSelected ? purple : Colors.transparent),
              child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
          ]),
          if (isSelected && merchantNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Send payment to:', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF6B21A8)),
                  const SizedBox(width: 6),
                  Flexible(child: Text(merchantNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () { Clipboard.setData(ClipboardData(text: merchantNumber)); _showSnack('Number copied!'); },
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: lightPurple, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Copy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: purple))),
                  ),
                ]),
                if (altNumber != null) ...[
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 6),
                  const Text('Account name:', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  Text(altNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                ],
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFDE68A))),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFFD97706)),
                    SizedBox(width: 6),
                    Expanded(child: Text('Include your Order ID as the reference when sending.', style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w500))),
                  ])),
              ]),
            ),
          ],
          if (isSelected && method == PaymentMethod.cash) ...[
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBBF7D0))),
              child: const Row(children: [
                Icon(Icons.handshake_rounded, size: 13, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Expanded(child: Text('Pay cash directly to our delivery rider when your laundry arrives.', style: TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w500))),
              ])),
          ],
        ]),
      ),
    );
  }

  Widget _mtnLogo()   => Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('MTN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black))));
  Widget _airtelLogo() => Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFE30613), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('AIRTEL', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white))));
  Widget _cashLogo()  => Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF6EE7B7))), child: const Icon(Icons.payments_rounded, size: 18, color: Color(0xFF059669)));

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Order Invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3))),
                  _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                      : _statusChip(),
                ],
              ),
            ),

            // ── BODY ──
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        // Order header card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(children: [
                            Row(children: [
                              Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color.fromRGBO(255,255,255,0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Order #${inv.orderId}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2)),
                                Text(inv.pickupDate, style: const TextStyle(fontSize: 12, color: Color.fromRGBO(255,255,255,0.7))),
                              ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                const Text('Total Due', style: TextStyle(fontSize: 11, color: Color.fromRGBO(255,255,255,0.65))),
                                Text('UGX ${_fmt(_actualAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                              ]),
                            ]),
                            const SizedBox(height: 14),
                            Container(height: 1, color: const Color.fromRGBO(255,255,255,0.15)),
                            const SizedBox(height: 12),
                            Row(children: [
                              const Icon(Icons.person_outline_rounded, size: 13, color: Color.fromRGBO(255,255,255,0.65)),
                              const SizedBox(width: 5),
                              Text(inv.clientName, style: const TextStyle(fontSize: 12, color: Color.fromRGBO(255,255,255,0.8), fontWeight: FontWeight.w500)),
                              const Spacer(),
                              const Icon(Icons.location_on_outlined, size: 13, color: Color.fromRGBO(255,255,255,0.65)),
                              const SizedBox(width: 4),
                              Text(inv.clientAddress, style: const TextStyle(fontSize: 12, color: Color.fromRGBO(255,255,255,0.8), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                            ]),
                          ]),
                        ),

                        const SizedBox(height: 22),

                        // Weight highlight
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: lightPurple, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDDD6FE))),
                          child: Row(children: [
                            Container(width: 44, height: 44, decoration: BoxDecoration(color: purple, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.scale_rounded, color: Colors.white, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Actual weight measured', style: TextStyle(fontSize: 11, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
                              Text('$_actualKg kg of clothing', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              const Text('at UGX 3,000/kg', style: TextStyle(fontSize: 10, color: Color(0xFF7C3AED))),
                              Text('= UGX ${_fmt(_actualAmount)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF6B21A8))),
                            ]),
                          ]),
                        ),

                        const SizedBox(height: 22),

                        // Payment methods
                        _sectionLabel('Choose Payment Method'),
                        _paymentCard(method: PaymentMethod.mtn, title: 'MTN Mobile Money', subtitle: 'Send via MTN MoMo', logo: _mtnLogo(), merchantNumber: '0771 234 567', altNumber: 'Protos Laundries Ltd'),
                        _paymentCard(method: PaymentMethod.airtel, title: 'Airtel Money', subtitle: 'Send via Airtel Money', logo: _airtelLogo(), merchantNumber: '0701 234 567', altNumber: 'Protos Laundries Ltd'),

                        // Payment proof
                        _paymentProofSection(),

                        const SizedBox(height: 24),

                        // Confirm button
                        SizedBox(
                          width: double.infinity, height: 54,
                          child: ElevatedButton(
                            onPressed: (_confirmed || _isUploading) ? null : _confirmPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _confirmed ? const Color(0xFF059669) : gold,
                              foregroundColor: _confirmed ? Colors.white : const Color(0xFF1A0A2E),
                              disabledBackgroundColor: _confirmed ? const Color(0xFF059669) : Colors.grey,
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isUploading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(_confirmed ? Icons.check_circle_rounded : selectedMethod == PaymentMethod.cash ? Icons.handshake_rounded : Icons.send_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _confirmed ? 'Payment Confirmed ✓' : selectedMethod == PaymentMethod.cash ? 'Confirm Cash on Delivery' : 'I Have Sent the Payment',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                  ]),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Center(child: Text(
                          selectedMethod == PaymentMethod.cash ? 'Your laundry will be delivered after cleaning' : 'Our team will verify your payment before delivery',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center,
                        )),
                        const SizedBox(height: 10),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}