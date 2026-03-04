// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const Color purple      = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFFF3E8FF);

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How long does laundry take?',
      'a': 'Standard laundry takes 24–48 hours from pickup to delivery. Special items like duvets and suits may take up to 72 hours. We\'ll notify you when your order is ready.',
    },
    {
      'q': 'How do I pay?',
      'a': 'We accept MTN Mobile Money and Airtel Money. After your laundry is ready, you\'ll receive the final amount and can upload your payment screenshot directly in the app.',
    },
    {
      'q': 'What if my clothes are damaged?',
      'a': 'We handle all items with great care. In the rare event of damage, please contact us within 24 hours of delivery with photos. We\'ll investigate and resolve it promptly.',
    },
    {
      'q': 'Can I cancel an order?',
      'a': 'You can cancel an order up to 2 days before your scheduled pickup date directly in the app. If it\'s less than a day away, please call your branch directly to cancel manually.',
    },
    {
      'q': 'How does pickup work?',
      'a': 'After scheduling, our team comes to your address at the selected date and time to collect your laundry. Make sure someone is available at the address or leave instructions for the rider.',
    },
    {
      'q': 'What areas do you cover?',
      'a': 'We currently serve the Mulago, Kulambiro, and Ntinda areas of Kampala. We\'re expanding — check our Branches screen for the latest locations.',
    },
  ];

  final Set<int> _expanded = {};

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/256$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _email() async {
    final uri = Uri.parse(
        'mailto:protoslaundries@gmail.com?subject=Support Request&body=Hello Protos Laundries,');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: purple, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEDE9F6)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [

          // ── Header banner ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(106, 27, 154, 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We\'re here to help',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Reach us via WhatsApp, call, or email',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Contact section label ──
          _sectionLabel('Contact Us Directly'),
          const SizedBox(height: 12),

          // ── WhatsApp buttons ──
          _contactCard(
            icon: Icons.chat_rounded,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF4CAF50),
            title: 'WhatsApp Us',
            subtitle: 'Chat with us on WhatsApp',
            children: [
              _numberRow('0784 267214', isWhatsapp: true,
                  onTap: () => _whatsapp('0784267214')),
              const SizedBox(height: 8),
              _numberRow('0743 174294', isWhatsapp: true,
                  onTap: () => _whatsapp('0743174294')),
            ],
          ),

          const SizedBox(height: 12),

          // ── Call buttons ──
          _contactCard(
            icon: Icons.call_rounded,
            iconBg: lightPurple,
            iconColor: purple,
            title: 'Call Us',
            subtitle: 'Speak to our team directly',
            children: [
              _numberRow('0784 267214',
                  onTap: () => _call('0784267214')),
              const SizedBox(height: 8),
              _numberRow('0743 174294',
                  onTap: () => _call('0743174294')),
            ],
          ),

          const SizedBox(height: 12),

          // ── Email ──
          GestureDetector(
            onTap: _email,
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.email_rounded,
                        color: Color(0xFFFF8F00), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email Support',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            )),
                        SizedBox(height: 2),
                        Text('protoslaundries@gmail.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── FAQ section ──
          _sectionLabel('Frequently Asked Questions'),
          const SizedBox(height: 4),
          const Text(
            'Tap a question to see the answer',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 14),

          ..._faqs.asMap().entries.map((entry) {
            final i       = entry.key;
            final faq     = entry.value;
            final isOpen  = _expanded.contains(i);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isOpen
                      ? const Color(0xFFD8B4FE)
                      : const Color(0xFFEDE9F6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      if (isOpen) {
                        _expanded.remove(i);
                      } else {
                        _expanded.add(i);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: isOpen ? purple : lightPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isOpen
                                  ? Icons.remove_rounded
                                  : Icons.add_rounded,
                              color: isOpen ? Colors.white : purple,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              faq['q']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isOpen
                                    ? purple
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(54, 0, 14, 14),
                      child: Text(
                        faq['a']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),

          // ── Footer ──
          Center(
            child: Text(
              'Protos Laundries · Fotogenix Building, Kulambiro',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            color: purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _numberRow(String number,
      {required VoidCallback onTap, bool isWhatsapp = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isWhatsapp
              ? const Color(0xFFE8F5E9)
              : lightPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isWhatsapp ? Icons.chat_rounded : Icons.call_rounded,
              color: isWhatsapp ? const Color(0xFF4CAF50) : purple,
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isWhatsapp ? const Color(0xFF2E7D32) : purple,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isWhatsapp
                  ? const Color(0xFF4CAF50)
                  : purple,
            ),
          ],
        ),
      ),
    );
  }
}