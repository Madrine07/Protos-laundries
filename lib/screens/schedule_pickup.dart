// ignore_for_file: use_build_context_synchronously, unused_field, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'notification_badge.dart';

enum BasketSize { none, half, full, two }

extension BasketSizeInfo on BasketSize {
  String get label {
    switch (this) {
      case BasketSize.none: return 'Select size';
      case BasketSize.half: return 'Half Basket';
      case BasketSize.full: return 'Full Basket';
      case BasketSize.two:  return 'Two Baskets';
    }
  }
  String get weightRange {
    switch (this) {
      case BasketSize.none: return '';
      case BasketSize.half: return '~3–4 kg';
      case BasketSize.full: return '~6–8 kg';
      case BasketSize.two:  return '~10–12 kg';
    }
  }
  double get minKg { switch (this) { case BasketSize.none: return 0; case BasketSize.half: return 3; case BasketSize.full: return 6; case BasketSize.two: return 10; } }
  double get maxKg { switch (this) { case BasketSize.none: return 0; case BasketSize.half: return 4; case BasketSize.full: return 8; case BasketSize.two: return 12; } }
  int minPrice(int pricePerKg) => (minKg * pricePerKg).round();
  int maxPrice(int pricePerKg) => (maxKg * pricePerKg).round();
  String? get apiValue { switch (this) { case BasketSize.none: return null; case BasketSize.half: return 'half'; case BasketSize.full: return 'full'; case BasketSize.two: return 'two'; } }
}

enum TurnaroundTime { express, standard }

class SchedulePickupScreen extends StatefulWidget {
  const SchedulePickupScreen({super.key});
  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  static const Color purple     = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const Color gold       = Color(0xFFD4AF37);
  static const Color bgColor    = Color(0xFFFEF7FF);
  static const Color outline    = Color(0xFFCCC3D2);
  static const Color surfaceLow = Color(0xFFF8F1FA);
  static const Color onSurface  = Color(0xFF1D1A20);
  static const Color textGrey   = Color(0xFF7B7482);

  final ApiService _apiService = ApiService();

  bool _isSubmitting    = false;
  bool _loadingAddress  = true;
  bool _loadingBranches = true;
  bool _loadingPrices   = true;

  Map<String, int> _prices = {
    'price_per_kg': 3000, 'suit_2_piece': 15000,
    'suit_3_piece': 20000, 'duvet': 22500, 'curtain': 10000,
  };

  List<Map<String, dynamic>> _branches = [];
  Map<String, dynamic>? _selectedBranch;

  DateTime?  selectedDate;
  TimeOfDay? selectedTime;
  BasketSize selectedBasket = BasketSize.none;
  TurnaroundTime _turnaround = TurnaroundTime.standard;

  String pickupAddress = '';
  int shirts = 0, trousers = 0, dresses = 0, skirts = 0;
  int suits2Piece = 0, suits3Piece = 0, duvets = 0, curtains = 0;

  final TextEditingController _instructionsCtrl = TextEditingController();

  int get _pricePerKg   => _prices['price_per_kg'] ?? 3000;
  int get _suit2Price   => _prices['suit_2_piece']  ?? 15000;
  int get _suit3Price   => _prices['suit_3_piece']  ?? 20000;
  int get _duvetPrice   => _prices['duvet']         ?? 22500;
  int get _curtainPrice => _prices['curtain']       ?? 10000;

  int get clothingCount     => shirts + trousers + dresses + skirts;
  int get specialCount      => suits2Piece + suits3Piece + duvets + curtains;
  int get totalItems        => clothingCount + specialCount;
  bool get hasClothingItems => clothingCount > 0;

  int get specialFixedTotal =>
      (suits2Piece * _suit2Price) + (suits3Piece * _suit3Price) +
      (duvets * _duvetPrice) + (curtains * _curtainPrice);

  int get estimatedMin => selectedBasket.minPrice(_pricePerKg) + specialFixedTotal;
  int get estimatedMax => selectedBasket.maxPrice(_pricePerKg) + specialFixedTotal;

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _loadBranches();
    _loadPrices();
    NotificationBadge.refresh();
  }

  @override
  void dispose() { _instructionsCtrl.dispose(); super.dispose(); }

  Future<void> _loadPrices() async {
    try { final p = await _apiService.fetchPrices(); if (!mounted) return; setState(() => _prices = p); }
    catch (_) {} finally { if (mounted) setState(() => _loadingPrices = false); }
  }

  Future<void> _loadBranches() async {
    try { final b = await _apiService.getBranches(); if (!mounted) return; setState(() { _branches = b; _loadingBranches = false; }); }
    catch (_) { if (!mounted) return; setState(() => _loadingBranches = false); }
  }

  Future<void> _loadAddress() async {
    if (!mounted) return;
    setState(() => _loadingAddress = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;
      final response = await http.get(Uri.parse('https://protos.dina-apartments.com/api/profile'),
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() => pickupAddress = data['address'] ?? '');
      }
    } catch (_) {} finally { if (mounted) setState(() => _loadingAddress = false); }
  }

  void _schedulePickup() async {
    if (_isSubmitting) return;
    if (_selectedBranch == null) { _snack('Please select a branch', isError: true); return; }
    if (selectedDate == null || selectedTime == null) { _snack('Please select a pickup date and time', isError: true); return; }
    if (pickupAddress.trim().isEmpty) { _snack('Please enter a pickup address', isError: true); return; }
    if (totalItems == 0 && selectedBasket == BasketSize.none) { _snack('Please add items or select a basket size', isError: true); return; }
    if (hasClothingItems && selectedBasket == BasketSize.none) { _snack('Please select a basket size for your clothing items', isError: true); return; }

    setState(() => _isSubmitting = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final formattedTime = '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00';
      final Map<String, int> items = {};
      if (shirts > 0)      items['shirts']   = shirts;
      if (trousers > 0)    items['trousers'] = trousers;
      if (dresses > 0)     items['dresses']  = dresses;
      if (skirts > 0)      items['skirts']   = skirts;
      if (suits2Piece > 0) items['suits_2']  = suits2Piece;
      if (suits3Piece > 0) items['suits_3']  = suits3Piece;
      if (duvets > 0)      items['duvets']   = duvets;
      if (curtains > 0)    items['curtains'] = curtains;

      final response = await _apiService.createOrder(
        branchId: _selectedBranch!['id'] as int, pickupAddress: pickupAddress,
        pickupDate: formattedDate, pickupTime: formattedTime,
        instructions: _instructionsCtrl.text.trim().isEmpty ? null : _instructionsCtrl.text.trim(),
        basketSize: selectedBasket.apiValue, estimatedMin: estimatedMin, estimatedMax: estimatedMax, items: items,
      );
      if (!mounted) return;
      _snack('Pickup Scheduled! Order #${response['order']['id']}');
      _resetForm();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/orders');
    } catch (e) {
      if (!mounted) return;
      _snack('Something went wrong. Please try again.', isError: true);
      debugPrint('ORDER ERROR: $e');
    } finally { if (mounted) setState(() => _isSubmitting = false); }
  }

  void _resetForm() {
    setState(() {
      _selectedBranch = null; selectedDate = null; selectedTime = null;
      _instructionsCtrl.clear();
      shirts = 0; trousers = 0; dresses = 0; skirts = 0;
      suits2Piece = 0; suits3Piece = 0; duvets = 0; curtains = 0;
      selectedBasket = BasketSize.none; _turnaround = TurnaroundTime.standard;
    });
    _loadAddress(); _loadBranches(); _loadPrices();
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: purple, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87)), child: child!),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: purple, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87)), child: child!),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> _editAddress() async {
    final ctrl = TextEditingController(text: pickupAddress);
    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: outline, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Change Pickup Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
            const SizedBox(height: 4),
            const Text('Overrides your profile address for this pickup only', style: TextStyle(fontSize: 12, color: textGrey)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl, autofocus: true, maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter pickup address', filled: true, fillColor: surfaceLow,
                prefixIcon: const Icon(Icons.location_on_rounded, color: purple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: outline)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: purple, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () { final val = ctrl.text.trim(); if (val.isNotEmpty) { setState(() => pickupAddress = val); Navigator.pop(ctx); } },
                style: ElevatedButton.styleFrom(backgroundColor: purple, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
    ctrl.dispose();
  }

  void _showBasketPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Estimate Laundry Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
          const SizedBox(height: 4),
          Text('For clothing items only  ·  UGX ${_fmt(_pricePerKg)}/kg', style: const TextStyle(fontSize: 13, color: textGrey)),
          const SizedBox(height: 20),
          ...[BasketSize.half, BasketSize.full, BasketSize.two].map((b) => _basketOption(b, ctx)),
        ]),
      ),
    );
  }

  Widget _basketOption(BasketSize b, BuildContext sheetCtx) {
    final isSelected = selectedBasket == b;
    return GestureDetector(
      onTap: () { setState(() => selectedBasket = b); Navigator.pop(sheetCtx); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? lightPurple : surfaceLow, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? purple : Colors.transparent, width: 1.5),
        ),
        child: Row(children: [
          const Text('🧺', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isSelected ? purple : onSurface)),
            Text('${b.weightRange}  ·  Est. UGX ${_fmt(b.minPrice(_pricePerKg))} – ${_fmt(b.maxPrice(_pricePerKg))}', style: const TextStyle(fontSize: 12, color: textGrey)),
          ])),
          if (isSelected) const Icon(Icons.check_circle_rounded, color: purple, size: 20),
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
          currentIndex: 2,
          selectedItemColor: purple,
          unselectedItemColor: textGrey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, '/home');
            if (index == 1) Navigator.pushNamed(context, '/orders');
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
                  Positioned(
                    right: -6, top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
                      child: Text(unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1A0A2E)),
                          textAlign: TextAlign.center),
                    ),
                  ),
              ]),
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
          ],
        );
      },
    );
  }

  // ── UI builders (unchanged from original, just kept together) ──
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(24), border: Border.all(color: outline.withOpacity(0.35))),
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        Positioned(right: -6, top: 0, bottom: 0,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _headerBar(height: 44, color: purple.withOpacity(0.18)),
            const SizedBox(width: 5),
            _headerBar(height: 28, color: gold.withOpacity(0.35), marginTop: 10),
            const SizedBox(width: 5),
            _headerBar(height: 56, color: purple.withOpacity(0.12)),
            const SizedBox(width: 5),
            _headerBar(height: 20, color: gold.withOpacity(0.25), marginTop: 18),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('SCHEDULE PICKUP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textGrey)),
          ]),
          const SizedBox(height: 10),
          const Text('What are we\ncleaning today?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: onSurface, height: 1.15)),
          const SizedBox(height: 10),
          Row(children: [
            Container(width: 3, height: 14, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('Pick items, choose a time, done.', style: TextStyle(fontSize: 13, color: textGrey)),
          ]),
        ]),
      ]),
    );
  }

  Widget _headerBar({required double height, required Color color, double marginTop = 0}) {
    return Container(width: 8, height: height, margin: EdgeInsets.only(top: marginTop),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));
  }

  Widget _capsLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 3, height: 12, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
      Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: textGrey)),
    ]),
  );

  Widget _sectionTitle(String title, {String? badge, Color? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: (badgeColor ?? purple).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor ?? purple, letterSpacing: 0.5)),
          ),
        ],
      ]),
    );
  }

  Widget _buildBranchSelector() {
    if (_loadingBranches) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: purple)));
    if (_branches.isEmpty) return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))), child: const Text('No branches available.', style: TextStyle(color: Color(0xFF92400E), fontSize: 13)));
    if (_branches.length <= 4) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(16)),
        child: Row(children: _branches.map((branch) {
          final isSelected = _selectedBranch?['id'] == branch['id'];
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedBranch = branch),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))] : null,
                border: isSelected ? Border.all(color: outline.withOpacity(0.5)) : null,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.store_mall_directory_rounded, size: 18, color: isSelected ? purple : textGrey),
                const SizedBox(height: 4),
                Text(branch['name'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? purple : textGrey)),
                if ((branch['location'] ?? '').isNotEmpty)
                  Text(branch['location'], style: const TextStyle(fontSize: 10, color: textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ));
        }).toList()),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _selectedBranch != null ? purple : outline, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: DropdownButtonHideUnderline(child: DropdownButton<Map<String, dynamic>>(
        value: _selectedBranch,
        hint: const Text('Select Branch', style: TextStyle(color: textGrey, fontSize: 14)),
        isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down_rounded, color: purple),
        items: _branches.map((branch) => DropdownMenuItem<Map<String, dynamic>>(value: branch, child: Row(children: [
          const Icon(Icons.store_mall_directory_rounded, color: purple, size: 18), const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(branch['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: onSurface)),
            if ((branch['location'] ?? '').isNotEmpty) Text(branch['location'], style: const TextStyle(fontSize: 11, color: textGrey)),
          ]),
        ]))).toList(),
        onChanged: (value) => setState(() => _selectedBranch = value),
      )),
    );
  }

  Widget _buildAddressCard() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: _editAddress,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pickupAddress.isEmpty ? const Color(0xFFFFFBEB) : Colors.white, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pickupAddress.isEmpty ? const Color(0xFFFDE68A) : outline, width: pickupAddress.isEmpty ? 1.5 : 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(width: 42, height: 42,
              decoration: BoxDecoration(color: pickupAddress.isEmpty ? const Color(0xFFFEF3C7) : lightPurple, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.location_on_rounded, color: pickupAddress.isEmpty ? const Color(0xFFD97706) : purple, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: _loadingAddress
              ? const Text('Loading address...', style: TextStyle(fontSize: 13, color: textGrey))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pickupAddress.isEmpty ? 'No address set' : pickupAddress,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: pickupAddress.isEmpty ? textGrey : onSurface)),
                  const SizedBox(height: 2),
                  Text(pickupAddress.isEmpty ? 'Tap to enter pickup address' : 'Tap to change for this pickup',
                      style: const TextStyle(fontSize: 11, color: textGrey)),
                ])),
            Icon(Icons.edit_rounded, size: 16, color: pickupAddress.isEmpty ? const Color(0xFFD97706) : purple),
          ]),
        ),
      ),
      if (!_loadingAddress && pickupAddress.isEmpty) ...[
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/account'),
          child: Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFD97706)), SizedBox(width: 8),
              Expanded(child: Text('Add your address in Account settings to pre-fill it here →', style: TextStyle(fontSize: 11, color: Color(0xFF92400E)))),
            ]),
          ),
        ),
      ],
    ]);
  }

  Widget _buildItemRow({required IconData icon, required String label, String? subtitle, required int value, required ValueChanged<int> onChanged, bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: outline.withOpacity(0.6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: isSpecial ? lightPurple.withOpacity(0.6) : surfaceLow, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: purple, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: onSurface)),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 12, color: purple, fontWeight: FontWeight.w500))],
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(50)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _pillBtn(Icons.remove, value > 0 ? () => onChanged(value - 1) : null, value > 0),
            SizedBox(width: 32, child: Text(value.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: onSurface))),
            _pillBtn(Icons.add, () => onChanged(value + 1), true),
          ]),
        ),
      ]),
    );
  }

  Widget _pillBtn(IconData icon, VoidCallback? onTap, bool active) {
    return GestureDetector(onTap: onTap, child: Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: active ? purple : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, size: 15, color: active ? Colors.white : Colors.grey[400])));
  }

  Widget _basketSelectorTile() {
    final hasBasket = selectedBasket != BasketSize.none;
    return GestureDetector(
      onTap: _showBasketPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: hasBasket ? lightPurple : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: hasBasket ? purple : outline, width: hasBasket ? 1.5 : 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          const Text('🧺', style: TextStyle(fontSize: 26)), const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(hasBasket ? selectedBasket.label : 'Select Basket Size', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: hasBasket ? purple : onSurface)),
            const SizedBox(height: 2),
            Text(hasBasket ? '${selectedBasket.weightRange}  ·  Est. UGX ${_fmt(selectedBasket.minPrice(_pricePerKg))}–${_fmt(selectedBasket.maxPrice(_pricePerKg))}' : 'Tap to estimate weight of your clothing', style: const TextStyle(fontSize: 12, color: textGrey)),
          ])),
          Icon(Icons.chevron_right_rounded, color: hasBasket ? purple : textGrey),
        ]),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: outline.withOpacity(0.6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        GestureDetector(onTap: _pickDate, child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: lightPurple, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.today_rounded, color: purple, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: textGrey)),
            const SizedBox(height: 2),
            Text(selectedDate == null ? 'Select a date' : DateFormat('EEE, d MMM yyyy').format(selectedDate!), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: selectedDate == null ? textGrey : onSurface)),
          ])),
          Icon(Icons.expand_more_rounded, color: selectedDate != null ? purple : textGrey),
        ])),
        const SizedBox(height: 4),
        Divider(color: outline.withOpacity(0.4), height: 20),
        GestureDetector(onTap: _pickTime, child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: lightPurple, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.alarm_rounded, color: purple, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: textGrey)),
            const SizedBox(height: 2),
            Text(selectedTime == null ? 'Select a time' : selectedTime!.format(context), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: selectedTime == null ? textGrey : onSurface)),
          ])),
          Icon(Icons.expand_more_rounded, color: selectedTime != null ? purple : textGrey),
        ])),
      ]),
    );
  }

  Widget _buildTurnaroundSelector() {
    return Row(children: [
      Expanded(child: _turnaroundCard(TurnaroundTime.express, icon: Icons.bolt_rounded, title: 'Express', subtitle: '8–12 Hours', badge: 'PREMIUM', isGold: true)),
      const SizedBox(width: 12),
      Expanded(child: _turnaroundCard(TurnaroundTime.standard, icon: Icons.schedule_rounded, title: 'Standard', subtitle: '24–48 Hours', badge: 'REGULAR', isGold: false)),
    ]);
  }

  Widget _turnaroundCard(TurnaroundTime type, {required IconData icon, required String title, required String subtitle, required String badge, required bool isGold}) {
    final isSelected  = _turnaround == type;
    final accentColor = isGold ? gold : purple;
    return GestureDetector(
      onTap: () => setState(() => _turnaround = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? accentColor : outline.withOpacity(0.5), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: isSelected ? accentColor : textGrey, size: 22),
            if (isSelected) Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
          ]),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? accentColor : onSurface)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: textGrey)),
          const SizedBox(height: 6),
          Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: isSelected ? accentColor : textGrey)),
        ]),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final hasBasket  = selectedBasket != BasketSize.none;
    final hasSpecial = specialFixedTotal > 0;
    final showRange  = hasBasket || hasSpecial;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(28), border: Border.all(color: outline.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface)),
        const SizedBox(height: 16),
        if (hasClothingItems) _summaryRow('Clothing ($clothingCount items)', 'By weight'),
        if (hasSpecial) _summaryRow('Special items', 'UGX ${_fmt(specialFixedTotal)}'),
        if (totalItems == 0) const Text('No items added yet', style: TextStyle(fontSize: 13, color: textGrey)),
        const SizedBox(height: 12),
        Divider(color: outline.withOpacity(0.5)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Estimated Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
          Text(showRange ? 'UGX ${_fmt(estimatedMin)} – ${_fmt(estimatedMax)}' : totalItems > 0 ? 'By weight' : '—',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: purple)),
        ]),
      ]),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14, color: textGrey)),
      Text(value, style: const TextStyle(fontSize: 14, color: onSurface, fontWeight: FontWeight.w500)),
    ]));
  }

  Widget _buildBottomBar() {
    final hasBasket  = selectedBasket != BasketSize.none;
    final hasSpecial = specialFixedTotal > 0;
    final showRange  = hasBasket || hasSpecial;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: outline.withOpacity(0.4))), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]),
      child: SafeArea(top: false, child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('$totalItems item${totalItems == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: onSurface)),
          const SizedBox(height: 1),
          Text(showRange ? 'Est. UGX ${_fmt(estimatedMin)} – ${_fmt(estimatedMax)}' : totalItems > 0 ? 'Weight confirmed at pickup' : 'Add items to begin',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: showRange ? purple : textGrey)),
        ])),
        const SizedBox(width: 12),
        SizedBox(height: 50, child: ElevatedButton(
          onPressed: _isSubmitting ? null : _schedulePickup,
          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF1A0A2E), disabledBackgroundColor: const Color(0xFFD1D5DB), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Confirm Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ]),
        )),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [_buildBottomBar(), _buildBottomNav()]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(), const SizedBox(height: 28),
            _capsLabel('Select Branch'), _buildBranchSelector(), const SizedBox(height: 28),
            _capsLabel('Pickup Address'), _buildAddressCard(), const SizedBox(height: 28),
            _capsLabel('Schedule Pickup'), _buildDateTimeSection(), const SizedBox(height: 28),
            _sectionTitle('Standard Items', badge: 'Weight Based', badgeColor: const Color(0xFF735C00)),
            Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFECB3))),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF735C00)), const SizedBox(width: 8),
                Expanded(child: Text(_loadingPrices ? 'Loading prices...' : "Priced by weight · UGX ${_fmt(_pricePerKg)}/kg · Confirmed after pickup",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF735C00), fontWeight: FontWeight.w500))),
              ]),
            ),
            _buildItemRow(icon: Icons.checkroom_rounded, label: 'Shirts / Tops', value: shirts, onChanged: (v) => setState(() => shirts = v)),
            _buildItemRow(icon: Icons.dry_cleaning_rounded, label: 'Trousers', value: trousers, onChanged: (v) => setState(() => trousers = v)),
            _buildItemRow(icon: Icons.woman_rounded, label: 'Dresses', value: dresses, onChanged: (v) => setState(() => dresses = v)),
            _buildItemRow(icon: Icons.accessibility_new_rounded, label: 'Skirts', value: skirts, onChanged: (v) => setState(() => skirts = v)),
            if (hasClothingItems) ...[const SizedBox(height: 6), _basketSelectorTile()],
            const SizedBox(height: 28),
            _sectionTitle('Special Items', badge: 'Fixed Price'),
            _buildItemRow(icon: Icons.work_outline_rounded, label: 'Suit (2-Piece)', isSpecial: true, subtitle: _loadingPrices ? 'Loading...' : 'UGX ${_fmt(_suit2Price)} per suit', value: suits2Piece, onChanged: (v) => setState(() => suits2Piece = v)),
            _buildItemRow(icon: Icons.business_center_rounded, label: 'Suit (3-Piece)', isSpecial: true, subtitle: _loadingPrices ? 'Loading...' : 'UGX ${_fmt(_suit3Price)} per suit', value: suits3Piece, onChanged: (v) => setState(() => suits3Piece = v)),
            _buildItemRow(icon: Icons.bed_rounded, label: 'Duvet / Blanket', isSpecial: true, subtitle: _loadingPrices ? 'Loading...' : 'UGX ${_fmt(_duvetPrice)} each', value: duvets, onChanged: (v) => setState(() => duvets = v)),
            _buildItemRow(icon: Icons.window_rounded, label: 'Curtains', isSpecial: true, subtitle: _loadingPrices ? 'Loading...' : 'UGX ${_fmt(_curtainPrice)} per piece', value: curtains, onChanged: (v) => setState(() => curtains = v)),
            const SizedBox(height: 28),
            _sectionTitle('Turnaround Time'), _buildTurnaroundSelector(), const SizedBox(height: 28),
            _buildOrderSummary(), const SizedBox(height: 28),
            _capsLabel('Special Instructions (Optional)'),
            TextField(
              controller: _instructionsCtrl, maxLines: 3, maxLength: 250,
              decoration: InputDecoration(
                hintText: 'e.g. Handle black dress gently, use fabric softener on shirts…',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                filled: true, fillColor: Colors.white,
                counterStyle: const TextStyle(fontSize: 11, color: textGrey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: outline)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: purple, width: 1.5)),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 13, color: onSurface),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}