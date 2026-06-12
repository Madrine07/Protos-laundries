// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class OrderInvoiceFromId extends StatefulWidget {
  final int orderId;
  const OrderInvoiceFromId({super.key, required this.orderId});

  @override
  State<OrderInvoiceFromId> createState() => _OrderInvoiceFromIdState();
}

class _OrderInvoiceFromIdState extends State<OrderInvoiceFromId> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color gold   = Color(0xFFD4AF37);

  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getOrderDetails(widget.orderId);

      final invoice = OrderInvoice(
        orderId:       data['id'],
        pickupDate:    data['pickup_date'] ?? 'Walk-in',
        clientName:    data['customer_name'] ?? data['user']?['name'] ?? 'Customer',
        clientAddress: data['pickup_address'] ?? 'Branch Walk-in',
        clothingKg:    num.tryParse(data['actual_kg'].toString())?.toDouble() ?? 0,
        finalAmount:   num.tryParse(data['final_amount'].toString())?.toInt(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderInvoiceScreen(invoice: invoice)),
      );
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.error_outline_rounded, color: gold.withOpacity(0.5), size: 52),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(color: purple, borderRadius: BorderRadius.circular(14)),
                        child: const Text('Go Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
              )
            : Shimmer.fromColors(
                baseColor: const Color(0xFFE5E7EB),
                highlightColor: const Color(0xFFF9FAFB),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    const SizedBox(height: 20),
                    Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    const SizedBox(height: 20),
                    Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                    const SizedBox(height: 20),
                    Container(height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
                  ]),
                ),
              ),
      ),
    );
  }
}