import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';


// ─────────────────────────────────────────────
// Branch enum - matches backend branches table
// ─────────────────────────────────────────────
enum Branch { none, mulago, kulambiro }

extension BranchInfo on Branch {
  String get label {
    switch (this) {
      case Branch.none: return 'Select Branch';
      case Branch.mulago: return 'Mulago Branch';
      case Branch.kulambiro: return 'Kulambiro Branch';
    }
  }

  String get address {
    switch (this) {
      case Branch.none: return '';
      case Branch.mulago: return 'Mulago Hospital Road, Kampala';
      case Branch.kulambiro: return 'Kulambiro Road, Kampala';
    }
  }

  // Returns the branch_id from your database
  // Mulago = 1, Kulambiro = 2 (based on your seeder order)
  int? get branchId {
    switch (this) {
      case Branch.none: return null;
      case Branch.mulago: return 1;
      case Branch.kulambiro: return 2;
    }
  }

  IconData get icon {
    switch (this) {
      case Branch.none: return Icons.store_rounded;
      case Branch.mulago: return Icons.local_hospital_rounded;
      case Branch.kulambiro: return Icons.store_mall_directory_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// Basket size model
// ─────────────────────────────────────────────
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

  // UGX 3,000 / kg
  int get minPrice {
    switch (this) {
      case BasketSize.none: return 0;
      case BasketSize.half: return 9000;
      case BasketSize.full: return 18000;
      case BasketSize.two:  return 30000;
    }
  }

  int get maxPrice {
    switch (this) {
      case BasketSize.none: return 0;
      case BasketSize.half: return 12000;
      case BasketSize.full: return 24000;
      case BasketSize.two:  return 36000;
    }
  }

  // Convert to API format
  String? get apiValue {
    switch (this) {
      case BasketSize.none: return null;
      case BasketSize.half: return 'half';
      case BasketSize.full: return 'full';
      case BasketSize.two:  return 'two';
    }
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class SchedulePickupScreen extends StatefulWidget {
  const SchedulePickupScreen({super.key});

  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  final ApiService _apiService = ApiService();

  bool _isSubmitting = false;

  Branch selectedBranch = Branch.none;
  DateTime?   selectedDate;
  TimeOfDay?  selectedTime;
  BasketSize  selectedBasket = BasketSize.none;

  // Address (loaded from profile, overridable per pickup)
  String pickupAddress = "Plot 10, Kulambiro Road, Kampala";

  // Clothing counters (no fixed price – weighed at pickup)
  int shirts   = 0;
  int trousers = 0;
  int dresses  = 0;
  int skirts   = 0;

  // Special fixed-price items
  int suits2Piece = 0;
  int suits3Piece = 0;
  int duvets      = 0;
  int curtains    = 0;

  // Optional instructions
  final TextEditingController _instructionsCtrl = TextEditingController();

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  // ── computed ──────────────────────────────────

  int get clothingCount   => shirts + trousers + dresses + skirts;
  int get specialCount    => suits2Piece + suits3Piece + duvets + curtains;
  int get totalItems      => clothingCount + specialCount;

  int get specialFixedTotal =>
      (suits2Piece * 15000) +
      (suits3Piece * 20000) +
      (duvets      * 22500) + // midpoint of 15k–30k range
      (curtains    * 10000);

  int get estimatedMin => selectedBasket.minPrice + specialFixedTotal;
  int get estimatedMax => selectedBasket.maxPrice + specialFixedTotal;

  bool get hasClothingItems => clothingCount > 0;

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // ── pickers ───────────────────────────────────

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context:     context,
      initialDate: now,
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   Color(0xFF6B21A8),
            onPrimary: Colors.white,
            surface:   Colors.white,
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
      context:     context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   Color(0xFF6B21A8),
            onPrimary: Colors.white,
            surface:   Colors.white,
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
      context:          context,
      isScrollControlled: true,
      backgroundColor:  Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            const Text("Change Pickup Address",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            const Text("This overrides your profile address for this pickup only",
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus:  true,
              maxLines:   2,
              decoration: InputDecoration(
                hintText:    "Enter pickup address",
                filled:      true,
                fillColor:   const Color(0xFFF8F7FF),
                prefixIcon:  const Icon(Icons.location_on_rounded,
                    color: Color(0xFF6B21A8)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF6B21A8), width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final val = ctrl.text.trim();
                  if (val.isNotEmpty) setState(() => pickupAddress = val);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B21A8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Save Address",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
  }

  void _showBasketPicker() {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            const Text("Estimate Laundry Size",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            const Text(
              "For shirts, trousers, dresses & skirts only  ·  UGX 3,000/kg",
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
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
    return GestureDetector(
      onTap: () {
        setState(() => selectedBasket = b);
        Navigator.pop(sheetCtx);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin:  const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E8FF) : const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B21A8)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Text("🧺", style: TextStyle(fontSize: 24)),
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
                              ? const Color(0xFF6B21A8)
                              : const Color(0xFF1A1A2E))),
                  Text(
                    "${b.weightRange}  ·  Est. UGX ${_fmt(b.minPrice)} – ${_fmt(b.maxPrice)}",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF6B21A8), size: 20),
          ],
        ),
      ),
    );
  }



  void _schedulePickup() async {
    // Validation
    if (_isSubmitting) return;
    

    if (selectedBranch == Branch.none) {
      _snack("Please select a branch", isError: true);
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      _snack("Please select a pickup date and time", isError: true);
      return;
    }
    if (totalItems == 0 && selectedBasket == BasketSize.none) {
      _snack("Please add items or select a basket size", isError: true);
      return;
    }
    if (hasClothingItems && selectedBasket == BasketSize.none) {
      _snack("Please select a basket size for your clothing items",
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Format date and time for Laravel
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final formattedTime = '${selectedTime!.hour.toString().padLeft(2, '0')}:'
          '${selectedTime!.minute.toString().padLeft(2, '0')}:00';

      // Prepare items map
      final Map<String, int> items = {};
      if (shirts > 0) items['shirts'] = shirts;
      if (trousers > 0) items['trousers'] = trousers;
      if (dresses > 0) items['dresses'] = dresses;
      if (skirts > 0) items['skirts'] = skirts;
      if (suits2Piece > 0) items['suits_2'] = suits2Piece;
      if (suits3Piece > 0) items['suits_3'] = suits3Piece;
      if (duvets > 0) items['duvets'] = duvets;
      if (curtains > 0) items['curtains'] = curtains;

      final response = await _apiService.createOrder(
        branchId: selectedBranch.branchId!,
        pickupAddress: pickupAddress,
        pickupDate: formattedDate,
        pickupTime: formattedTime,
        instructions: _instructionsCtrl.text.trim().isEmpty 
            ? null 
            : _instructionsCtrl.text.trim(),
        basketSize: selectedBasket.apiValue,
        estimatedMin: estimatedMin,
        estimatedMax: estimatedMax,
        items: items,
      );

      // Success - check if widget is still mounted
      if (!mounted) return;
      
      _snack("Pickup Scheduled Successfully! Order #${response['order']['id']}");
      _resetForm();

      
      // Navigate to orders screen after delay
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      
      Navigator.pushReplacementNamed(context, "/orders");
      
    } catch (e) {
    //  USER FRIENDLY ERROR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Something went wrong. Please try again."),
        backgroundColor: Colors.red,
      ),
    );

    //  DEV LOG (only you see in console)
    debugPrint("ORDER ERROR: $e");

  } finally {
    setState(() => _isSubmitting = false);
  } 
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? Colors.redAccent : const Color(0xFF6B21A8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }




  // ─────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────

  Widget _branchCard(Branch branch) {
    final isSelected = selectedBranch == branch;
    return GestureDetector(
      onTap: () => setState(() => selectedBranch = branch),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B21A8)
                : const Color(0xFFE5E7EB),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B21A8)
                        : const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    branch.icon,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B21A8),
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF6B21A8), size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              branch.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF6B21A8)
                    : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              branch.address,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B21A8),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateTimeCard({
    required IconData icon,
    required String   label,
    required String   value,
    required VoidCallback onTap,
    required bool     isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B21A8) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B21A8)
                : const Color(0xFFE5E7EB),
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
            Icon(icon, size: 20,
                color: isSelected
                    ? Colors.white70
                    : const Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white70
                        : const Color(0xFF9CA3AF),
                    letterSpacing: 0.05)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow({
    required IconData icon,
    required String   label,
    String?           subtitle,
    required int      value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6B21A8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B21A8),
                          fontWeight: FontWeight.w500)),
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
          icon:  Icons.remove,
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          active: value > 0,
        ),
        SizedBox(
          width: 36,
          child: Text(value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16,
                  color: Color(0xFF1A1A2E))),
        ),
        _counterBtn(
          icon:  Icons.add,
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
          color: active
              ? const Color(0xFF6B21A8)
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16,
            color: active ? Colors.white : Colors.grey[400]),
      ),
    );
  }

  Widget _basketSelectorTile() {
    final hasBasket = selectedBasket != BasketSize.none;
    return GestureDetector(
      onTap: _showBasketPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasBasket ? const Color(0xFFF3E8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasBasket
                ? const Color(0xFF6B21A8)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const Text("🧺", style: TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasBasket ? selectedBasket.label : "Select Basket Size",
                    style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14,
                      color: hasBasket
                          ? const Color(0xFF6B21A8)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasBasket
                        ? "${selectedBasket.weightRange}  ·  Est. UGX ${_fmt(selectedBasket.minPrice)}–${_fmt(selectedBasket.maxPrice)}"
                        : "Tap to estimate weight of your clothing items",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: hasBasket
                  ? const Color(0xFF6B21A8)
                  : const Color(0xFF9CA3AF),
            ),
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
        ? "Est. UGX ${_fmt(estimatedMin)} – ${_fmt(estimatedMax)}"
        : "$totalItems item${totalItems == 1 ? '' : 's'} added";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3)),
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
                  "$totalItems item${totalItems == 1 ? '' : 's'}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      fontSize: 13),
                ),
                const SizedBox(height: 1),
                Text(
                  summaryText,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: showRange
                          ? const Color(0xFF6B21A8)
                          : const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _schedulePickup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B21A8),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Confirm Pickup",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
  setState(() {
    // reset branch
    selectedBranch = Branch.none;

    // Reset date & time
    selectedDate = null;
    selectedTime = null;

    // reset text fields
    pickupAddress = '';
    _instructionsCtrl.clear();

    // reset items
    shirts = 0;
    trousers = 0;
    dresses = 0;
    skirts = 0;
    suits2Piece = 0;
    suits3Piece = 0;
    duvets = 0;
    curtains = 0;

    // Clear instructions
    _instructionsCtrl.clear();

    // reset basket
    selectedBasket = BasketSize.none;
  });
}


  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
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
            selectedItemColor:   const Color(0xFF6B21A8),
            unselectedItemColor: Colors.grey,
            backgroundColor:     Colors.white,
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
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TITLE ───────────────────────────
              const Text("Schedule Pickup",
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text("Choose when we should pick up your laundry",
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),

              const SizedBox(height: 24),

              // ── SELECT BRANCH ─────────────────────
              _sectionHeader("Select Branch"),
              Row(
                children: [
                  Expanded(
                    child: _branchCard(Branch.mulago),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _branchCard(Branch.kulambiro),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── PICKUP ADDRESS ───────────────────
              _sectionHeader("Pickup Address"),
              GestureDetector(
                onTap: _editAddress,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: Color(0xFF6B21A8), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pickupAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 2),
                            const Text("Tap to change for this pickup",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_rounded,
                          size: 16, color: Color(0xFF6B21A8)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── DATE & TIME ──────────────────────
              _sectionHeader("Pickup Date & Time"),
              Row(
                children: [
                  Expanded(
                    child: _dateTimeCard(
                      icon:       Icons.calendar_today_rounded,
                      label:      "DATE",
                      value:      selectedDate == null
                          ? "Select Date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      onTap:      _pickDate,
                      isSelected: selectedDate != null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateTimeCard(
                      icon:       Icons.access_time_rounded,
                      label:      "TIME",
                      value:      selectedTime == null
                          ? "Select Time"
                          : selectedTime!.format(context),
                      onTap:      _pickTime,
                      isSelected: selectedTime != null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── CLOTHING ITEMS ───────────────────
              _sectionHeader("Clothing Items",
                  badge: "Weighed at pickup · UGX 3,000/kg"),

              // Info banner
              Container(
                margin:  const EdgeInsets.only(bottom: 12),
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
                        "Prices for these items are set by weight. We'll confirm the exact amount after pickup.",
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
                icon: Icons.checkroom_rounded, label: "Shirts / Tops",
                value: shirts,
                onChanged: (val) => setState(() => shirts = val),
              ),
              _buildItemRow(
                icon: Icons.accessibility_new_rounded, label: "Trousers",
                value: trousers,
                onChanged: (val) => setState(() => trousers = val),
              ),
              _buildItemRow(
                icon: Icons.woman_rounded, label: "Dresses",
                value: dresses,
                onChanged: (val) => setState(() => dresses = val),
              ),
              _buildItemRow(
                icon: Icons.dry_cleaning_rounded, label: "Skirts",
                value: skirts,
                onChanged: (val) => setState(() => skirts = val),
              ),

              // Basket selector appears once user adds clothing items
              if (hasClothingItems) ...[
                const SizedBox(height: 6),
                _basketSelectorTile(),
              ],

              const SizedBox(height: 28),

              // ── SPECIAL ITEMS ────────────────────
              _sectionHeader("Special Items", badge: "Fixed price"),
              _buildItemRow(
                icon: Icons.work_outline_rounded,
                label: "Suit (2-Piece)",
                subtitle: "UGX 15,000 per suit",
                value: suits2Piece,
                onChanged: (val) => setState(() => suits2Piece = val),
              ),
              _buildItemRow(
                icon: Icons.business_center_rounded,
                label: "Suit (3-Piece)",
                subtitle: "UGX 20,000 per suit",
                value: suits3Piece,
                onChanged: (val) => setState(() => suits3Piece = val),
              ),
              _buildItemRow(
                icon: Icons.bed_rounded,
                label: "Duvet",
                subtitle: "UGX 15,000 – 30,000",
                value: duvets,
                onChanged: (val) => setState(() => duvets = val),
              ),
              _buildItemRow(
                icon: Icons.window_rounded,
                label: "Curtains",
                subtitle: "UGX 10,000 per piece",
                value: curtains,
                onChanged: (val) => setState(() => curtains = val),
              ),

              const SizedBox(height: 28),

              // ── SPECIAL INSTRUCTIONS ─────────────
              _sectionHeader("Special Instructions", badge: "Optional"),
              TextField(
                controller: _instructionsCtrl,
                maxLines:   3,
                maxLength:  250,
                decoration: InputDecoration(
                  hintText:
                      "e.g. Handle black dress gently, use fabric softener on shirts…",
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFFBDBDBD)),
                  filled:     true,
                  fillColor:  Colors.white,
                  counterStyle: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF6B21A8), width: 1.5)),
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