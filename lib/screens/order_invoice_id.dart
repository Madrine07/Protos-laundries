// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class OrderInvoiceFromId extends StatefulWidget {
  final int orderId;
  const OrderInvoiceFromId({super.key, required this.orderId});

  @override
  State<OrderInvoiceFromId> createState() => _OrderInvoiceFromIdState();
}

class _OrderInvoiceFromIdState extends State<OrderInvoiceFromId> {
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
        orderId: data['id'],
        pickupDate: data['pickup_date'] ?? 'Walk-in',
        clientName:
            data['customer_name'] ?? data['user']?['name'] ?? 'Customer',
        clientAddress: data['pickup_address'] ?? 'Branch Walk-in',
        clothingKg: num.tryParse(data['actual_kg'].toString())?.toDouble() ?? 0,
        finalAmount: num.tryParse(data['final_amount'].toString())?.toInt(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderInvoiceScreen(invoice: invoice)),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6B21A8)),
                  SizedBox(height: 16),
                  Text(
                    'Loading your order...',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
      ),
    );
  }
}
