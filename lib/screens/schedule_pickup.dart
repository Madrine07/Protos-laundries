// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

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

  // Min/max are now multipliers × price_per_kg
  // half: 3kg–4kg, full: 6kg–8kg, two: 10kg–12kg
  double get minKg {
    switch (this) {
      case BasketSize.none: return 0;
      case BasketSize.half: return 3;
      case BasketSize.full: return 6;
      case BasketSize.two:  return 10;
    }
  }

  double get maxKg {
    switch (this) {
      case BasketSize.none: return 0;
      case BasketSize.half: return 4;
      case BasketSize.full: return 8;
      case BasketSize.two:  return 12;
    }
  }

  int minPrice(int pricePerKg) => (minKg * pricePerKg).round();
  int maxPrice(int pricePerKg) => (maxKg * pricePerKg).round();

  String? get apiValue {
    switch (this) {
      case BasketSize.none: return null;
      case BasketSize.half: return 'half';
      case BasketSize.full: return 'full';
      case BasketSize.two:  return 'two';
    }
  }
}

class SchedulePickupScreen extends StatefulWidget {
  const SchedulePickupScreen({super.key});

  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  static const Color purple      = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);

  final ApiService _apiService = ApiService();

  bool _isSubmitting    = false;
  bool _loadingAddress  = true;
  bool _loadingBranches = true;
  bool _loadingPrices   = true;

  // Dynamic prices from backend
  Map<String, int> _prices = {
    'price_per_kg': 3000,
    'suit_2_piece': 15000,
    'suit_3_piece': 20000,
    'duvet':        22500,
    'curtain':      10000,
  };

  // Dynamic branches from API
  List<Map<String, dynamic>> _branches = [];
  Map<String, dynamic>? _selectedBranch;

  DateTime?  selectedDate;
  TimeOfDay? selectedTime;
  BasketSize selectedBasket = BasketSize.none;

  String pickupAddress = '';

  int shirts      = 0;
  int trousers    = 0;
  int dresses     = 0;
  int skirts      = 0;
  int suits2Piece = 0;
  int suits3Piece = 0;
  int duvets      = 0;
  int curtains    = 0;

  final TextEditingController _instructionsCtrl = TextEditingController();

  // ── Convenience getters ──
  int get _pricePerKg  => _prices['price_per_kg'] ?? 3000;
  int get _suit2Price  => _prices['suit_2_piece']  ?? 15000;
  int get _suit3Price  => _prices['suit_3_piece']  ?? 20000;
  int get _duvetPrice  => _prices['duvet']         ?? 22500;
  int get _curtainPrice => _prices['curtain']      ?? 10000;

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _loadBranches();
    _loadPrices();
  }

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    try {
      final prices = await _apiService.fetchPrices();
      if (!mounted) return;
      setState(() => _prices = prices);
    } catch (e) {
      // use defaults
    } finally {
      if (mounted) setState(() => _loadingPrices = false);
    }
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _apiService.getBranches();
      if (!mounted) return;
      setState(() {
        _branches = branches;
        _loadingBranches = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingBranches = false);
    }
  }

  Future<void> _loadAddress() async {
    if (!mounted) return;
    setState(() => _loadingAddress = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() => pickupAddress = data['address'] ?? '');
      }
    } catch (e) {
      // silent fail
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  // ── Computed ──
  int get clothingCount     => shirts + trousers + dresses + skirts;
  int get specialCount      => suits2Piece + suits3Piece + duvets + curtains;
  int get totalItems        => clothingCount + specialCount;

  int get specialFixedTotal =>
      (suits2Piece * _suit2Price) +
      (suits3Piece * _suit3Price) +
      (duvets      * _duvetPrice) +
      (curtains    * _curtainPrice);

  int get estimatedMin =>
      selectedBasket.minPrice(_pricePerKg) + specialFixedTotal;

  int get estimatedMax =>
      selectedBasket.maxPrice(_pricePerKg) + specialFixedTotal;

  bool get hasClothingItems => clothingCount > 0;

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  // ── Branch selector ──
  Widget _buildBranchSelector() {
    if (_loadingBranches) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: purple),
        ),
      );
    }

    if (_branches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Text(
          'No branches available. Please try again later.',
          style: TextStyle(color: Color(0xFF92400E), fontSize: 13),
        ),
      );
    }

    if (_branches.length > 4) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedBranch != null ? purple : const Color(0xFFE5E7EB),
            width: _selectedBranch != null ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedBranch,
            hint: const Text('Select Branch',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: purple),
            items: _branches.map((branch) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: branch,
                child: Row(
                  children: [
                    const Icon(Icons.store_mall_directory_rounded,
                        color: purple, size: 18),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(branch['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E))),
                        if ((branch['location'] ?? '').isNotEmpty)
                          Text(branch['location'],
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedBranch = value),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: _branches.map((branch) => _branchCard(branch)).toList(),
    );
  }

  Widget _branchCard(Map<String, dynamic> branch) {
    final isSelected = _selectedBranch?['id'] == branch['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedBranch = branch),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? purple : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color.fromRGBO(107, 33, 168, 0.15)
                  : const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? purple : lightPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.store_mall_directory_rounded,
                      color: isSelected ? Colors.white : purple, size: 18),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: purple, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(branch['name'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? purple : const Color(0xFF1A1A2E),
                )),
            const SizedBox(height: 2),
            Text(branch['location'] ?? '',
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: purple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: purple,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> _editAddress() async {
    final ctrl = TextEditingController(text: pickupAddress);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Change Pickup Address',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text(
                'This overrides your profile address for this pickup only',
                style:
                    TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter pickup address',
                  filled: true,
                  fillColor: const Color(0xFFF8F7FF),
                  prefixIcon: const Icon(Icons.location_on_rounded,
                      color: purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: purple, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final val = ctrl.text.trim();
                    if (val.isNotEmpty){
                      setState(() => pickupAddress = val);
                    Navigator.pop(ctx);}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Address',
                      style:
                          TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    ctrl.dispose();
  }

  void _showBasketPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Estimate Laundry Size',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text(
              'For shirts, trousers, dresses & skirts only  ·  UGX ${_fmt(_pricePerKg)}/kg',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 20),
            ...[BasketSize.half, BasketSize.full, BasketSize.two]
                .map((b) => _basketOption(b, ctx)),
          ],
        ),
      ),
    );
  }

  Widget _basketOption(BasketSize b, BuildContext sheetCtx) {
    final isSelected = selectedBasket == b;
    final minP = b.minPrice(_pricePerKg);
    final maxP = b.maxPrice(_pricePerKg);
    return GestureDetector(
      onTap: () {
        setState(() => selectedBasket = b);
        Navigator.pop(sheetCtx);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? lightPurple : const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? purple : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Text('🧺', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isSelected
                            ? purple
                            : const Color(0xFF1A1A2E),
                      )),
                  Text(
                    '${b.weightRange}  ·  Est. UGX ${_fmt(minP)} – ${_fmt(maxP)}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: purple, size: 20),
          ],
        ),
      ),
    );
  }

  void _schedulePickup() async {
    if (_isSubmitting) return;

    if (_selectedBranch == null) {
      _snack('Please select a branch', isError: true);
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      _snack('Please select a pickup date and time', isError: true);
      return;
    }
    if (pickupAddress.trim().isEmpty) {
      _snack('Please enter a pickup address', isError: true);
      return;
    }
    if (totalItems == 0 && selectedBasket == BasketSize.none) {
      _snack('Please add items or select a basket size', isError: true);
      return;
    }
    if (hasClothingItems && selectedBasket == BasketSize.none) {
      _snack('Please select a basket size for your clothing items',
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate!);
      final formattedTime =
          '${selectedTime!.hour.toString().padLeft(2, '0')}:'
          '${selectedTime!.minute.toString().padLeft(2, '0')}:00';

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
        branchId:      _selectedBranch!['id'] as int,
        pickupAddress: pickupAddress,
        pickupDate:    formattedDate,
        pickupTime:    formattedTime,
        instructions:  _instructionsCtrl.text.trim().isEmpty
            ? null
            : _instructionsCtrl.text.trim(),
        basketSize:    selectedBasket.apiValue,
        estimatedMin:  estimatedMin,
        estimatedMax:  estimatedMax,
        items:         items,
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
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _resetForm() {
    setState(() {
      _selectedBranch = null;
      selectedDate    = null;
      selectedTime    = null;
      _instructionsCtrl.clear();
      shirts      = 0;
      trousers    = 0;
      dresses     = 0;
      skirts      = 0;
      suits2Piece = 0;
      suits3Piece = 0;
      duvets      = 0;
      curtains    = 0;
      selectedBasket = BasketSize.none;
    });
    _loadAddress();
    _loadBranches();
    _loadPrices();
  }

  Widget _sectionHeader(String title, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              )),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      fontSize: 10,
                      color: purple,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateTimeCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? purple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? purple : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color.fromRGBO(107, 33, 168, 0.25)
                  : const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected
                    ? Colors.white70
                    : const Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white70
                      : const Color(0xFF9CA3AF),
                )),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF1A1A2E),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    )),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: purple,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ],
            ),
          ),
          _buildCounter(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildCounter(int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _counterBtn(
          icon: Icons.remove,
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          active: value > 0,
        ),
        SizedBox(
          width: 36,
          child: Text(value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              )),
        ),
        _counterBtn(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
          active: true,
        ),
      ],
    );
  }

  Widget _counterBtn({
    required IconData icon,
    required VoidCallback? onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30, height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? purple : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16,
            color: active ? Colors.white : Colors.grey[400]),
      ),
    );
  }

  Widget _basketSelectorTile() {
    final hasBasket = selectedBasket != BasketSize.none;
    final minP = selectedBasket.minPrice(_pricePerKg);
    final maxP = selectedBasket.maxPrice(_pricePerKg);
    return GestureDetector(
      onTap: _showBasketPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasBasket ? lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasBasket ? purple : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🧺', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasBasket
                        ? selectedBasket.label
                        : 'Select Basket Size',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: hasBasket
                          ? purple
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasBasket
                        ? '${selectedBasket.weightRange}  ·  Est. UGX ${_fmt(minP)}–${_fmt(maxP)}'
                        : 'Tap to estimate weight of your clothing items',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color:
                    hasBasket ? purple : const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final hasBasket  = selectedBasket != BasketSize.none;
    final hasSpecial = specialFixedTotal > 0;
    final showRange  = hasBasket || hasSpecial;

    final summaryText = showRange
        ? 'Est. UGX ${_fmt(estimatedMin)} – ${_fmt(estimatedMax)}'
        : '$totalItems item${totalItems == 1 ? '' : 's'} added';

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '$totalItems item${totalItems == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      fontSize: 13,
                    )),
                const SizedBox(height: 1),
                Text(summaryText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: showRange
                          ? purple
                          : const Color(0xFF9CA3AF),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _schedulePickup,
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                              Colors.white)))
                  : const Text('Confirm Pickup',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryBar(),
          BottomNavigationBar(
            currentIndex: 2,
            selectedItemColor: purple,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            onTap: (index) {
              if (index == 0) Navigator.pushNamed(context, '/home');
              if (index == 1) Navigator.pushNamed(context, '/orders');
              if (index == 3){
                Navigator.pushNamed(context, '/notifications');}
              if (index == 4) Navigator.pushNamed(context, '/account');
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Orders'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: 'Schedule'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_rounded),
                  label: 'Notifications'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded), label: 'Account'),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Schedule Pickup',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  )),
              const SizedBox(height: 4),
              const Text(
                'Choose when we should pick up your laundry',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 24),

              // ── BRANCH ──
              _sectionHeader('Select Branch'),
              _buildBranchSelector(),
              const SizedBox(height: 28),

              // ── ADDRESS ──
              _sectionHeader('Pickup Address'),
              GestureDetector(
                onTap: _editAddress,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: pickupAddress.isEmpty
                        ? const Color(0xFFFFFBEB)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: pickupAddress.isEmpty
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFFE5E7EB),
                      width: pickupAddress.isEmpty ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: pickupAddress.isEmpty
                              ? const Color(0xFFFEF3C7)
                              : lightPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on_rounded,
                            color: pickupAddress.isEmpty
                                ? const Color(0xFFD97706)
                                : purple,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _loadingAddress
                            ? const Text('Loading address...',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF)))
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pickupAddress.isEmpty
                                        ? 'No address set'
                                        : pickupAddress,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: pickupAddress.isEmpty
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickupAddress.isEmpty
                                        ? 'Tap to enter or add one in Account'
                                        : 'Tap to change for this pickup',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                      ),
                      Icon(Icons.edit_rounded,
                          size: 16,
                          color: pickupAddress.isEmpty
                              ? const Color(0xFFD97706)
                              : purple),
                    ],
                  ),
                ),
              ),
              if (!_loadingAddress && pickupAddress.isEmpty) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/account'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Add your address in Account settings to pre-fill it here. Tap to go there →',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // ── DATE & TIME ──
              _sectionHeader('Pickup Date & Time'),
              Row(
                children: [
                  Expanded(
                    child: _dateTimeCard(
                      icon: Icons.calendar_today_rounded,
                      label: 'DATE',
                      value: selectedDate == null
                          ? 'Select Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      onTap: _pickDate,
                      isSelected: selectedDate != null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateTimeCard(
                      icon: Icons.access_time_rounded,
                      label: 'TIME',
                      value: selectedTime == null
                          ? 'Select Time'
                          : selectedTime!.format(context),
                      onTap: _pickTime,
                      isSelected: selectedTime != null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── CLOTHING ITEMS ──
              _sectionHeader('Clothing Items',
                  badge: _loadingPrices
                      ? 'Loading prices...'
                      : 'Weighed at pickup · UGX ${_fmt(_pricePerKg)}/kg'),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFFDE68A), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prices for these items are set by weight. We\'ll confirm the exact amount after pickup.',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              _buildItemRow(
                icon: Icons.checkroom_rounded,
                label: 'Shirts / Tops',
                value: shirts,
                onChanged: (val) => setState(() => shirts = val),
              ),
              _buildItemRow(
                icon: Icons.accessibility_new_rounded,
                label: 'Trousers',
                value: trousers,
                onChanged: (val) => setState(() => trousers = val),
              ),
              _buildItemRow(
                icon: Icons.woman_rounded,
                label: 'Dresses',
                value: dresses,
                onChanged: (val) => setState(() => dresses = val),
              ),
              _buildItemRow(
                icon: Icons.dry_cleaning_rounded,
                label: 'Skirts',
                value: skirts,
                onChanged: (val) => setState(() => skirts = val),
              ),
              if (hasClothingItems) ...[
                const SizedBox(height: 6),
                _basketSelectorTile(),
              ],
              const SizedBox(height: 28),

              // ── SPECIAL ITEMS ──
              _sectionHeader('Special Items', badge: 'Fixed price'),
              _buildItemRow(
                icon: Icons.work_outline_rounded,
                label: 'Suit (2-Piece)',
                subtitle: _loadingPrices
                    ? 'Loading...'
                    : 'UGX ${_fmt(_suit2Price)} per suit',
                value: suits2Piece,
                onChanged: (val) =>
                    setState(() => suits2Piece = val),
              ),
              _buildItemRow(
                icon: Icons.business_center_rounded,
                label: 'Suit (3-Piece)',
                subtitle: _loadingPrices
                    ? 'Loading...'
                    : 'UGX ${_fmt(_suit3Price)} per suit',
                value: suits3Piece,
                onChanged: (val) =>
                    setState(() => suits3Piece = val),
              ),
              _buildItemRow(
                icon: Icons.bed_rounded,
                label: 'Duvet',
                subtitle: _loadingPrices
                    ? 'Loading...'
                    : 'UGX ${_fmt(_duvetPrice)} each',
                value: duvets,
                onChanged: (val) => setState(() => duvets = val),
              ),
              _buildItemRow(
                icon: Icons.window_rounded,
                label: 'Curtains',
                subtitle: _loadingPrices
                    ? 'Loading...'
                    : 'UGX ${_fmt(_curtainPrice)} per piece',
                value: curtains,
                onChanged: (val) =>
                    setState(() => curtains = val),
              ),
              const SizedBox(height: 28),

              // ── INSTRUCTIONS ──
              _sectionHeader('Special Instructions',
                  badge: 'Optional'),
              TextField(
                controller: _instructionsCtrl,
                maxLines: 3,
                maxLength: 250,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Handle black dress gently, use fabric softener on shirts…',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFFBDBDBD)),
                  filled: true,
                  fillColor: Colors.white,
                  counterStyle: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: purple, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}